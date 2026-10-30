# Lives: a wrong answer costs one; each missing life comes back after
# LIFE_RECHARGE_TIME, one at a time. The timer only runs while lives are missing.
module HasLives
  extend ActiveSupport::Concern

  MAX_LIVES = 5
  LIFE_RECHARGE_TIME = 20.minutes

  def lose_life!
    now = Time.current
    update!(lives: [lives - 1, 0].max,
            lives_recharge_started_at: lives_recharge_started_at || now)
  end

  # Gives back the lives earned by waiting. Safe to call on every request.
  def recharge_lives!(now = Time.current)
    return if lives >= MAX_LIVES

    started = lives_recharge_started_at
    return update!(lives_recharge_started_at: now) if started.nil?

    regained = ((now - started) / LIFE_RECHARGE_TIME).floor
    return if regained <= 0

    new_lives = [lives + regained, MAX_LIVES].min
    update!(lives: new_lives,
            lives_recharge_started_at: new_lives >= MAX_LIVES ? nil : started + regained * LIFE_RECHARGE_TIME)
  end

  # Moment the next life comes back, or nil when lives are full
  def next_life_at
    return if lives >= MAX_LIVES

    (lives_recharge_started_at || Time.current) + LIFE_RECHARGE_TIME
  end

  def out_of_lives?
    lives <= 0
  end
end
