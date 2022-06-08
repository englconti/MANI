class UsersController < ApplicationController
  def show
    @user = current_user

    l1 = Lesson.find(1)
    @l1_num_questions = l1.questions.count
    l1_answers = @user.answers.where("question_id < ?", l1.questions.count + 1)
    @l1_correct_answers = l1_answers.where("is_correct = ?", true).count


    # Do the logic to get the answers from the user in all lessons and render it in the show page.
    # ON PROGRESS
    # Lesson.all.each do |lesson|
    #   lesson_answers = @user.answers.where("Condição que pega as respostas da lesson em questão que o usuário respondeu")
    #   lesson.number_of_questions

    # end
  end
end
