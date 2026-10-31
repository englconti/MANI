# XP earned by a user on one day. The sum of the days of a week is the weekly ranking
# score; today's row is the progress of the daily goal.
class XpDay < ApplicationRecord
  belongs_to :user

  validates :day, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def self.credit!(user, amount, day: Time.zone.today)
    return if amount <= 0

    create_or_find_by!(user: user, day: day).increment!(:amount, amount)
  end

  # { user_id => XP earned from Monday of today's week until today }
  def self.week_totals(user_ids, today: Time.zone.today)
    where(user_id: user_ids, day: today.beginning_of_week..today).group(:user_id).sum(:amount)
  end
end
