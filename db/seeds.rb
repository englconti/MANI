# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Added by MANI Team ------------------------
# Database SEED for Mani -> Recommendation: drop your development DB before running this seed
# rails db:drop db:create db:migrate db:seed

# creating Products -------------------------
Product.create!([
                  { title: "LCI/LCA", description: nil, definition: nil, kind: nil, how_to_invest: nil },
                  { title: "CRI/CRA", description: nil, definition: nil, kind: nil, how_to_invest: nil },
                  { title: "Tesouro direto", description: nil, definition: nil, kind: nil, how_to_invest: nil },
                  { title: "Ações", description: nil, definition: nil, kind: nil, how_to_invest: nil },
                  { title: "FIIs", description: nil, definition: nil, kind: nil, how_to_invest: nil },
                  { title: "CDB", description: nil, definition: nil, kind: nil, how_to_invest: nil }
                ])
# --------------------------------------------


# creating Users -----------------------------
User.create!([
               { username: "leo", password: "mani1234", email: "leo@mani.com.br", birthday: "1990/12/12" },
               { username: "ale", password: "mani1234", email: "ale@mani.com.br", birthday: "1990/12/12" },
               { username: "gui", password: "mani1234", email: "gui@mani.com.br", birthday: "1990/12/12" },
               { username: "zepaulo", password: "mani1234", email: "zepaulo@mani.com.br", birthday: "1990/12/12" }
             ])
# ---------------------------------------------

# creating Lessons ----------------------------
Lesson.create!([
                 { title: "Teste introdutório", description: "lerolero-blablabla", number_of_questions: 5 },
                 { title: "Conceitos básicos", description: "lerolero-blablabla", number_of_questions: 5 },
                 { title: "Renda fixa", description: "lerolero-blablabla", number_of_questions: 5 },
                 { title: "Renda variável", description: "lerolero-blablabla", number_of_questions: 5 },
                 { title: "FII", description: "lerolero-blablabla", number_of_questions: 5 }
               ])
# ---------------------------------------------

# creating Questions --------------------------
i = Lesson.first.id
Lesson.count.times do
  Question.create!([
                    { lesson: Lesson.find(i), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "alternativa C" },
                    { lesson: Lesson.find(i), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "alternativa C" },
                    { lesson: Lesson.find(i), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "alternativa C" },
                    { lesson: Lesson.find(i), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "alternativa C" },
                    { lesson: Lesson.find(i), question_type: "abcd", level: "dificil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "alternativa C" }
                   ])
  i += 1
end
# ---------------------------------------------

# creating Answers -----------------------------
# If you want to check another user, change the number on find accordingly to the Users created.
chosen_user = User.find(1)
# Lesson 1: Question 1 to 5
Answer.create!([
                 { user: chosen_user, question: Question.find(1), is_correct: true },
                 { user: chosen_user, question: Question.find(2), is_correct: true },
                 { user: chosen_user, question: Question.find(3), is_correct: true },
                 { user: chosen_user, question: Question.find(4), is_correct: true },
                 { user: chosen_user, question: Question.find(5), is_correct: true }
               ])
# Lesson 2: Question 6 to 10
Answer.create!([
                 { user: chosen_user, question: Question.find(6), is_correct: true },
                 { user: chosen_user, question: Question.find(7), is_correct: true },
                 { user: chosen_user, question: Question.find(8), is_correct: true },
                 { user: chosen_user, question: Question.find(9), is_correct: true },
                 { user: chosen_user, question: Question.find(10), is_correct: false }
               ])
# Lesson 3.a: Question 11 to 15
Answer.create!([
                 { user: chosen_user, question: Question.find(11), is_correct: true },
                 { user: chosen_user, question: Question.find(12), is_correct: true },
                 { user: chosen_user, question: Question.find(13), is_correct: true },
                 { user: chosen_user, question: Question.find(14), is_correct: true },
                 { user: chosen_user, question: Question.find(15), is_correct: false }
               ])
# Lesson 3.b: Question 16 to 20
Answer.create!([
                 { user: chosen_user, question: Question.find(16), is_correct: true },
                 { user: chosen_user, question: Question.find(17), is_correct: true },
                 { user: chosen_user, question: Question.find(18), is_correct: true },
                 { user: chosen_user, question: Question.find(19), is_correct: true },
                 { user: chosen_user, question: Question.find(20), is_correct: true }
               ])
# Lesson 3.c: Question 21 to 25
Answer.create!([
                 { user: chosen_user, question: Question.find(21), is_correct: true },
                 { user: chosen_user, question: Question.find(22), is_correct: true },
                 { user: chosen_user, question: Question.find(23), is_correct: false },
                 { user: chosen_user, question: Question.find(24), is_correct: false },
                 { user: chosen_user, question: Question.find(25), is_correct: false }
               ])
# ---------------------------------------------
