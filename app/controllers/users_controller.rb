class UsersController < ApplicationController
  before_action :disable_dashboard_button, only: [:show]
  before_action :show_user_info, only: [:show]

  def index
  end

  def show
    current_user.recharge_lives!
    @lesson_map = LessonMap.new(current_user)

    # SEARCHING FOR FRIENDS ---------------------------------------------------------------
    # all_users passed as users to partial _friends.html AND removed current_user from list
    @all_users = User.search_by_username_and_email(params[:query]).where("id != ?", current_user.id)

    respond_to do |format|
      format.html # Follow regular flow of Rails
      format.text { render partial: 'friends.html', locals: { users: @all_users } }
    end
    # END ---------------------------------------------------------------------------------

    @all_friends = find_friends
    @information = random_information
  end

  private

  def find_friends
    friends = Friendship.where(asker: current_user).map { |friendship| friendship.receiver }
    friends.sort_by { |friend| friend.xp }.reverse
  end

  def random_information
    Information.all.sample
  end
end
