# The trail of lessons shown on the profile. Lessons unlock in order: finishing a
# lesson (reaching its summary) unlocks the next one; the first lesson not yet
# finished is the "current" one.
class LessonMap
  Node = Struct.new(:lesson, :state, :correct, :total, keyword_init: true) do
    def completed? = state == :completed
    def current? = state == :current
    def locked? = state == :locked

    def percent
      total.zero? ? 0 : (correct * 100.0 / total).round
    end

    # 0 to 3 stars from the score of the lesson
    def stars
      return 0 unless completed?

      case percent
      when 100 then 3
      when 60..99 then 2
      else 1
      end
    end
  end

  def initialize(user)
    @user = user
  end

  def nodes
    @nodes ||= build_nodes
  end

  def unlocked?(lesson)
    node = nodes.find { |candidate| candidate.lesson.id == lesson.id }
    node.present? && !node.locked?
  end

  def current
    nodes.find(&:current?)
  end

  private

  def build_nodes
    totals = Question.group(:lesson_id).count
    corrects = @user.answers.where(is_correct: true).joins(:question)
                    .group("questions.lesson_id").count
    finished_ids = @user.lesson_completions.pluck(:lesson_id).to_set
    current_taken = false

    Lesson.ordered.where(id: totals.keys).map do |lesson|
      state = if finished_ids.include?(lesson.id)
                :completed
              elsif !current_taken
                current_taken = true
                :current
              else
                :locked
              end
      Node.new(lesson: lesson, state: state, correct: corrects.fetch(lesson.id, 0),
               total: totals.fetch(lesson.id))
    end
  end
end
