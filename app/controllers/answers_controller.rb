class AnswersController < ApplicationController
  def create
    # We will not have create because all instances of answers will be createad when a new user id created.
  end

  # The client only sends what the user chose/typed (params[:answer]); the
  # server decides whether it is correct. Only the user's own answers are reachable.
  def update
    answer = current_user.answers.find(params[:id])
    answer.submit!(params[:answer])
    # The client calls this with fetch (Accept: json) and has no template to render
    head :no_content
  end
end
