class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question

  # Grades the submitted answer on the server (never trust the client's verdict),
  # stores the result and takes a life away on a wrong answer.
  def submit!(submitted)
    correct = question.correct?(submitted)
    transaction do
      update!(is_correct: correct, answered_at: Time.current)
      user.lose_life! unless correct
      user.register_study_day!
    end
    correct
  end
end
