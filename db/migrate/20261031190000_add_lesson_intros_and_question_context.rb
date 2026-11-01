require Rails.root.join("lib/content_sync")

# Each lesson opens with a short introduction (title, text and a mascot picture); a question
# can also carry a reminder shown above it. The texts live in the CSVs.
class AddLessonIntrosAndQuestionContext < ActiveRecord::Migration[8.1]
  def up
    add_column :lessons, :intro_title, :string
    add_column :lessons, :intro_text, :text
    add_column :lessons, :intro_image, :string
    add_column :questions, :context, :text
    Lesson.reset_column_information
    Question.reset_column_information

    changed = ContentSync.call(log: ->(message) { say(message) })
    say "#{changed} records created or updated"
  end

  def down
    remove_column :questions, :context
    remove_column :lessons, :intro_image
    remove_column :lessons, :intro_text
    remove_column :lessons, :intro_title
  end
end
