class LessonsController < ApplicationController
  before_action :disable_nav, only: [:show]
  # NOTE: show still credits XP on every visit (known defect B-1, see docs/spec/01-backend.md)

  def show
    @current_lesson = Lesson.find(params[:id])

    # Finding all answers from the lesson questions of current user (*Try to make it better later!)
    @questions = @current_lesson.questions

    # answers = @questions.map { |question| Answer.where(user: current_user, question: question)[0] }
    # new way of calling answers -> lesson has_many :answers, through: :questions
    answers = @current_lesson.answers.where(user: current_user)
    @answers_array = answers.map { |answer| answer.is_correct }
    @true_count = @answers_array.count(true)

    # Add XP points to user
    add_xp

    # Add Mani$ to user
    add_manis
  end

  # Redoing a lesson refills the lives (explicit POST instead of a side effect on GET)
  def restart
    lesson = Lesson.find(params[:id])
    current_user.update(lives: 5)
    redirect_to question_path(lesson.questions.first)
  end

  private

  def add_xp
    user = current_user
    user.xp += @true_count * 5
    user.save
  end

  def add_manis
    user = current_user
    user.manis += @true_count * 3
    user.save
  end

  def lesson_params
    params.require(:lesson).permit(:title, :description)
  end
end
