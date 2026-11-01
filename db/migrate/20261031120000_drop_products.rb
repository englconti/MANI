class DropProducts < ActiveRecord::Migration[8.1]
  def change
    drop_table :products do |t|
      t.string :title
      t.text :description
      t.text :definition
      t.text :kind
      t.text :how_to_invest
      t.timestamps
    end
  end
end
