class AnswersController < ApplicationController
  def create
    # We will not have create because all instances of answers will be createad when a new user id created.
  end

  def update
    @user_answer = params[:answer]
    @answer_id = params[:answer_id]
    @question_id = Question.find(@answer_id.to_i).id
    puts "-----------------------------------"
    correct_answer = Question.find(@question_id).correct_answer
    # binding.pry

    if correct_answer == @user_answer
      puts "Well Done!! 😁😁😁😀😀"
    else
      puts "WRONG DUMBASS 👹👿👿"
    end

  end
end
