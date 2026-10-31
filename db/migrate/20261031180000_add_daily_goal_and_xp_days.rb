# The daily goal (in XP) and the XP earned each day, which feed the goal bar and the
# weekly ranking among friends.
class AddDailyGoalAndXpDays < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :daily_goal, :integer, null: false, default: 20

    create_table :xp_days do |t|
      t.references :user, null: false, foreign_key: true
      t.date :day, null: false
      t.integer :amount, null: false, default: 0
      t.timestamps
    end
    add_index :xp_days, %i[user_id day], unique: true
    add_index :xp_days, :day
  end
end
