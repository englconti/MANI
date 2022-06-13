require "csv"

# Creating Products ------------------------------------------------
puts "-=-=-=-=- CREATING PRODUCTS -=-=-=-=-"
products_path = "db/data/products_starter.csv"
CSV.foreach(products_path, headers: :first_row) do |row|
  if Product.find_by(title: row['title']).nil?
    Product.create!(title: row['title'],
                    description: row['description'],
                    definition: row['definition'],
                    kind: row['kind'],
                    how_to_invest: row['how_to_invest'])
    puts "Product created: #{Product.last.title}"
  end
end
# -------------------------------------------------------------------

# Creating Lessons -------------------------------------------------
puts "-=-=-=-=- CREATING LESSONS -=-=-=-=-"
lessons_path = "db/data/lessons_starter.csv"
CSV.foreach(lessons_path, headers: :first_row) do |row|
  if Lesson.find_by(title: row['title']).nil?
    Lesson.create!(title: row['title'], description: row['description'])
    puts "Lesson created: #{Lesson.last.title}"
  end
end
# ------------------------------------------------------------------

# Creating Questions -----------------------------------------------
puts "-=-=-=-=- CREATING QUESTIONS -=-=-=-=-"
questions_path = "db/data/questions_starter.csv"
# questions_path = "#{__FILE__}/../db/data/questions_starter.csv"
skipper = true
CSV.foreach(questions_path, headers: :first_row) do |row|
  if skipper
    # uncomment line bellow when all questions have different parameters
    # if Question.where(lesson: Lesson.find_by(title: row['lesson_title']), statement: row['statement'], a: row['a'])[0].nil?
    Question.create!(lesson: Lesson.find_by(title: row['lesson_title']),
                     question_type: row['question_type'],
                     level: row['level'],
                     statement: row['statement'],
                     a: row['a'],
                     b: row['b'],
                     c: row['c'],
                     d: row['d'],
                     img_url: row['img_url'],
                     correct_answer: row['correct_answer'])
    puts "Question created: #{Question.last.statement}"
  end
end
# ------------------------------------------------------------------
