class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include HasLives
  include HasStreak

  has_many :answers, dependent: :destroy
  has_many :xp_days, dependent: :destroy
  has_many :lesson_completions, dependent: :destroy

  validates :lives, numericality: { greater_than_or_equal_to: 0 }

  # The goal is chosen among a few steps: the label is what the person sees
  DAILY_GOALS = { 10 => "Leve", 20 => "Normal", 40 => "Forte" }.freeze
  validates :daily_goal, inclusion: { in: DAILY_GOALS.keys }

  after_create :populate_answers

  # for Friendships ------------------
  has_many :friendships_as_asker, class_name: "Friendship", foreign_key: :asker_id, dependent: :destroy
  has_many :friendships_as_receiver, class_name: "Friendship", foreign_key: :receiver_id, dependent: :destroy
  # ----------------------------------

  # for searching friends ------------
  include PgSearch::Model
  pg_search_scope :search_by_username_and_email,
                  against: %i[username email],
                  using: {
                    tsearch: { prefix: true } # <-- now `superman batm` will return something!
                  }
  # ----------------------------------


  def level
    PlayerLevel.for(xp)
  end

  def xp_today(today = Time.zone.today)
    xp_days.find_by(day: today)&.amount.to_i
  end

  def daily_goal_reached?(today = Time.zone.today)
    xp_today(today) >= daily_goal
  end

  # Studied yesterday and not yet today: the streak ends tonight unless they study
  def streak_at_risk?(today = Time.zone.today)
    streak_count.positive? && last_study_on == today - 1
  end

  def completed_lesson?(lesson)
    lesson_completions.exists?(lesson: lesson)
  end

  def populate_answers
    Question.find_each do |question|
      answers << Answer.new(question: question, user: self, is_correct: false)
    end
  end

end
