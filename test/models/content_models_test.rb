require "test_helper"

class ContentModelsTest < ActiveSupport::TestCase
  test "lesson requires title and description" do
    assert_not Lesson.new.valid?
    assert Lesson.new(title: "t", description: "d").valid?
  end

  test "lesson exposes its answers through questions" do
    lesson = create_lesson(count: 2)
    user = create_user

    assert_equal 2, lesson.answers.where(user: user).count
  end

  test "question requires a valid type, statement and correct answer" do
    lesson = Lesson.create!(title: "t", description: "d")
    base = { lesson: lesson, statement: "s", correct_answer: "a" }

    assert Question.new(base.merge(question_type: "abcd")).valid?
    assert Question.new(base.merge(question_type: "writing")).valid?
    assert_not Question.new(base.merge(question_type: "other")).valid?
    assert_not Question.new(base.merge(question_type: "abcd", statement: nil)).valid?
    assert_not Question.new(base.merge(question_type: "abcd", correct_answer: nil)).valid?
  end

  test "friendship links asker and receiver" do
    asker = create_user
    receiver = create_user
    friendship = Friendship.create!(asker: asker, receiver: receiver)

    assert_includes asker.friendships_as_asker, friendship
    assert_includes receiver.friendships_as_receiver, friendship
  end

  test "friendship requires both users" do
    assert_not Friendship.new(asker: create_user).valid?
  end
end
