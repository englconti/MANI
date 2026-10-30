# Shown when the user has no lives left: explains the rule and counts down to the next life.
class LivesController < ApplicationController
  before_action :disable_nav

  def show
    current_user.recharge_lives!
    return redirect_to user_path(current_user), notice: "Suas vidas voltaram!" unless current_user.out_of_lives?

    @next_life_at = current_user.next_life_at
  end
end
