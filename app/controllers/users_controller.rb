class UsersController < ApplicationController
  def show
    refill_lives
    # Conceitos Básicos I
    @lesson1 = render_lesson(1)
    # Conceitos Básicos II
    @lesson2 = render_lesson(2)
    # Finanças Pessoais I
    @lesson3 = render_lesson(3)
    # Renda Fixa I
    @lesson4 = render_lesson(4)
    # Renda Variável I
    @lesson5 = render_lesson(5)
    # Finanças Pessoais II
    @lesson6 = render_lesson(6)
    # FII I
    @lesson7 = render_lesson(7)
  end

  def render_lesson(lesson_id)
    @user = current_user
    lesson = Lesson.find(lesson_id)
    questions_count = lesson.questions.count
    lesson_answers = @user.answers.where("question_id > ? and question_id < ?", lesson.questions.first.id - 1, lesson.questions.first.id + questions_count)
    correct_answers_count = lesson_answers.where("is_correct = ?", true).count
    [lesson, correct_answers_count, questions_count]
  end

  def refill_lives
    current_user.lives = 5
    current_user.save
  end

end
