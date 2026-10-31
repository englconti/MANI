# The trail of lessons shown on the profile. A lesson is open unless it has a
# prerequisite the user has not finished yet (finishing = reaching its summary).
# Level 1 lessons have no prerequisite; a level 2 lesson needs its level 1 lesson.
class LessonMap
  Node = Struct.new(:lesson, :state, :correct, :total, :prerequisite, keyword_init: true) do
    def completed? = state == :completed
    def available? = state == :available
    def locked? = state == :locked

    # Finished with every answer right
    def perfect? = completed? && percent == 100

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

  # One track per subject: a lesson with no prerequisite starts a track and the
  # lessons that require it follow, one behind the other.
  Track = Struct.new(:subject, :nodes, keyword_init: true)

  def tracks
    @tracks ||= begin
      by_prerequisite = nodes.group_by { |node| node.lesson.prerequisite_id }
      known_ids = nodes.map { |node| node.lesson.id }.to_set
      roots = nodes.select { |node| node.lesson.prerequisite_id.nil? || !known_ids.include?(node.lesson.prerequisite_id) }

      roots.map do |root|
        # Every lesson that hangs from the root, level by level, so none is ever left out
        chain = [root]
        chain.each { |node| chain.concat(by_prerequisite.fetch(node.lesson.id, [])) }
        Track.new(subject: root.lesson.track.presence || root.lesson.subject, nodes: chain)
      end
    end
  end

  def available_count
    nodes.count(&:available?)
  end

  def unlocked?(lesson)
    node = nodes.find { |candidate| candidate.lesson.id == lesson.id }
    node.present? && !node.locked?
  end

  # The recommended next lesson: the first lesson still to do among the open ones
  def current
    nodes.find(&:available?)
  end

  private

  def build_nodes
    totals = Question.group(:lesson_id).count
    corrects = @user.answers.where(is_correct: true).joins(:question)
                    .group("questions.lesson_id").count
    completions = LessonCompletion.where(user_id: @user.id).index_by(&:lesson_id)
    finished_ids = completions.keys.to_set

    lessons = Lesson.ordered.includes(:prerequisite).where(id: totals.keys)

    lessons.map do |lesson|
      state = if finished_ids.include?(lesson.id)
                :completed
              elsif lesson.prerequisite_id.nil? || finished_ids.include?(lesson.prerequisite_id)
                :available
              else
                :locked
              end
      # The best score of a finished lesson stays even if its answers were reset by a content update
      correct = [corrects.fetch(lesson.id, 0), completions[lesson.id]&.correct_count.to_i].max
      Node.new(lesson: lesson, state: state, correct: [correct, totals.fetch(lesson.id)].min,
               total: totals.fetch(lesson.id), prerequisite: lesson.prerequisite)
    end
  end
end
