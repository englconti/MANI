class AnswersController < ApplicationController
  def create
    # We will not have create because all instances of answers will be createad when a new user id created.
  end

  # The client only sends what the user chose/typed (params[:answer]); the
  # server decides whether it is correct. Only the user's own answers are reachable.
  def update
    answer = current_user.answers.find(params[:id])
    correct = answer.submit!(params[:answer])
    # The correct answer is revealed only now, after the user has answered
    render json: { correct: correct,
                   correct_answer_label: answer.question.correct_answer_label,
                   lives: current_user.reload.lives }
  end
end
