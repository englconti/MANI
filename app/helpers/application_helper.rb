module ApplicationHelper
  # Was used to remove words typed into the instance of question inside the fields a, b, c or d. (decided to do it by hand)
  # def remove_words_from_statement(statement, question)
  #   remove_text = statement.gsub(question.a, "<div data-wr-choice-target='choice'>_______</div>") if question.a.present?
  #   remove_text = remove_text.gsub(question.b, "<div data-wr-choice-target='choice'>_______</div>") if question.b.present?
  #   remove_text = remove_text.gsub(question.c, "<div data-wr-choice-target='choice'>_______</div>") if question.c.present?
  #   remove_text = remove_text.gsub(question.d, "<div data-wr-choice-target='choice'>_______</div>") if question.d.present?
  #   remove_text
  # end
end
