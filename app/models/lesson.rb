class Lesson < ApplicationRecord
  has_many :questions, -> { order(:id) }

  has_many :answers, through: :questions
  has_many :lesson_completions

  # A lesson without a prerequisite is open from the start
  belongs_to :prerequisite, class_name: "Lesson", optional: true
  has_many :follow_ups, class_name: "Lesson", foreign_key: :prerequisite_id, inverse_of: :prerequisite,
                        dependent: :nullify

  validates :title, presence: true
  validates :description, presence: true
  validates :level, inclusion: { in: 1..3 }
  validate :prerequisite_is_another_lesson

  before_validation :set_default_position, on: :create

  scope :ordered, -> { order(:position, :id) }

  def intro?
    intro_text.present?
  end

  # The question to go back to when the user left this lesson halfway: the first one not
  # answered yet. Nil when nothing (or everything) was answered, so there is nothing to resume.
  def resume_question_for(user)
    questions_list = questions.to_a
    answered_ids = user.answers.where(question_id: questions_list.map(&:id)).where.not(answered_at: nil).pluck(:question_id).to_set
    return if answered_ids.empty?

    questions_list.find { |question| !answered_ids.include?(question.id) }
  end

  # Starts the lesson over for this user: every answer goes back to "not answered".
  # The best score (and the XP already earned) are kept in the lesson completion.
  def reset_answers_for(user)
    user.answers.where(question_id: question_ids).update_all(is_correct: false, answered_at: nil, updated_at: Time.current)
  end

  # The introduction as paragraphs (blank lines separate them)
  def intro_paragraphs
    intro_text.to_s.split(/\r?\n\s*\r?\n/).map(&:strip).reject(&:blank?)
  end

  # "Finanças Pessoais II" -> "Finanças Pessoais": the subject a lesson belongs to
  def subject
    title.sub(/\s+(I|II|III)\z/, "")
  end

  private

  # New lessons go to the end of the map unless a position is given
  def set_default_position
    self.position ||= (Lesson.maximum(:position) || 0) + 1
  end

  def prerequisite_is_another_lesson
    errors.add(:prerequisite, :invalid) if prerequisite_id.present? && prerequisite_id == id
  end
end
