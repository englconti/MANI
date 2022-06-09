class AnswersController < ApplicationController
  def create
    # We will not have create because all instances of answers will be createad when a new user id created.
  end

  def update
    user_answer = params[:answer]
    answer_id = params[:answer_id].to_i
    answer = Answer.find(answer_id)
    question = Answer.find(answer_id).question
    question_id = question.id
    # binding.pry
    correct_answer = Question.find(question_id).correct_answer

    if correct_answer == user_answer
      puts "Well Done!! 😁😁😁😀😀"
      answer.is_correct = true
    else
      puts "WRONG DUMBASS 👹👿👿"
      answer.is_correct = false
    end

    answer.save
  end
end
