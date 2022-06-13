class RenameScoreToXpInUsers < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :score, :xp
  end
end
