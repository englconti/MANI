require "test_helper"

class LessonMapTest < ActiveSupport::TestCase
  # first and second are level 1 (open from the start); third is a level 2 lesson
  # that only needs the first one.
  setup do
    @first = create_lesson(count: 4)
    @second = create_lesson(count: 2)
    @third = create_lesson(count: 2, prerequisite: @first)
    @user = create_user
  end

  def states(user = @user)
    LessonMap.new(user).nodes.map(&:state)
  end

  test "level 1 lessons are open and level 2 waits for its prerequisite" do
    assert_equal %i[available available locked], states
  end

  test "finishing a lesson completes it and opens only its follow-up" do
    LessonCompletion.create!(user: @user, lesson: @first)

    assert_equal %i[completed available available], states
  end

  test "finishing an unrelated level 1 lesson does not open the level 2 lesson" do
    LessonCompletion.create!(user: @user, lesson: @second)

    assert_equal %i[available completed locked], states
  end

  test "unlocked? follows the prerequisite" do
    assert LessonMap.new(@user).unlocked?(@second)
    assert_not LessonMap.new(@user).unlocked?(@third)

    LessonCompletion.create!(user: @user, lesson: @first)
    map = LessonMap.new(@user)

    assert map.unlocked?(@first)
    assert map.unlocked?(@third)
  end

  test "a locked node knows which lesson unlocks it" do
    node = LessonMap.new(@user).nodes.last

    assert node.locked?
    assert_equal @first, node.prerequisite
  end

  test "tracks put each lesson behind its prerequisite" do
    tracks = LessonMap.new(@user).tracks

    assert_equal [[@first, @third], [@second]], tracks.map { |track| track.nodes.map(&:lesson) }
  end

  test "subject drops the level numeral from the title" do
    assert_equal "Finanças Pessoais", Lesson.new(title: "Finanças Pessoais II").subject
    assert_equal "FII", Lesson.new(title: "FII I").subject
  end

  test "available_count counts every open lesson" do
    assert_equal 2, LessonMap.new(@user).available_count
  end

  test "a lesson cannot be its own prerequisite" do
    @first.prerequisite = @first

    assert_not @first.valid?
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
