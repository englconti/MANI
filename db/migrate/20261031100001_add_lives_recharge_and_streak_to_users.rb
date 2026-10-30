class AddLivesRechargeAndStreakToUsers < ActiveRecord::Migration[8.1]
  def change
    # When the oldest missing life started recharging (nil while the user has all lives)
    add_column :users, :lives_recharge_started_at, :datetime
    add_column :users, :streak_count, :integer, null: false, default: 0
    add_column :users, :last_study_on, :date
  end
end
