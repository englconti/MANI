class QuestionsController < ApplicationController
  before_action :disable_nav, only: [:show]

  def show
    @question = Question.find(params[:id])
    unless LessonMap.new(current_user).unlocked?(@question.lesson)
      return redirect_to user_path(current_user), alert: "Termine #{@question.lesson.prerequisite&.title || "a aula anterior"} para liberar esta aula."
    end

    @practice = params[:practice].present? && current_user.completed_lesson?(@question.lesson)

    current_user.recharge_lives!
    return redirect_to no_lives_path if current_user.out_of_lives? && !@practice

    # "Refazer só as que errei": the ids to go through, kept in the URL so no state is needed
    lesson_questions = @question.lesson.questions.to_a
    retry_ids = params[:retry].to_s.split("-").map(&:to_i)
    @retry_ids = retry_ids if retry_ids.include?(@question.id)
    @sequence = @retry_ids ? lesson_questions.select { |question| @retry_ids.include?(question.id) } : lesson_questions

    # Questions added after the user signed up get their answer row on first visit
    @answer_id = current_user.answers.find_or_create_by!(question: @question).id
  end
end
