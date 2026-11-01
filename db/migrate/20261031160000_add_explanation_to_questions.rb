require Rails.root.join("lib/content_sync")

# A short "why" shown after every answer. The texts live in the questions CSV.
class AddExplanationToQuestions < ActiveRecord::Migration[8.1]
  def up
    add_column :questions, :explanation, :text
    Question.reset_column_information
    changed = ContentSync.call(log: ->(message) { say(message) })
    say "#{changed} records updated"
  end

  def down
    remove_column :questions, :explanation
  end
end
