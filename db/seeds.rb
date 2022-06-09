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
                  { title: "CDB", description: nil, definition: "renda fixa", kind: "corretora", how_to_invest: "se vira" }
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
                 { title: "Conceitos básicos I", description: "lerolero-blablabla", number_of_questions: 5 },
                 { title: "Conceitos básicos II", description: "lerolero-blablabla", number_of_questions: 5 },
                 { title: "Renda fixa", description: "lerolero-blablabla", number_of_questions: 5 },
                 { title: "Renda variável", description: "lerolero-blablabla", number_of_questions: 5 },
                 { title: "FII", description: "lerolero-blablabla", number_of_questions: 5 }
               ])
# ---------------------------------------------

# creating Questions --------------------------
# Questions Lesson 1
Question.create!([
    { lesson: Lesson.find(1), question_type: "abcd", level: "muito facil", statement: "O que é dinheiro?", a: "Um Jogo", b: "Um meio de troca", c: "Um carro", d: "Um papel", img_url: "", correct_answer: "B" },
    { lesson: Lesson.find(1), question_type: "abcd", level: "muito facil", statement: "Por que usamos dinheiro?", a: "Para facilitar a troca de produtos e servicos entre pessoas", b: "Para podermos criar empresas", c: "Para nos comunicarmos", d: "Para se alimentar", img_url: "", correct_answer: "A" },
    { lesson: Lesson.find(1), question_type: "abcd", level: "medio", statement: "Antes de termos dinheiro, como trocávamos itens ou serviços?", a: "Por porquinhos", b: "Não havia troca", c: "Através de orações", d: "Usávamos algum outro meio de troca (ex: conchas) ou trocávamos um item por outro.", img_url: "", correct_answer: "D" },
    { lesson: Lesson.find(1), question_type: "abcd", level: "medio", statement: "O que é escassez?", a: "Falta de comida", b: "Ter em pouca quantidade podendo faltar ou acabar", c: "Falta de água", d: "Excesso de dinheiro", img_url: "", correct_answer: "B" },
    { lesson: Lesson.find(1), question_type: "abcd", level: "dificil", statement: "O que escassez tem a ver com economia ou financas?", a: "Nada", b: "Tudo, pois basicamente, quanto mais escasso, maior será o valor atribuído a algo", c: "Falta de água pode desequilibrar o orcamento pessoal", d: "Sem lama o porquinho não vive", img_url: "", correct_answer: "B" }
  ])
# -----------------
# Questions Lesson 2
Question.create!([
    { lesson: Lesson.find(2), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
    { lesson: Lesson.find(2), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
    { lesson: Lesson.find(2), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
    { lesson: Lesson.find(2), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
    { lesson: Lesson.find(2), question_type: "abcd", level: "dificil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" }
  ])
# -----------------
# Questions Lesson 3
Question.create!([
  { lesson: Lesson.find(3), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(3), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(3), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(3), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(3), question_type: "abcd", level: "dificil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" }
])
# -----------------
# Questions Lesson 4
Question.create!([
  { lesson: Lesson.find(4), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(4), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(4), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(4), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(4), question_type: "abcd", level: "dificil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" }
])
# -----------------
# Questions Lesson 5
Question.create!([
  { lesson: Lesson.find(5), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(5), question_type: "abcd", level: "facil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(5), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(5), question_type: "abcd", level: "medio", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" },
  { lesson: Lesson.find(5), question_type: "abcd", level: "dificil", statement: "Alguma pergunta sobre finanças", a: "alternativa A", b: "alternativa B", c: "alternativa C", d: "alternativa D", img_url: "", correct_answer: "C" }
])
# -----------------
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
# Lesson 3: Question 11 to 15
Answer.create!([
                 { user: chosen_user, question: Question.find(11), is_correct: false },
                 { user: chosen_user, question: Question.find(12), is_correct: false },
                 { user: chosen_user, question: Question.find(13), is_correct: false },
                 { user: chosen_user, question: Question.find(14), is_correct: false },
                 { user: chosen_user, question: Question.find(15), is_correct: false }
               ])
# Lesson 4: Question 16 to 20
Answer.create!([
                 { user: chosen_user, question: Question.find(16), is_correct: false },
                 { user: chosen_user, question: Question.find(17), is_correct: false },
                 { user: chosen_user, question: Question.find(18), is_correct: false },
                 { user: chosen_user, question: Question.find(19), is_correct: false },
                 { user: chosen_user, question: Question.find(20), is_correct: false }
               ])
# Lesson 5: Question 21 to 25
Answer.create!([
                 { user: chosen_user, question: Question.find(21), is_correct: true },
                 { user: chosen_user, question: Question.find(22), is_correct: true },
                 { user: chosen_user, question: Question.find(23), is_correct: false },
                 { user: chosen_user, question: Question.find(24), is_correct: false },
                 { user: chosen_user, question: Question.find(25), is_correct: false }
               ])
# ---------------------------------------------
