require "test_helper"

class LessonMapTest < ActiveSupport::TestCase
  setup do
    @first = create_lesson(count: 4)
    @second = create_lesson(count: 2)
    @third = create_lesson(count: 2)
    @user = create_user
  end

  def states(user = @user)
    LessonMap.new(user).nodes.map(&:state)
  end

  test "only the first lesson is open for a new user" do
    assert_equal %i[current locked locked], states
  end

  test "finishing a lesson completes it and opens the next" do
    LessonCompletion.create!(user: @user, lesson: @first)

    assert_equal %i[completed current locked], states
  end

  test "unlocked? is true for finished and current lessons only" do
    LessonCompletion.create!(user: @user, lesson: @first)
    map = LessonMap.new(@user)

    assert map.unlocked?(@first)
    assert map.unlocked?(@second)
    assert_not map.unlocked?(@third)
  end

  test "nodes carry the score and stars" do
    @user.answers.where(question: @first.questions).update_all(is_correct: true)
    LessonCompletion.create!(user: @user, lesson: @first, correct_count: 4)

    node = LessonMap.new(@user).nodes.first

    assert_equal 4, node.correct
    assert_equal 4, node.total
    assert_equal 100, node.percent
    assert_equal 3, node.stars
  end

  test "stars depend on the score" do
    # 4 questions: 25% and 50% -> 1 star, 75% -> 2 stars, 100% -> 3 stars
    {1 => 1, 2 => 1, 3 => 2, 4 => 3}.each do |correct, expected|
      user = create_user
      user.answers.where(question: @first.questions.first(correct)).update_all(is_correct: true)
      LessonCompletion.create!(user: user, lesson: @first, correct_count: correct)

      assert_equal expected, LessonMap.new(user).nodes.first.stars, "#{correct} correct answers"
    end
  end

  test "everything is completed once all lessons are finished" do
    [@first, @second, @third].each { |lesson| LessonCompletion.create!(user: @user, lesson: lesson) }

    assert_equal %i[completed completed completed], states
    assert_nil LessonMap.new(@user).current
  end
end
