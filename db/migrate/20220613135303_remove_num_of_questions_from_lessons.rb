class RemoveNumOfQuestionsFromLessons < ActiveRecord::Migration[6.1]
  def change
    remove_column :lessons, :number_of_questions
  end
end
