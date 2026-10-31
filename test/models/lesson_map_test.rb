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

  test "a card named by the track holds lessons of different subjects" do
    root = Lesson.create!(title: "Orçamento Pessoal", description: "d", track: "Finanças Pessoais")
    Question.create!(lesson: root, question_type: "abcd", statement: "q", a: "a", b: "b", c: "c", d: "d", correct_answer: "a")
    second = create_lesson(title: "Dívidas e Cartão de Crédito", count: 1, prerequisite: root)
    third = create_lesson(title: "Reserva de Emergência", count: 1, prerequisite: second)
    Lesson.where(id: [second.id, third.id]).update_all(track: "Finanças Pessoais")
    Lesson.where(id: third.id).update_all(level: 3)
    user = create_user

    track = LessonMap.new(user).tracks.find { |candidate| candidate.subject == "Finanças Pessoais" }

    assert_equal [root, second, third], track.nodes.map(&:lesson)
  end

  test "two lessons that need the same one both stay in its track" do
    root = create_lesson(count: 1)
    a = create_lesson(count: 1, prerequisite: root)
    b = create_lesson(count: 1, prerequisite: root)
    user = create_user

    track = LessonMap.new(user).tracks.find { |candidate| candidate.nodes.first.lesson == root }

    assert_equal [root, a, b], track.nodes.map(&:lesson)
  end

  test "levels go up to three" do
    lesson = Lesson.new(title: "X", description: "d", level: 3)
    assert lesson.valid?

    lesson.level = 4
    assert_not lesson.valid?
  end

  test "subject drops a trailing III too" do
    assert_equal "Algo", Lesson.new(title: "Algo III").subject
  end
end
