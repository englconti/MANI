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
      format.text { render partial: 'friends', formats: [:html], locals: { users: @all_users } }
    end
    # END ---------------------------------------------------------------------------------

    @all_friends = find_friends
    @ranking = build_ranking(@all_friends)
  end

  private

  def find_friends
    friends = Friendship.where(asker: current_user).map { |friendship| friendship.receiver }
    friends.sort_by { |friend| friend.xp }.reverse
  end

  # Me and the people I follow, by XP earned this week (Monday to today). Same XP, same place.
  Place = Struct.new(:user, :xp, :rank, :me, keyword_init: true)

  def build_ranking(friends)
    people = (friends + [current_user]).uniq
    totals = XpDay.week_totals(people.map(&:id))
    ordered = people.sort_by { |person| [-totals.fetch(person.id, 0), person.username.downcase] }

    rank = 0
    previous = nil
    ordered.each_with_index.map do |person, index|
      xp = totals.fetch(person.id, 0)
      rank = index + 1 unless xp == previous
      previous = xp
      Place.new(user: person, xp: xp, rank: rank, me: person == current_user)
    end
  end

end
