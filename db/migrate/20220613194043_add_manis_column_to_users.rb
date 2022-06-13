class AddManisColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :manis, :integer, default: 0
  end
end
