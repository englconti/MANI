class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include HasLives
  include HasStreak

  has_many :answers, dependent: :destroy
  has_many :xp_days, dependent: :destroy
  has_many :avatar_purchases, dependent: :destroy
  has_many :lesson_completions, dependent: :destroy

  validates :lives, numericality: { greater_than_or_equal_to: 0 }

  # The goal is chosen among a few steps: the label is what the person sees
  DAILY_GOALS = { 10 => "Leve", 20 => "Normal", 40 => "Forte" }.freeze
  validates :daily_goal, inclusion: { in: DAILY_GOALS.keys }
  validate :avatar_is_in_the_catalog

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

  # The avatar in use (the base one if the stored key is no longer in the catalog)
  def avatar
    Avatar.find(avatar_key) || Avatar.default
  end

  def owned_avatar_keys
    [Avatar.default.key] + avatar_purchases.pluck(:avatar_key)
  end

  def owns_avatar?(avatar)
    avatar.default? || avatar_purchases.exists?(avatar_key: avatar.key)
  end

  # Pays for an avatar with M$. The balance is checked and spent in one locked step, so two
  # clicks at once cannot spend the same M$ twice.
  def buy_avatar!(avatar)
    raise Avatar::Unknown, "avatar fora da loja" if avatar.default?

    with_lock do
      raise Avatar::AlreadyOwned if owns_avatar?(avatar)
      raise Avatar::NotEnoughManis.new(avatar.price - manis) if manis < avatar.price

      update!(manis: manis - avatar.price)
      avatar_purchases.create!(avatar_key: avatar.key, price: avatar.price)
    end
  end

  def use_avatar!(avatar)
    raise Avatar::NotOwned unless owns_avatar?(avatar)

    update!(avatar_key: avatar.key)
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

  def avatar_is_in_the_catalog
    errors.add(:avatar_key, :invalid) unless Avatar.keys.include?(avatar_key)
  end

  def populate_answers
    Question.find_each do |question|
      answers << Answer.new(question: question, user: self, is_correct: false)
    end
  end

end
