require "test_helper"

class QuestionOptionsTest < ActiveSupport::TestCase
  setup do
    @lesson = create_lesson(count: 0)
    @user = create_user
    @question = Question.create!(lesson: @lesson, question_type: "abcd", statement: "q", a: "um", b: "dois",
                                 c: "três", d: "quatro", correct_answer: "C")
  end

  test "correct_answer_text is the text of the right option, without its letter" do
    assert_equal "três", @question.correct_answer_text
  end

  test "correct_answer_text of a writing question is the expected words" do
    question = Question.new(question_type: "writing", correct_answer: "meio troca")

    assert_equal "meio troca", question.correct_answer_text
  end

  test "options_for keeps every option with its original letter" do
    options = @question.options_for(@user)

    assert_equal %w[A B C D], options.map(&:first).sort
    assert_equal "três", options.to_h["C"]
  end

  test "the order is stable for the same person and question" do
    assert_equal @question.options_for(@user), @question.options_for(@user)
  end

  test "different questions are not shuffled in the same way for everyone" do
    orders = 12.times.map do |i|
      question = Question.create!(lesson: @lesson, question_type: "abcd", statement: "q#{i}", a: "1", b: "2",
                                  c: "3", d: "4", correct_answer: "A")
      question.options_for(@user).map(&:first)
    end

    assert_operator orders.uniq.size, :>, 1
  end

  test "options that refer to the others keep the written order" do
    question = Question.create!(lesson: @lesson, question_type: "abcd", statement: "q", a: "um", b: "dois",
                                c: "três", d: "Todas as outras opções estão corretas", correct_answer: "D")

    assert_not question.shuffleable?
    assert_equal %w[A B C D], question.options_for(@user).map(&:first)
  end

  test "an empty option is left out" do
    question = Question.create!(lesson: @lesson, question_type: "abcd", statement: "q", a: "um", b: "dois",
                                c: "três", d: "", correct_answer: "A")

    assert_equal 3, question.options_for(@user).size
  end
end
