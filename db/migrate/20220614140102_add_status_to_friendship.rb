class AddStatusToFriendship < ActiveRecord::Migration[6.1]
  def change
    add_column :friendships, :status, :boolean, default: false
  end
end
