class AnswersController < ApplicationController
  def create
    @answer = Question.find(question_id).correct_answer
    # if @answer ==
  end

  def update
  end
end
