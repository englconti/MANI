class FriendshipsController < ApplicationController
  before_action :set_friendship, only: :destroy

  def new
    @friendship = Friendship.new
  end

  def create
    receiver = User.find_by(username: params["receiver_username"])
    friendship = Friendship.new(asker: current_user, receiver: receiver)

    if friendship.save
      redirect_to user_path(current_user), notice: "Friend successfully followed!"
    else
      render :new # ????
    end
  end

  def index
  end

  def destroy
    if @friendship.destroy
      redirect_to user_path(current_user), notice: "Friend unfollowed!"
    end
  end

  def set_friendship
    @friendship = Friendship.where(asker: current_user, receiver: User.find_by(username: params["receiver_username"]))[0]
  end
end
