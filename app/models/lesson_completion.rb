class LessonCompletion < ApplicationRecord
  XP_PER_CORRECT_ANSWER = 5
  MANIS_PER_CORRECT_ANSWER = 3

  belongs_to :user
  belongs_to :lesson

  validates :lesson_id, uniqueness: { scope: :user_id }

  # Rewards only the improvement over the best score already rewarded for this
  # lesson, so reloading the summary (or redoing the lesson) can't farm XP.
  # Returns how many extra correct answers were rewarded.
  def self.record!(user:, lesson:, correct_count:)
    user.with_lock do
      completion = find_or_create_by!(user: user, lesson: lesson)
      gained = [correct_count - completion.correct_count, 0].max
      if gained.positive?
        completion.update!(correct_count: correct_count)
        user.update!(xp: user.xp + gained * XP_PER_CORRECT_ANSWER,
                     manis: user.manis + gained * MANIS_PER_CORRECT_ANSWER)
      end
      gained
    end
  end
end
