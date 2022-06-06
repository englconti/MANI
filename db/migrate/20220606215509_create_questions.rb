class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.string :question_type
      t.integer :level
      t.string :statement
      t.references :lesson, null: false, foreign_key: true
      t.string :a
      t.string :b
      t.string :c
      t.string :d
      t.string :img_url
      t.string :correct_answer

      t.timestamps
    end
  end
end
