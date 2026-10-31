class DailyGoalsController < ApplicationController
  def update
    goal = params[:goal].to_i
    if User::DAILY_GOALS.key?(goal) && current_user.update(daily_goal: goal)
      redirect_to user_path(current_user), notice: "Meta do dia: #{goal} XP."
    else
      redirect_to user_path(current_user), alert: "Escolha uma meta entre as opções."
    end
  end
end
