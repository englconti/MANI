class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.text :definition
      t.text :kind
      t.text :howToInvest

      t.timestamps
    end
  end
end
