require "test_helper"

class PagesAndAccessTest < ActionDispatch::IntegrationTest
  test "home is public" do
    get root_url
    assert_response :success
  end

  test "signing in goes straight to the user page" do
    user = create_user

    post user_session_url, params: { user: { username: user.username, password: "senha1234" } }

    assert_redirected_to user_url(user)
  end

  test "landing page has the calls to action for visitors" do
    get root_url

    assert_select "a#banner-btn-register[href='#{new_user_registration_path}']"
    assert_select "a#banner-btn-login[href='#{new_user_session_path}']"
    assert_select ".steps .step-card", 3
  end

  test "landing page for a signed in user points to the trail" do
    user = create_user
    sign_in user

    get root_url

    assert_select "a#banner-btn-login[href='#{user_path(user)}']"
    assert_select "a#banner-btn-register", 0
  end

  test "sign up form uses the native date picker and a show-password toggle" do
    get new_user_registration_url

    assert_select "input[type=date][name='user[birthday]']"
    assert_select "[data-controller=password] input[type=checkbox]"
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
