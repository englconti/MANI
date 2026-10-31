require "csv"

# Brings the questions and "Você sabia?" texts of an existing database in line
# with the starter CSVs in db/data, so content fixes reach people who already
# have data. Rows are matched by position: the n-th CSV question of a lesson is
# the n-th question of that lesson in the database. When the counts differ the
# lesson is skipped, so a database with different content is never overwritten.
module ContentSync
  # The CSV "level" is a label ("fácil") but the column is an integer, so it is not synced
  QUESTION_FIELDS = %w[question_type statement a b c d img_url correct_answer].freeze
  INFORMATION_FIELDS = %w[text img_url source].freeze

  module_function

  # Returns how many records changed
  def call(root: Rails.root, log: ->(message) {})
    changed = sync_questions(root.join("db/data/Mani - questions_starter.csv"), log)
    changed + sync_informations(root.join("db/data/Mani - informations_starter.csv"), log)
  end

  def sync_questions(path, log)
    return 0 unless File.exist?(path)

    changed = 0
    CSV.foreach(path, headers: true).group_by { |row| row["lesson_title"] }.each do |title, rows|
      lesson = Lesson.find_by(title: title)
      stored = lesson ? lesson.questions.to_a : []
      unless stored.size == rows.size
        log.call("skipping #{title}: #{stored.size} questions in the database, #{rows.size} in the CSV")
        next
      end

      stored.zip(rows).each do |question, row|
        changed += 1 if update_if_needed(question, row, QUESTION_FIELDS)
      end
    end
    changed
  end

  def sync_informations(path, log)
    return 0 unless File.exist?(path)

    rows = CSV.foreach(path, headers: true).to_a
    stored = Information.order(:id).to_a
    unless stored.size == rows.size
      log.call("skipping informations: #{stored.size} in the database, #{rows.size} in the CSV")
      return 0
    end

    stored.zip(rows).count { |information, row| update_if_needed(information, row, INFORMATION_FIELDS) }
  end

  def update_if_needed(record, row, fields)
    attributes = fields.to_h { |field| [field, row[field]] }
    return false if attributes.all? { |field, value| record[field].to_s == value.to_s }

    record.update_columns(attributes)
    true
  end
end
