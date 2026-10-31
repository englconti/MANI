require "csv"


# Creating Informations ------------------------------------------------
puts "-=-=-=-=- CREATING INFORMATIONS -=-=-=-=-"
informations_path = "db/data/Mani - informations_starter.csv"
CSV.foreach(informations_path, headers: :first_row) do |row|
  Information.create!(text: row['text'],
                      img_url: row['img_url'],
                      source: row['source'])
  puts "Information created, source: #{Information.last.source}"
end
# -------------------------------------------------------------------

# Creating Lessons -------------------------------------------------
puts "-=-=-=-=- CREATING LESSONS -=-=-=-=-"
lessons_path = "db/data/Mani - lessons_starter.csv"
CSV.foreach(lessons_path, headers: :first_row).with_index(1) do |row, position|
  if Lesson.find_by(title: row['title']).nil?
    Lesson.create!(title: row['title'], description: row['description'], position: position)
    puts "Lesson created: #{Lesson.last.title}"
  end
end
# ------------------------------------------------------------------

# Creating Questions -----------------------------------------------
puts "-=-=-=-=- CREATING QUESTIONS -=-=-=-=-"
questions_path = "db/data/Mani - questions_starter.csv"
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

# Creating Users ------------------------------------------------
puts "-=-=-=-=- CREATING USERS -=-=-=-=-"
users_path = "db/data/Mani - users_starter.csv"
CSV.foreach(users_path, headers: :first_row) do |row|
  if User.find_by(username: row['username']).nil?
    User.create!(email: row['email'],
                 username: row['username'],
                 password: row['password'],
                 birthday: row['birthday'],
                 xp: row['xp'])
    puts "Username created, username: #{User.last.username}"
  end
end
# -------------------------------------------------------------------
