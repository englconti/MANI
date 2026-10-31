class LessonsController < ApplicationController
  before_action :disable_nav, only: [:show]
  before_action :set_lesson
  before_action :require_unlocked_lesson

  def show
    answers = @lesson.answers.where(user: current_user)
    @questions = @lesson.questions
    @true_count = answers.where(is_correct: true).count
    @wrong_count = answers.where(is_correct: false).count

    # Idempotent: only an improvement over the best score is rewarded
    gained = LessonCompletion.record!(user: current_user, lesson: @lesson, correct_count: @true_count)
    @xp_gained = gained * LessonCompletion::XP_PER_CORRECT_ANSWER
    @manis_gained = gained * LessonCompletion::MANIS_PER_CORRECT_ANSWER
    @map = LessonMap.new(current_user)
    current_user.recharge_lives!
  end

  # Redoing a lesson needs at least one life; lives are only recharged by time
  def restart
    current_user.recharge_lives!
    return redirect_to no_lives_path if current_user.out_of_lives?

    redirect_to question_path(@lesson.questions.first)
  end

  # Goes through only the questions the user got wrong, in lesson order
  def retry_wrong
    current_user.recharge_lives!
    return redirect_to no_lives_path if current_user.out_of_lives?

    wrong_ids = current_user.answers.where(question: @lesson.questions, is_correct: false).pluck(:question_id).to_set
    wrong = @lesson.questions.select { |question| wrong_ids.include?(question.id) }
    return redirect_to lesson_path(@lesson), notice: "Você acertou tudo: não há o que refazer." if wrong.empty?

    redirect_to question_path(wrong.first, retry: wrong.map(&:id).join("-"))
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end

  def require_unlocked_lesson
    return if LessonMap.new(current_user).unlocked?(@lesson)

    redirect_to user_path(current_user), alert: "Termine #{@lesson.prerequisite&.title || "a aula anterior"} para liberar esta aula."
  end
end
