class Question < ApplicationRecord
  belongs_to :lesson
  has_many :answers

  validates :question_type, presence: true, inclusion: { in: %w[abcd writing link] }
  validates :statement, presence: true
  validates :correct_answer, presence: true

  # `submitted` is the chosen option (abcd) or the filled-in words (writing).
  def correct?(submitted)
    normalize(submitted) == normalize(correct_answer)
  end

  private

  def normalize(text)
    text.to_s.squish
  end
end
