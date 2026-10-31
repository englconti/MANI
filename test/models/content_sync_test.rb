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
end
