class Lesson < ApplicationRecord
  has_many :questions

  has_many :answers, through: :questions

  validates :title, presence: true
  validates :description, presence: true
end
