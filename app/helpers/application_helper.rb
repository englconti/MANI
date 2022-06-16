module ApplicationHelper
  def remove_words_from_statement(statement, question)
    remove_text = statement.gsub(question.a, "<div data-wr-choice-target='choice'>_______</div>") if question.a.present?
    remove_text = remove_text.gsub(question.b, "<div data-wr-choice-target='choice'>_______</div>") if question.b.present?
    remove_text = remove_text.gsub(question.c, "<div data-wr-choice-target='choice'>_______</div>") if question.c.present?
    remove_text = remove_text.gsub(question.d, "<div data-wr-choice-target='choice'>_______</div>") if question.d.present?
    remove_text
  end
end
