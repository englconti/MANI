require "test_helper"

class SocialAndCatalogTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user(username: "alice")
    @friend = create_user(username: "bob")
    sign_in @user
  end

  test "following a user creates a friendship" do
    assert_difference -> { Friendship.count } => 1 do
      post friendships_url, params: { receiver_username: "bob" }
    end
    assert_redirected_to user_path(@user)
    assert_equal @friend, Friendship.last.receiver
  end

  test "unfollowing removes the friendship" do
    friendship = Friendship.create!(asker: @user, receiver: @friend)

    assert_difference -> { Friendship.count } => -1 do
      delete friendship_url(friendship), params: { receiver_username: "bob" }
    end
    assert_redirected_to user_path(@user)
  end
  test "searching for friends returns the matching people as a list" do
    get user_url(@user, query: "bob"), headers: { "Accept" => "text/plain" }

    assert_response :success
    assert_select "p.friend-username", text: "bob"
    assert_select "form[action='#{friendships_path(receiver_username: "bob")}'] button", text: "Seguir"
  end

  test "the friend list never shows email addresses, nor matches on them" do
    @friend.update_columns(email: "segredo@example.com")

    get user_url(@user, query: "bob"), headers: { "Accept" => "text/plain" }
    assert_not_includes response.body, "segredo@example.com"

    get user_url(@user, query: "segredo"), headers: { "Accept" => "text/plain" }
    assert_empty response.body.strip
  end

  test "someone else's address shows nothing of theirs: it goes back to the logged in person's own page" do
    get user_url(@friend)

    assert_redirected_to user_url(@user)
  end

  test "an old numeric address goes to the username address, keeping the search" do
    get "/users/#{@user.id}", params: { query: "bob" }

    assert_redirected_to user_url(@user, query: "bob")
  end

  test "searching for someone who does not exist returns an empty list" do
    get user_url(@user, query: "zzzxqy"), headers: { "Accept" => "text/plain" }

    assert_response :success
    assert_empty response.body.strip
  end

  test "following shows a message in Portuguese" do
    post friendships_url(receiver_username: "bob")

    assert_equal "Você agora segue essa pessoa.", flash[:notice]
  end
end
