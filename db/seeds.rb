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
lesson_rows = CSV.read(lessons_path, headers: :first_row)
lesson_rows.each.with_index(1) do |row, position|
  lesson = Lesson.find_or_initialize_by(title: row['title'])
  new_lesson = lesson.new_record?
  lesson.update!(description: row['description'], level: row['level'].to_i, position: position)
  puts "Lesson created: #{lesson.title}" if new_lesson
end
# Prerequisites need every lesson to exist first
lesson_rows.each do |row|
  next if row['prerequisite'].blank?

  Lesson.find_by!(title: row['title']).update!(prerequisite: Lesson.find_by!(title: row['prerequisite']))
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
                     correct_answer: row['correct_answer'],
                     explanation: row['explanation'])
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
