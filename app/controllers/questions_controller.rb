class QuestionsController < ApplicationController
  before_action :disable_nav, only: [:show]

  def show
    @question = Question.find(params[:id])
    # Questions added after the user signed up get their answer row on first visit
    @answer_id = current_user.answers.find_or_create_by!(question: @question).id
  end

  private

  def question_params
    params.require(:question).permit(:question_type,
                                     :statement, :level, :a, :b,
                                     :c, :d, :img_url, :correct_answer)
  end
end
