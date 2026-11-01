require "test_helper"

class ProgressTest < ActiveSupport::TestCase
  # --- Levels --------------------------------------------------------------------------

  test "the level comes from the total XP" do
    assert_equal "Cofrinho", PlayerLevel.for(0).name
    assert_equal "Cofrinho", PlayerLevel.for(74).name
    assert_equal "Poupador", PlayerLevel.for(75).name
    assert_equal 2, PlayerLevel.for(75).number
    assert_equal "Investidor", PlayerLevel.for(170).name
    assert_equal "Estrategista", PlayerLevel.for(300).name
    assert_equal "Sábio", PlayerLevel.for(450).name
  end

  test "a negative or missing XP is the first level" do
    assert_equal "Cofrinho", PlayerLevel.for(-5).name
    assert_equal "Cofrinho", PlayerLevel.for(nil).name
  end

  test "progress inside a level and what is missing for the next" do
    level = PlayerLevel.for(122) # Poupador runs from 75 to 170

    assert_equal 49, level.percent
    assert_equal 48, level.xp_to_next
    assert_equal "Investidor", level.next_name
    assert_not level.max?
  end

  test "the last level has no next one and is full" do
    level = PlayerLevel.for(999)

    assert_equal "Lenda", level.name
    assert level.max?
    assert_equal 100, level.percent
    assert_equal 0, level.xp_to_next
  end

  test "the thresholds go up and a lesson can be finished with the first points" do
    minimums = PlayerLevel::LEVELS.map(&:last)

    assert_equal minimums.sort, minimums
    assert_equal 0, minimums.first
    assert_operator minimums[1], :<=, 2 * 40
    assert_equal 7, minimums.size
    # reachable: the lessons give 5 XP per right answer
    assert_operator minimums.last, :<=, Question.count.nonzero? ? 5 * Question.count : 505
  end

  # --- XP per day ----------------------------------------------------------------------

  test "credit adds up during the day and ignores zero" do
    user = create_user

    XpDay.credit!(user, 10)
    XpDay.credit!(user, 15)
    XpDay.credit!(user, 0)

    assert_equal 25, user.xp_today
    assert_equal 1, user.xp_days.count
  end

  test "each day has its own total" do
    user = create_user
    XpDay.credit!(user, 10, day: Date.new(2026, 11, 2))
    XpDay.credit!(user, 5, day: Date.new(2026, 11, 3))

    assert_equal 10, user.xp_today(Date.new(2026, 11, 2))
    assert_equal 5, user.xp_today(Date.new(2026, 11, 3))
    assert_equal 0, user.xp_today(Date.new(2026, 11, 4))
  end

  test "the week starts on Monday" do
    user = create_user
    sunday = Date.new(2026, 11, 1)
    monday = Date.new(2026, 11, 2)
    wednesday = Date.new(2026, 11, 4)
    XpDay.credit!(user, 50, day: sunday)
    XpDay.credit!(user, 10, day: monday)
    XpDay.credit!(user, 5, day: wednesday)

    assert_equal({ user.id => 15 }, XpDay.week_totals([user.id], today: wednesday))
    assert_equal({ user.id => 50 }, XpDay.week_totals([user.id], today: sunday))
  end

  test "finishing a lesson credits the XP to today and a repeat adds nothing" do
    lesson = create_lesson(count: 3)
    user = create_user

    LessonCompletion.record!(user: user, lesson: lesson, correct_count: 2)
    assert_equal 10, user.reload.xp_today

    LessonCompletion.record!(user: user, lesson: lesson, correct_count: 2)
    assert_equal 10, user.reload.xp_today

    LessonCompletion.record!(user: user, lesson: lesson, correct_count: 3)
    assert_equal 15, user.reload.xp_today
    assert_equal 15, user.xp
  end

  # --- Daily goal, streak ------------------------------------------------------------------

  test "the daily goal is one of the offered steps" do
    user = create_user

    assert_equal 20, user.daily_goal
    user.daily_goal = 40
    assert user.valid?
    user.daily_goal = 15
    assert_not user.valid?
  end

  test "the goal is reached when today's XP gets to it" do
    user = create_user
    XpDay.credit!(user, 19)
    assert_not user.daily_goal_reached?

    XpDay.credit!(user, 1)
    assert user.daily_goal_reached?
  end

  test "the streak is at risk only when they studied yesterday and not yet today" do
    today = Date.new(2026, 11, 4)
    user = create_user

    user.update!(streak_count: 3, last_study_on: today - 1)
    assert user.streak_at_risk?(today)

    user.update!(last_study_on: today)
    assert_not user.streak_at_risk?(today)

    user.update!(last_study_on: today - 2)
    assert_not user.streak_at_risk?(today)

    user.update!(streak_count: 0, last_study_on: nil)
    assert_not user.streak_at_risk?(today)
  end

  test "completed_lesson? looks at the completions" do
    lesson = create_lesson(count: 1)
    user = create_user
    assert_not user.completed_lesson?(lesson)

    LessonCompletion.create!(user: user, lesson: lesson)
    assert user.completed_lesson?(lesson)
  end

  test "deleting a user deletes their XP days" do
    user = create_user
    XpDay.credit!(user, 10)

    assert_difference -> { XpDay.count }, -1 do
      user.destroy
    end
  end

  test "all levels list the range of each one and where this XP stands" do
    entries = PlayerLevel.all(130)

    assert_equal PlayerLevel::LEVELS.size, entries.size
    assert_equal %i[done current locked locked locked locked locked], entries.map(&:state)
    assert_equal [1, 2, 3, 4, 5, 6, 7], entries.map(&:number)
    assert_equal [0, 75, 170, 275, 365, 430, 480], entries.map(&:from)
    assert_equal [75, 170, 275, 365, 430, 480, nil], entries.map(&:to)
  end

  test "with no XP the first level is the current one" do
    assert_equal %i[current locked locked locked locked locked locked], PlayerLevel.all(0).map(&:state)
  end
end
