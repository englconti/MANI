class Lesson < ApplicationRecord
  has_many :questions

  validates :title, presence: true
  validates :description, presence: true
  validates :number_of_questions, presence: true
end
