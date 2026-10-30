class QuestionsController < ApplicationController
  before_action :disable_nav, only: [:show]

  def show
    @question = Question.find(params[:id])
    unless LessonMap.new(current_user).unlocked?(@question.lesson)
      return redirect_to user_path(current_user), alert: "Termine a aula anterior para liberar esta."
    end

    current_user.recharge_lives!
    return redirect_to no_lives_path if current_user.out_of_lives?

    # Questions added after the user signed up get their answer row on first visit
    @answer_id = current_user.answers.find_or_create_by!(question: @question).id
  end
end
