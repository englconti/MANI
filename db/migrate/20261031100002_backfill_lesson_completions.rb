# The lesson map now unlocks lessons from lesson_completions, so users who already
# answered lessons before the table existed get a completion with their current score
# (their XP was already granted, so the stored best score is not rewarded again).
class BackfillLessonCompletions < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      INSERT INTO lesson_completions (user_id, lesson_id, correct_count, created_at, updated_at)
      SELECT answers.user_id, questions.lesson_id, COUNT(*), NOW(), NOW()
      FROM answers
      JOIN questions ON questions.id = answers.question_id
      WHERE answers.is_correct = TRUE
      GROUP BY answers.user_id, questions.lesson_id
      ON CONFLICT (user_id, lesson_id) DO NOTHING
    SQL
  end

  def down
    # Backfilled rows can't be told apart from real ones; leave them in place
  end
end
