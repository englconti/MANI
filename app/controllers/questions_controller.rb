class QuestionsController < ApplicationController

  def show
    @question = Question.find(params[:id])

    @answer_id = Answer.where(question: @question, user: current_user)[0].id
  end

  # Questions are created on the seed file!
  # def create
  #   # @question = Question.new(question_params)
  #   # @question.lesson_id = Lesson.find(lesson_params)
  # end

  private

  def question_params
    params.require(:question).permit(:question_type,
                                     :statement, :level, :a, :b,
                                     :c, :d, :img_url, :correct_answer)
  end
end
