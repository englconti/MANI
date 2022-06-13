class LessonsController < ApplicationController
  before_action :disable_nav, only: [:show]

  def show
    @current_lesson = Lesson.find(params[:id])

    # Finding all answers from the lesson questions of current user (*Try to make it better later!)
    @questions = @current_lesson.questions

    # answers = @questions.map { |question| Answer.where(user: current_user, question: question)[0] }
    # new way of calling answers -> lesson has_many :answers, through: :questions
    answers = @current_lesson.answers.where(user: current_user)
    @answers_array = answers.map { |answer| answer.is_correct }
  end

  private

  def lesson_params
    params.require(:lesson).permit(:title, :description)
  end
end
