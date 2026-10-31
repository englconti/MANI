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

  OPTION_LETTERS = %w[A B C D].freeze

  # Options that point at other options ("todas as outras estão corretas") only
  # make sense in the written order
  OPTION_REFERENCE = /(todas|nenhuma|ambas)\s+(as\s+)?(outras|anteriores|acima|alternativas|opções)|outras\s+opções/i

  # The text of the right answer without its letter: letters change when the options are shuffled
  def correct_answer_text
    option = correct_answer.to_s.downcase
    return correct_answer unless question_type == "abcd" && %w[a b c d].include?(option)

    public_send(option)
  end

  def shuffleable?
    OPTION_LETTERS.none? { |letter| public_send(letter.downcase).to_s.match?(OPTION_REFERENCE) }
  end

  # [original letter, text] in the order shown to this user. The order is shuffled but
  # stable for the same person and question, so a reload keeps the options where they were.
  def options_for(user)
    letters = OPTION_LETTERS.select { |letter| public_send(letter.downcase).present? }
    letters = letters.shuffle(random: Random.new(Zlib.crc32("#{user.id}-#{id}"))) if shuffleable?
    letters.map { |letter| [letter, public_send(letter.downcase)] }
  end

  private

  def normalize(text)
    text.to_s.squish
  end
end
