# Daily study streak: consecutive days with at least one answered question.
module HasStreak
  extend ActiveSupport::Concern

  # Call whenever the user studies; counts at most once per day.
  def register_study_day!(today = Time.zone.today)
    return if last_study_on == today

    update!(streak_count: last_study_on == today - 1 ? streak_count + 1 : 1,
            last_study_on: today)
  end

  # The stored streak is stale once a whole day was skipped
  def current_streak(today = Time.zone.today)
    return 0 if last_study_on.nil? || last_study_on < today - 1

    streak_count
  end

  def studied_today?(today = Time.zone.today)
    last_study_on == today
  end
end
