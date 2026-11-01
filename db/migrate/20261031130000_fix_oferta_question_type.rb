# "Oferta é:" has four options and a letter answer, but was seeded as a
# drag-the-words question, which rendered with no blanks to fill.
class FixOfertaQuestionType < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE questions SET question_type = 'abcd'
      WHERE question_type = 'writing' AND statement = 'Oferta é:'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE questions SET question_type = 'writing'
      WHERE question_type = 'abcd' AND statement = 'Oferta é:'
    SQL
  end
end
