class Question < ApplicationRecord
  belongs_to :lesson
  has_many :answers

  validates :question_type, presence: true, inclusion: { in: %w[abcd writing link] }
  validates :statement, presence: true
  validates :correct_answer, presence: true
end
