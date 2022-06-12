class LessonsController < ApplicationController
  before_action :disable_nav, only: [:show]

  def show
    @current_lesson = Lesson.find(params[:id])
    # @answer_id = Answer.where(lesson: @lesson, user: current_user)[0].id

  end

  private

  def lesson_params
    raise
    params.require(:lesson).permit(:lesson_type,
                                     :statement, :level, :a, :b,
                                     :c, :d, :img_url, :correct_answer)
  end
end
