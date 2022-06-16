class CreateInformation < ActiveRecord::Migration[6.1]
  def change
    create_table :information do |t|
      t.string :text
      t.string :img_url
      t.string :source

      t.timestamps
    end
  end
end
