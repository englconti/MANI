require "test_helper"

class LivesAndStreakTest < ActiveSupport::TestCase
  setup { @user = create_user }

  # --- lives --------------------------------------------------------------------

  test "losing a life starts the recharge timer" do
    freeze_time do
      @user.lose_life!

      assert_equal 4, @user.lives
      assert_equal Time.current, @user.lives_recharge_started_at
      assert_equal 20.minutes.from_now, @user.next_life_at
    end
  end

  test "losing another life keeps the original timer" do
    started = 5.minutes.ago
    @user.update!(lives: 4, lives_recharge_started_at: started)

    @user.lose_life!

    assert_equal 3, @user.lives
    assert_in_delta started.to_f, @user.lives_recharge_started_at.to_f, 1
  end

  test "lives never go below zero" do
    @user.update!(lives: 0, lives_recharge_started_at: Time.current)

    @user.lose_life!

    assert_equal 0, @user.lives
  end

  test "one life comes back every 20 minutes" do
    freeze_time do
      @user.update!(lives: 2, lives_recharge_started_at: 45.minutes.ago)

      @user.recharge_lives!

      assert_equal 4, @user.lives
      # 5 minutes into the next life
      assert_equal 15.minutes.from_now, @user.next_life_at
    end
  end

  test "recharging up to the maximum clears the timer" do
    @user.update!(lives: 1, lives_recharge_started_at: 3.hours.ago)

    @user.recharge_lives!

    assert_equal HasLives::MAX_LIVES, @user.lives
    assert_nil @user.lives_recharge_started_at
    assert_nil @user.next_life_at
  end

  test "nothing happens before the first 20 minutes" do
    @user.update!(lives: 3, lives_recharge_started_at: 10.minutes.ago)

    @user.recharge_lives!

    assert_equal 3, @user.lives
  end

  test "a user missing lives without a timer gets one started" do
    @user.update!(lives: 3, lives_recharge_started_at: nil)

    @user.recharge_lives!

    assert_not_nil @user.lives_recharge_started_at
    assert_equal 3, @user.lives
  end

  test "out_of_lives? is true only at zero" do
    assert_not @user.out_of_lives?
    @user.update!(lives: 0)
    assert @user.out_of_lives?
  end

  # --- streak ----------------------------------------------------------------------

  test "the first study day starts a streak of one" do
    @user.register_study_day!(Date.new(2026, 10, 1))

    assert_equal 1, @user.streak_count
  end

  test "studying twice on the same day counts once" do
    day = Date.new(2026, 10, 1)
    @user.register_study_day!(day)
    @user.register_study_day!(day)

    assert_equal 1, @user.streak_count
  end

  test "studying on consecutive days grows the streak" do
    @user.register_study_day!(Date.new(2026, 10, 1))
    @user.register_study_day!(Date.new(2026, 10, 2))
    @user.register_study_day!(Date.new(2026, 10, 3))

    assert_equal 3, @user.streak_count
  end

  test "skipping a day restarts the streak" do
    @user.register_study_day!(Date.new(2026, 10, 1))
    @user.register_study_day!(Date.new(2026, 10, 2))
    @user.register_study_day!(Date.new(2026, 10, 4))

    assert_equal 1, @user.streak_count
  end

  test "current_streak is zero once a whole day was skipped" do
    @user.update!(streak_count: 5, last_study_on: Date.new(2026, 10, 1))

    assert_equal 5, @user.current_streak(Date.new(2026, 10, 1))
    assert_equal 5, @user.current_streak(Date.new(2026, 10, 2)) # can still study today
    assert_equal 0, @user.current_streak(Date.new(2026, 10, 3))
  end
end
