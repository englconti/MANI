require "csv"

# Keeps the database in line with the starter CSVs in db/data, for new and for
# existing installs:
# - lessons are created or updated by title (description, level, order, track and
#   prerequisite);
# - questions are matched by position: the n-th CSV question of a lesson is the n-th
#   question of that lesson in the database. A lesson with no questions gets all of
#   them; when the counts differ the lesson is skipped, so a database with different
#   content is never overwritten;
# - the "Você sabia?" texts work the same way, as one list.
module ContentSync
  # The CSV "level" is a label ("fácil") but the column is an integer; it is only
  # used when a question is created
  QUESTION_FIELDS = %w[question_type statement a b c d img_url correct_answer explanation context].freeze
  LESSON_INTRO_FIELDS = %w[intro_title intro_text intro_image].freeze
  INFORMATION_FIELDS = %w[text img_url source].freeze
  LEVELS = { "muito fácil" => 1, "fácil" => 2, "médio" => 3 }.freeze

  module_function

  # Returns how many records were created or changed
  # replace_questions: rebuild the questions of a lesson whose count differs from the CSV
  # (the answers to questions that kept their text are kept; the others are removed)
  def call(root: Rails.root, log: ->(message) {}, replace_questions: false)
    sync_lessons(root.join("db/data/Mani - lessons_starter.csv"), log) +
      sync_questions(root.join("db/data/Mani - questions_starter.csv"), log, replace: replace_questions) +
      sync_informations(root.join("db/data/Mani - informations_starter.csv"), log)
  end

  def sync_lessons(path, log)
    return 0 unless File.exist?(path)

    rows = CSV.foreach(path, headers: true).to_a
    changed = 0
    lessons = rows.each_with_index.to_h do |row, index|
      lesson = Lesson.find_or_initialize_by(title: row["title"])
      lesson.assign_attributes(description: row["description"], level: row["level"].to_i, position: index + 1)
      # Older installs reach this code from migrations that run before the column exists
      lesson.track = row["track"].presence if Lesson.column_names.include?("track")
      (LESSON_INTRO_FIELDS & Lesson.column_names).each { |field| lesson[field] = row[field].presence }
      log.call("lesson created: #{lesson.title}") if lesson.new_record?
      changed += 1 if lesson.new_record? || lesson.changed?
      lesson.save!
      [row["title"], lesson]
    end

    # Prerequisites need every lesson to exist first
    rows.each do |row|
      lesson = lessons.fetch(row["title"])
      prerequisite = row["prerequisite"].present? ? lessons[row["prerequisite"]] : nil
      next if lesson.prerequisite_id == prerequisite&.id

      lesson.update!(prerequisite: prerequisite)
      changed += 1
    end
    changed
  end

  def sync_questions(path, log, replace: false)
    return 0 unless File.exist?(path)

    changed = 0
    CSV.foreach(path, headers: true).group_by { |row| row["lesson_title"] }.each do |title, rows|
      lesson = Lesson.find_by(title: title)
      unless lesson
        log.call("skipping #{title}: there is no such lesson")
        next
      end

      stored = lesson.questions.to_a
      if stored.empty?
        rows.each { |row| create_question(lesson, row) }
        changed += rows.size
        log.call("#{rows.size} questions created in #{title}")
      elsif stored.size == rows.size
        stored.zip(rows).each { |question, row| changed += 1 if update_if_needed(question, row, QUESTION_FIELDS) }
      elsif replace
        rebuild_questions(lesson, stored, rows)
        changed += rows.size
        log.call("#{title}: questions rebuilt (#{stored.size} before, #{rows.size} now)")
      else
        log.call("skipping #{title}: #{stored.size} questions in the database, #{rows.size} in the CSV")
      end
    end
    changed
  end

  def sync_informations(path, log)
    return 0 unless File.exist?(path)

    rows = CSV.foreach(path, headers: true).to_a
    stored = Information.order(:id).to_a
    if stored.empty?
      rows.each { |row| Information.create!(INFORMATION_FIELDS.to_h { |field| [field, row[field]] }) }
      return rows.size
    end

    unless stored.size == rows.size
      log.call("skipping informations: #{stored.size} in the database, #{rows.size} in the CSV")
      return 0
    end

    stored.zip(rows).count { |information, row| update_if_needed(information, row, INFORMATION_FIELDS) }
  end

  # New questions first, then the answers of questions whose statement did not change move
  # to their new row, then the old questions and the answers left behind go away
  def rebuild_questions(lesson, stored, rows)
    old_by_statement = stored.index_by(&:statement)

    Question.transaction do
      rows.each do |row|
        question = create_question(lesson, row)
        old = old_by_statement[question.statement]
        Answer.where(question_id: old.id).update_all(question_id: question.id) if old
      end
      Answer.where(question_id: stored.map(&:id)).delete_all
      Question.where(id: stored.map(&:id)).delete_all
    end
  end

  def create_question(lesson, row)
    attributes = (QUESTION_FIELDS & Question.column_names).to_h { |field| [field, row[field]] }
    Question.create!(attributes.merge("lesson" => lesson, "level" => LEVELS[row["level"]]))
  end

  def update_if_needed(record, row, fields)
    attributes = (fields & record.class.column_names).to_h { |field| [field, row[field]] }
    return false if attributes.all? { |field, value| record[field].to_s == value.to_s }

    record.update_columns(attributes)
    true
  end
end
