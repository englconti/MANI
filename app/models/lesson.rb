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
