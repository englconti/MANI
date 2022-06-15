class FriendshipsController < ApplicationController
  def new
    @friendship = Friendship.new
  end

  def create
    receiver = User.find_by(username: params["receiver_username"])
    friendship = Friendship.new(asker: current_user, receiver: receiver)

    if friendship.save
      redirect_to user_path(current_user), notice: "Friend successfully added"
    else
      render :new # ????
    end
  end

  def index
    # only for submitted friendships

    # make one for received friendships
  end

  def destroy
  end
end
