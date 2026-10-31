# Lessons used to unlock one after another. Now level 1 lessons are open from the
# start and a level 2 lesson only needs the level 1 lesson on the same subject
# ("Finanças Pessoais II" needs "Finanças Pessoais I").
class AddLevelAndPrerequisiteToLessons < ActiveRecord::Migration[8.1]
  def up
    add_column :lessons, :level, :integer, null: false, default: 1
    add_reference :lessons, :prerequisite, foreign_key: { to_table: :lessons }, null: true

    rows = select_all("SELECT id, title, position FROM lessons ORDER BY position, id").to_a
    level_two, level_one = rows.partition { |row| row["title"].to_s.strip.end_with?(" II") }
    one_by_subject = level_one.to_h { |row| [row["title"].to_s.strip.delete_suffix(" I"), row["id"]] }

    level_two.each do |row|
      subject = row["title"].to_s.strip.delete_suffix(" II")
      prerequisite_id = one_by_subject[subject]
      execute "UPDATE lessons SET level = 2, prerequisite_id = #{prerequisite_id ? prerequisite_id.to_i : 'NULL'} WHERE id = #{row['id'].to_i}"
    end

    # Trail order: every level 1 lesson first, then the level 2 lessons in the same subject order
    ordered = level_one + level_two.sort_by { |row| level_one.index { |one| one["id"] == one_by_subject[row["title"].to_s.strip.delete_suffix(" II")] } || level_one.size }
    ordered.each_with_index do |row, index|
      execute "UPDATE lessons SET position = #{index + 1} WHERE id = #{row['id'].to_i}"
    end
  end

  def down
    remove_reference :lessons, :prerequisite, foreign_key: { to_table: :lessons }
    remove_column :lessons, :level
  end
end
