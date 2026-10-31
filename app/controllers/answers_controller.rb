class AnswersController < ApplicationController
  def create
    # We will not have create because all instances of answers will be createad when a new user id created.
  end

  # The client only sends what the user chose/typed (params[:answer]); the
  # server decides whether it is correct. Only the user's own answers are reachable.
  def update
    answer = current_user.answers.find(params[:id])
    # Practice grades the answer but costs no life and changes no score or streak. It is only
    # for lessons already completed, so it can't be used to peek at answers without penalty.
    practice = ActiveModel::Type::Boolean.new.cast(params[:practice]) && current_user.completed_lesson?(answer.question.lesson)
    correct = practice ? answer.question.correct?(params[:answer]) : answer.submit!(params[:answer])
    # The correct answer is revealed only now, after the user has answered
    render json: { correct: correct,
                   correct_answer_label: answer.question.correct_answer_label,
                   correct_answer_text: answer.question.correct_answer_text,
                   correct_option: answer.question.question_type == "abcd" ? answer.question.correct_answer : nil,
                   explanation: answer.question.explanation.presence,
                   lives: current_user.reload.lives }
  end
end
