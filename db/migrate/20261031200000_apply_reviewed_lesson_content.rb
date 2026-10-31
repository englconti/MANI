require Rails.root.join("lib/content_sync")

# Reviewed lessons: corrected and rewritten questions, new ones, reminders and an
# introduction for each lesson. Every lesson changed its number of questions, so the
# questions are rebuilt; answers to questions whose text stayed the same are kept, and
# so are the completions (XP, stars and the lessons already unlocked).
class ApplyReviewedLessonContent < ActiveRecord::Migration[8.1]
  def up
    changed = ContentSync.call(log: ->(message) { say(message) }, replace_questions: true)
    say "#{changed} records created or updated"
  end

  def down
    # The previous texts are in the git history of db/data
  end
end
