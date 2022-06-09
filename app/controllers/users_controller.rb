class UsersController < ApplicationController
  def show
    @lesson1 = render_lesson(1)
    @lesson2 = render_lesson(2)
    @lesson3 = render_lesson(3)
    @lesson4 = render_lesson(4)
    @lesson5 = render_lesson(5)
  end

  def render_lesson(lesson_id)
    @user = current_user
    lesson = Lesson.find(lesson_id)
    questions_count = lesson.questions.count
    lesson_answers = @user.answers.where("question_id > ? and question_id < ?", lesson.questions.first.id - 1, lesson.questions.first.id + questions_count)
    correct_answers_count = lesson_answers.where("is_correct = ?", true).count
    [lesson, correct_answers_count, questions_count]
  end
end
