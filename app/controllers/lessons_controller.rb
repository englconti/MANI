class LessonsController < ApplicationController
  before_action :disable_nav, only: [:show]

  def show
    @current_lesson = Lesson.find(params[:id])
    # @answer_id = Answer.where(lesson: @lesson, user: current_user)[0].id

    # Finding all answers from the lesson questions of current user (*Try to make it better later!)
    @questions = @current_lesson.questions
    answers = @questions.map { |question| Answer.where(user: current_user, question: question)[0] }
    @answers_array = answers.map { |answer| answer.is_correct }

  end

  private

  def lesson_params
    params.require(:lesson).permit(:title, :description, :number_of_questions)
  end
end
