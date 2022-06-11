class QuestionsController < ApplicationController

  before_action :disable_nav, only: [:show]

  def show
    @question = Question.find(params[:id])

    @answer_id = Answer.where(question: @question, user: current_user)[0].id

    i = 0
    if [1, 6, 11, 16, 21].include? @question.id
      i = 0
    elsif [2, 7, 12, 17, 22].include? @question.id
      i = 1
    elsif [3, 8, 13, 18, 23].include? @question.id
      i = 2
    elsif [4, 9, 14, 19, 24].include? @question.id
      i = 3
    elsif [5, 10, 15, 20, 25].include? @question.id
      i = 4
    end

    array_of_advancement = ["0", "12vw", "24vw", "36vw", "48vw", "60vw"]

    @bar_advancement = array_of_advancement[i]
  end

  # Questions are created on the seed file!
  # def create
  #   # @question = Question.new(question_params)
  #   # @question.lesson_id = Lesson.find(lesson_params)
  # end

  private

  def question_params
    params.require(:question).permit(:question_type,
                                     :statement, :level, :a, :b,
                                     :c, :d, :img_url, :correct_answer)
  end
end
