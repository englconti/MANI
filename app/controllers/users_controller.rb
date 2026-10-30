class UsersController < ApplicationController
  before_action :disable_dashboard_button, only: [:show]
  before_action :show_user_info, only: [:show]

  def index
  end

  def show
    refill_lives
    @lesson_rows = lesson_rows

    # SEARCHING FOR FRIENDS ---------------------------------------------------------------
    # all_users passed as users to partial _friends.html AND removed current_user from list
    @all_users = User.search_by_username_and_email(params[:query]).where("id != ?", current_user.id)

    respond_to do |format|
      format.html # Follow regular flow of Rails
      format.text { render partial: 'friends.html', locals: { users: @all_users } }
    end
    # END ---------------------------------------------------------------------------------

    # FOLLOWED friends to be rendered -----------------------------------------------------
    @all_friends = find_friends
    # -------------------------------------------------------------------------------------

    # RANDOM Information ------------------------------------------------------------------
    @information = random_information
    # -------------------------------------------------------------------------------------
  end

  def find_friends
    friends = Friendship.where(asker: current_user).map { |friendship| friendship.receiver }
    friends.sort_by { |friend| friend.xp }.reverse
  end

  # Lessons that have questions, in map order, as [lesson, correct_count, total]
  # groups for the map rows (1 lesson, then 2, then 3 per row).
  def lesson_rows
    totals = Question.group(:lesson_id).count
    corrects = current_user.answers.where(is_correct: true).joins(:question)
                           .group("questions.lesson_id").count
    entries = Lesson.ordered.where(id: totals.keys).map do |lesson|
      [lesson, corrects.fetch(lesson.id, 0), totals.fetch(lesson.id)]
    end
    first_rows = [entries.shift(1), entries.shift(2)]
    (first_rows + entries.each_slice(3).to_a).reject(&:empty?)
  end

  def refill_lives
    current_user.lives = 5
    current_user.save
  end

  def random_information
    Information.all.sample
  end
end
