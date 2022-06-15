class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :answers

  after_create :populate_answers

  # for Friendships ------------------
  has_many :friendships_as_asker, class_name: "Friendship", foreign_key: :asker_id
  has_many :friendships_as_receiver, class_name: "Friendship", foreign_key: :receiver_id
  # ----------------------------------

  # for searching friends ------------
  include PgSearch::Model
  pg_search_scope :search_by_username_and_email,
                  against: %i[username email],
                  using: {
                    tsearch: { prefix: true } # <-- now `superman batm` will return something!
                  }
  # ----------------------------------


  def populate_answers
    num_of_questions = Question.count
    i = 1
    num_of_questions.times do
      self.answers << Answer.new(question: Question.find(i), user: self, is_correct: false)
      i += 1
    end
  end

end
