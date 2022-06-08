class UsersController < ApplicationController
  def show
    @user = current_user

    # Lesson 1 -----------------------------------------------------------------
    l1 = Lesson.find(1)
    @l1_num_questions = l1.questions.count
    l1_answers = @user.answers.where("question_id < ?", l1.questions.count + 1)
    @l1_correct_answers = l1_answers.where("is_correct = ?", true).count
    # --------------------------------------------------------------------------
    # Lesson 2 -----------------------------------------------------------------
    l2 = Lesson.find(2)
    @l2_num_questions = l2.questions.count
    l2_answers = @user.answers.where("question_id > ? and question_id < ?", l2.questions.first.id, l2.questions.first.id + @l2_num_questions)
    @l2_correct_answers = l2_answers.where("is_correct = ?", true).count
    # --------------------------------------------------------------------------
    # Lesson 3 -----------------------------------------------------------------
    l3 = Lesson.find(3)
    @l3_num_questions = l3.questions.count
    l3_answers = @user.answers.where("question_id > ? and question_id < ?", l3.questions.first.id, l3.questions.first.id + @l3_num_questions)
    @l3_correct_answers = l3_answers.where("is_correct = ?", true).count
    # --------------------------------------------------------------------------
    # Lesson 4 -----------------------------------------------------------------
    l4 = Lesson.find(4)
    @l4_num_questions = l4.questions.count
    l4_answers = @user.answers.where("question_id > ? and question_id < ?", l4.questions.first.id, l4.questions.first.id + @l4_num_questions)
    @l4_correct_answers = l4_answers.where("is_correct = ?", true).count
    # --------------------------------------------------------------------------
    # Lesson 5 -----------------------------------------------------------------
    l5 = Lesson.find(5)
    @l5_num_questions = l5.questions.count
    l5_answers = @user.answers.where("question_id > ? and question_id < ?", l5.questions.first.id, l5.questions.first.id + @l5_num_questions)
    @l5_correct_answers = l5_answers.where("is_correct = ?", true).count
    # --------------------------------------------------------------------------

    # Do the logic to get the answers from the user in all lessons and render it in the show page.
    # ON PROGRESS
    # Lesson.all.each do |lesson|
    #   lesson_answers = @user.answers.where("Condição que pega as respostas da lesson em questão que o usuário respondeu")
    #   lesson.number_of_questions

    # end
  end
end
