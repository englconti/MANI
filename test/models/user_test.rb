require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "creating a user creates one answer per existing question" do
    lesson = create_lesson(count: 3)
    user = create_user

    assert_equal 3, user.answers.count
    assert user.answers.none?(&:is_correct)
    assert_equal lesson.questions.pluck(:id).sort, user.answers.pluck(:question_id).sort
  end

  test "new users start with default xp, lives and manis" do
    user = create_user

    assert_equal 0, user.xp
    assert_equal 5, user.lives
    assert_equal 0, user.manis
  end

  # Only the database enforces username/birthday today (no model validation yet).
  test "username and birthday are required by the database" do
    user = User.new(email: "x@example.com", password: "senha1234")

    assert_raises(ActiveRecord::NotNullViolation) { user.save! }
  end

  test "search_by_username_and_email finds by username prefix" do
    target = create_user(username: "batman")
    create_user(username: "robin")

    assert_includes User.search_by_username_and_email("batm"), target
    assert_equal 1, User.search_by_username_and_email("batm").count
  end
end
