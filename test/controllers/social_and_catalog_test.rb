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
end
