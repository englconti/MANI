class Lesson < ApplicationRecord
  has_many :questions, -> { order(:id) }

  has_many :answers, through: :questions
  has_many :lesson_completions

  validates :title, presence: true
  validates :description, presence: true

  before_validation :set_default_position, on: :create

  scope :ordered, -> { order(:position, :id) }

  private

  # New lessons go to the end of the map unless a position is given
  def set_default_position
    self.position ||= (Lesson.maximum(:position) || 0) + 1
  end
end
