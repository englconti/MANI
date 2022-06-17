class AnswersController < ApplicationController
  def create
    # We will not have create because all instances of answers will be createad when a new user id created.
  end

  def update
    # answer_id
    # question_type
    answer_id = params[:answer_id].to_i
    answer = Answer.find(answer_id)

    if params[:question_type] == "writing"
      # params[:answer] == Boolean
      answer.is_correct = params[:answer]
    elsif params[:question_type] == "abcd"
      # params[:answer] == String
      user_answer = params[:answer]
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
        current_user.lives -= 1
        current_user.save
      end
    end
    answer.save
  end
end
