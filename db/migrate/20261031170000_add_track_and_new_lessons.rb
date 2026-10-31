require Rails.root.join("lib/content_sync")

# - lessons.track names the card of a trail when it differs from the subject
#   ("Finanças Pessoais" holds Orçamento, Dívidas e Reserva);
# - the questions that were about running a company leave "Finanças Pessoais"
#   and become "Gestão Empresarial", keeping everyone's progress;
# - the new personal finance and scams lessons are created from the CSVs.
class AddTrackAndNewLessons < ActiveRecord::Migration[8.1]
  RENAMES = { "Finanças Pessoais I" => "Gestão Empresarial I", "Finanças Pessoais II" => "Gestão Empresarial II" }.freeze

  def up
    add_column :lessons, :track, :string
    Lesson.reset_column_information

    RENAMES.each { |old_title, new_title| Lesson.where(title: old_title).update_all(title: new_title) }
    changed = ContentSync.call(log: ->(message) { say(message) })
    say "#{changed} records created or updated"
  end

  def down
    RENAMES.each { |old_title, new_title| Lesson.where(title: new_title).update_all(title: old_title) }
    remove_column :lessons, :track
  end
end
