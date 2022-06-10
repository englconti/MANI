class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :answers

  after_create :populate_answers

  def populate_answers
    num_of_questions = Question.count
    i = 1
    num_of_questions.times do
      self.answers << Answer.new(question: Question.find(i), user: self, is_correct: false)
      i += 1
    end
  end

end
