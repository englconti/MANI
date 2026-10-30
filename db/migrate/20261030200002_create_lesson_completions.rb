class CreateLessonCompletions < ActiveRecord::Migration[6.1]
  def change
    create_table :lesson_completions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      # Best number of correct answers already rewarded with XP/manis
      t.integer :correct_count, null: false, default: 0

      t.timestamps
    end
    add_index :lesson_completions, %i[user_id lesson_id], unique: true
  end
end
