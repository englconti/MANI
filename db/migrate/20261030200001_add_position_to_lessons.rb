class AddPositionToLessons < ActiveRecord::Migration[6.1]
  def up
    add_column :lessons, :position, :integer
    # Keep today's order: lessons were shown by id
    execute "UPDATE lessons SET position = id"
    change_column_null :lessons, :position, false
    add_index :lessons, :position
  end

  def down
    remove_column :lessons, :position
  end
end
