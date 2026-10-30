class LessonsController < ApplicationController
  before_action :disable_nav, only: [:show]

  def show
    @current_lesson = Lesson.find(params[:id])

    @questions = @current_lesson.questions
    answers = @current_lesson.answers.where(user: current_user)
    @answers_array = answers.map { |answer| answer.is_correct }
    @true_count = @answers_array.count(true)

    # Idempotent: only an improvement over the best score is rewarded
    LessonCompletion.record!(user: current_user, lesson: @current_lesson, correct_count: @true_count)
  end

  # Redoing a lesson refills the lives (explicit POST instead of a side effect on GET)
  def restart
    lesson = Lesson.find(params[:id])
    current_user.update(lives: 5)
    redirect_to question_path(lesson.questions.first)
  end
end
