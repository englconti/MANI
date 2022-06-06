class UsersController < ApplicationController
  def show
    @user = current_user

    # Do the logic to get the answers from the user in all lessons and render it in the show page.
    # ON PROGRESS
    # Lesson.all.each do |lesson|
    #   lesson_answers = @user.answers.where("Condição que pega as respostas da lesson em questão que o usuário respondeu")
    #   lesson.number_of_questions

    # end
  end
end
