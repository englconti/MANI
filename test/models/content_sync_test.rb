require "test_helper"
require "tmpdir"
require Rails.root.join("lib/content_sync")

class ContentSyncTest < ActiveSupport::TestCase
  HEADER = "lesson_title,question_type,level,statement,a,b,c,d,img_url,correct_answer\n".freeze

  def write_csv(dir, rows)
    FileUtils.mkdir_p(File.join(dir, "db/data"))
    File.write(File.join(dir, "db/data/Mani - questions_starter.csv"), HEADER + rows.join("\n") + "\n")
  end

  test "the starter CSVs have no look-alike letters from other alphabets" do
    Dir[Rails.root.join("db/data/*.csv")].each do |path|
      content = File.read(path, encoding: "UTF-8")
      assert_no_match(/[Ѐ-ӿ]/, content, "#{File.basename(path)} has Cyrillic letters")
    end
  end

  test "updates stored questions from the CSV, matching by position in the lesson" do
    lesson = create_lesson(title: "Aula Sync", count: 2)
    Dir.mktmpdir do |dir|
      write_csv(dir, ["Aula Sync,abcd,fácil,Pergunta nova 1,a1,b1,c1,d1,,B",
                      "Aula Sync,abcd,fácil,Pergunta nova 2,a2,b2,c2,d2,,C"])

      changed = ContentSync.call(root: Pathname.new(dir))

      assert_equal 2, changed
    end
    first, second = lesson.questions.reload
    assert_equal "Pergunta nova 1", first.statement
    assert_equal "B", first.correct_answer
    assert_equal "c2", second.c
  end

  test "is a no-op when the content already matches" do
    create_lesson(title: "Aula Sync", count: 1)
    Dir.mktmpdir do |dir|
      write_csv(dir, ["Aula Sync,abcd,fácil,Question 0,a,b,c,d,,a"])
      Question.where(lesson: Lesson.find_by(title: "Aula Sync")).update_all(statement: "Question 0")

      assert_equal 0, ContentSync.call(root: Pathname.new(dir))
    end
  end

  test "skips a lesson whose question count differs from the CSV" do
    lesson = create_lesson(title: "Aula Sync", count: 2)
    messages = []
    Dir.mktmpdir do |dir|
      write_csv(dir, ["Aula Sync,abcd,fácil,Só uma,a,b,c,d,,A"])

      changed = ContentSync.call(root: Pathname.new(dir), log: ->(message) { messages << message })

      assert_equal 0, changed
    end
    assert_not_includes lesson.questions.reload.map(&:statement), "Só uma"
    assert_match(/skipping Aula Sync/, messages.first)
  end
  test "every row of the questions CSV has as many columns as the header" do
    rows = CSV.read(Rails.root.join("db/data/Mani - questions_starter.csv"), headers: true)

    rows.each_with_index do |row, index|
      assert_equal rows.headers.size, row.fields.size, "line #{index + 2} (#{row['statement'].to_s[0, 40]}) has the wrong number of columns"
    end
  end

  test "multiple choice rows have four options and a letter as the answer" do
    rows = CSV.read(Rails.root.join("db/data/Mani - questions_starter.csv"), headers: true).select { |row| row["question_type"] == "abcd" }

    rows.each do |row|
      assert_equal 4, %w[a b c d].count { |option| row[option].to_s.strip != "" }, "#{row['statement'][0, 40]} needs four options"
      assert_includes %w[A B C D], row["correct_answer"], "#{row['statement'][0, 40]} needs a letter answer"
    end
  end

  test "the lessons CSV is consistent with the questions CSV" do
    lessons = CSV.read(Rails.root.join("db/data/Mani - lessons_starter.csv"), headers: true)
    questions = CSV.read(Rails.root.join("db/data/Mani - questions_starter.csv"), headers: true)
    titles = lessons.map { |lesson| lesson["title"] }

    assert_equal titles.uniq, titles, "lesson titles must be unique"
    assert_empty questions.map { |question| question["lesson_title"] }.uniq - titles, "questions of lessons that do not exist"
    titles.each do |title|
      count = questions.count { |question| question["lesson_title"] == title }
      assert_operator count, :>=, 5, "#{title} has only #{count} questions"
    end
  end

  test "each level is one more than the level of its prerequisite" do
    lessons = CSV.read(Rails.root.join("db/data/Mani - lessons_starter.csv"), headers: true)
    levels = lessons.to_h { |lesson| [lesson["title"], lesson["level"].to_i] }

    lessons.each do |lesson|
      if lesson["prerequisite"].to_s.empty?
        assert_equal 1, lesson["level"].to_i, "#{lesson['title']} has no prerequisite so it must be level 1"
      else
        assert_equal levels.fetch(lesson["prerequisite"]) + 1, lesson["level"].to_i, "#{lesson['title']} has a wrong level"
      end
    end
  end

  test "a fresh database gets lessons, questions and informations from the CSVs" do
    Question.delete_all
    Lesson.update_all(prerequisite_id: nil)
    Lesson.delete_all
    Information.delete_all

    changed = ContentSync.call

    assert_equal 11, Lesson.count
    assert_equal 101, Question.count
    assert_operator Information.count, :>=, 5
    assert_operator changed, :>, 90
    assert_equal "Orçamento Pessoal", Lesson.find_by!(title: "Dívidas e Cartão de Crédito").prerequisite.title
    assert_equal "Finanças Pessoais", Lesson.find_by!(title: "Reserva de Emergência").track
    assert_equal [1, 2, 3], Lesson.where(track: "Finanças Pessoais").order(:position).pluck(:level)
  end

  test "running the sync twice changes nothing the second time" do
    Question.delete_all
    Lesson.update_all(prerequisite_id: nil)
    Lesson.delete_all
    Information.delete_all
    ContentSync.call

    assert_equal 0, ContentSync.call
  end
  test "the sync carries the lesson introductions and the question reminders" do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "db/data"))
      File.write(File.join(dir, "db/data/Mani - lessons_starter.csv"),
                 "title,description,level,prerequisite,track,intro_title,intro_text,intro_image\n" \
                 "Aula Intro,desc,1,,,Olá,\"Um.\n\nDois.\",golpes\n")
      File.write(File.join(dir, "db/data/Mani - questions_starter.csv"),
                 "lesson_title,question_type,level,statement,a,b,c,d,img_url,correct_answer,explanation,context\n" \
                 "Aula Intro,abcd,fácil,Pergunta?,a,b,c,d,,A,Porque sim.,Lembrete aqui\n")

      ContentSync.call(root: Pathname.new(dir))
    end

    lesson = Lesson.find_by!(title: "Aula Intro")
    assert_equal "Olá", lesson.intro_title
    assert_equal %w[Um. Dois.], lesson.intro_paragraphs
    assert_equal "golpes", lesson.intro_image
    assert_equal "Lembrete aqui", lesson.questions.first.context
  end

  test "every lesson has an introduction and no reminder points at a missing question" do
    lessons = CSV.read(Rails.root.join("db/data/Mani - lessons_starter.csv"), headers: true)

    lessons.each do |lesson|
      assert_operator lesson["intro_text"].to_s.split.size, :>=, 30, "#{lesson['title']} needs an introduction"
      assert_operator lesson["intro_title"].to_s.size, :>, 3, "#{lesson['title']} needs an introduction title"
    end
  end

  test "multiple choice rows have different options" do
    rows = CSV.read(Rails.root.join("db/data/Mani - questions_starter.csv"), headers: true).select { |row| row["question_type"] == "abcd" }

    rows.each do |row|
      assert_equal 4, [row["a"], row["b"], row["c"], row["d"]].uniq.size, "#{row['statement'][0, 40]} repeats an option"
    end
  end

  test "rebuilding a lesson keeps the answers of questions that did not change" do
    lesson = create_lesson(title: "Aula Sync", count: 0)
    kept = Question.create!(lesson: lesson, question_type: "abcd", statement: "Fica?", a: "a", b: "b", c: "c", d: "d", correct_answer: "A")
    gone = Question.create!(lesson: lesson, question_type: "abcd", statement: "Sai?", a: "a", b: "b", c: "c", d: "d", correct_answer: "A")
    user = create_user
    user.answers.where(question_id: kept.id).update_all(is_correct: true)
    assert_equal 2, user.answers.where(question_id: [kept.id, gone.id]).count

    Dir.mktmpdir do |dir|
      write_csv(dir, ["Aula Sync,abcd,fácil,Fica?,a,b,c,d,,A,Explicação",
                      "Aula Sync,abcd,fácil,Nova 1,a,b,c,d,,B,",
                      "Aula Sync,abcd,fácil,Nova 2,a,b,c,d,,C,"])

      changed = ContentSync.call(root: Pathname.new(dir), replace_questions: true)

      assert_equal 3, changed
    end

    statements = lesson.questions.reload.map(&:statement)
    assert_equal ["Fica?", "Nova 1", "Nova 2"], statements
    assert_not Question.exists?(gone.id)
    assert_equal 0, Answer.where(question_id: gone.id).count
    assert_equal [true], user.answers.where(question: lesson.questions.first).pluck(:is_correct)
    assert_equal 1, user.answers.where(question: lesson.questions).count
  end

  test "without the replace flag a lesson with another question count is left alone" do
    lesson = create_lesson(title: "Aula Sync", count: 2)

    Dir.mktmpdir do |dir|
      write_csv(dir, ["Aula Sync,abcd,fácil,Só uma,a,b,c,d,,A,"])

      assert_equal 0, ContentSync.call(root: Pathname.new(dir))
    end

    assert_equal 2, lesson.questions.count
  end
end
