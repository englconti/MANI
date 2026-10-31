class LessonsController < ApplicationController
  before_action :disable_nav, only: [:show]
  before_action :set_lesson
  before_action :require_unlocked_lesson

  def show
    answers = @lesson.answers.where(user: current_user)
    @questions = @lesson.questions
    @true_count = answers.where(is_correct: true).count

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

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end

  def require_unlocked_lesson
    return if LessonMap.new(current_user).unlocked?(@lesson)

    redirect_to user_path(current_user), alert: "Termine #{@lesson.prerequisite&.title || "a aula anterior"} para liberar esta aula."
  end
end
