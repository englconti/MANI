require "test_helper"

class PagesAndAccessTest < ActionDispatch::IntegrationTest
  test "home is public" do
    get root_url
    assert_response :success
  end

  test "sign up and login pages are public" do
    get new_user_registration_url
    assert_response :success
    get new_user_session_url
    assert_response :success
  end

  test "private pages redirect anonymous visitors to login" do
    lesson = create_lesson

    [user_path(1), lesson_path(lesson), question_path(lesson.questions.first),
     friendships_path].each do |path|
      get path
      assert_redirected_to new_user_session_url, "expected #{path} to require login"
    end
  end

  test "products are public" do
    get products_url
    assert_response :success
  end

  test "sign up creates a user and their answers" do
    create_lesson(count: 2)

    assert_difference -> { User.count } => 1, -> { Answer.count } => 2 do
      post user_registration_url, params: { user: {
        username: "novo", email: "novo@example.com", birthday: "2001-02-03",
        password: "senha1234", password_confirmation: "senha1234"
      } }
    end
    assert_response :redirect
  end
end
