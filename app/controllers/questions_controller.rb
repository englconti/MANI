class QuestionsController < ApplicationController
  before_action :disable_nav, only: [:show]

  def show
    @question = Question.find(params[:id])
    @type = @question.question_type
    @answer_id = Answer.where(question: @question, user: current_user)[0].id
    @statement = @question.statement
    @choice_a = @question.a
    @choice_b = @question.b
    @choice_c = @question.c
    @choice_d = @question.d
  end

  private

  def question_params
    params.require(:question).permit(:question_type,
                                     :statement, :level, :a, :b,
                                     :c, :d, :img_url, :correct_answer)
  end
end
