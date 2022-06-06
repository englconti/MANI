class AddColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :score, :integer, default: 0
    add_column :users, :username, :string, null: false
    add_column :users, :birthday, :datetime, null: false
    add_column :users, :lives, :integer, default: 5
  end
end
