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

  # What to show a user who got it wrong: "C: the option text" for abcd, the words for writing
  def correct_answer_label
    option = correct_answer.to_s.downcase
    return correct_answer unless question_type == "abcd" && %w[a b c d].include?(option)

    "#{correct_answer}: #{public_send(option)}"
  end

  private

  def normalize(text)
    text.to_s.squish
  end
end
