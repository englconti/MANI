# When a question was answered, so a lesson in progress can be resumed where it stopped
# (is_correct alone cannot tell a wrong answer from a question not yet answered).
class AddAnsweredAtToAnswers < ActiveRecord::Migration[8.1]
  def up
    add_column :answers, :answered_at, :datetime
    execute "UPDATE answers SET answered_at = updated_at WHERE is_correct = TRUE OR updated_at > created_at"
  end

  def down
    remove_column :answers, :answered_at
  end
end
