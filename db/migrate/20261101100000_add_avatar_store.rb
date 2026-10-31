# The Mani Store: the avatar a person uses and the avatars they bought with their M$.
class AddAvatarStore < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :avatar_key, :string, null: false, default: "mani"

    create_table :avatar_purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.string :avatar_key, null: false
      t.integer :price, null: false, default: 0
      t.timestamps
    end
    add_index :avatar_purchases, %i[user_id avatar_key], unique: true
  end
end
