require "test_helper"

class QuestionScreenTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = create_lesson(title: "Aula Um", count: 3)
    @lesson.update!(intro_image: "pig-coin")
    @user = create_user
    sign_in @user
  end

  test "the lives are one heart each, with the spent ones greyed out" do
    @user.update!(lives: 3, lives_recharge_started_at: Time.current)

    get question_url(@lesson.questions.first)

    assert_select ".hearts .heart", User::MAX_LIVES
    assert_select ".hearts .heart.is-lost", User::MAX_LIVES - 3
    assert_select ".hearts[role=img][aria-label='3 vidas']"
  end

  test "with every life there is no grey heart" do
    get question_url(@lesson.questions.first)

    assert_select ".hearts .heart", 5
    assert_select ".hearts .heart.is-lost", 0
  end

  test "the pig of the lesson asks the question inside a bubble" do
    question = @lesson.questions.first

    get question_url(question)

    assert_select ".question-ask .question-pig img[src*='pig-coin']"
    assert_select ".question-ask .question-bubble h1#question-statement", text: question.statement
    assert_select "fieldset.question-cards[aria-describedby=question-statement]"
  end

  test "the poses for a right and a wrong answer are ready on the page" do
    get question_url(@lesson.questions.first)

    assert_select "[data-lesson-cheer-image-value*='pig-cheering']"
    assert_select "[data-lesson-cry-image-value*='pig-crying']"
    assert_select "[data-lesson-target=pig]"
    assert_select "[data-lesson-target=heart]", 5
  end

  test "a writing question keeps its blanks inside the bubble" do
    lesson = create_lesson(count: 0)
    question = Question.create!(lesson: lesson, question_type: "writing", level: 1,
                                statement: "Um <div class='fill-ins'>_______</div> de troca.",
                                a: "meio fim troca", correct_answer: "meio")

    get question_url(question)

    assert_select ".question-bubble h1#question-statement .fill-ins"
    assert_select ".wr-question-cards button", 3
  end

  test "the reminder is plain text now, without a second picture" do
    question = @lesson.questions.second
    question.update!(context: "Lembre-se disto.")

    get question_url(question)

    assert_select "aside.question-context p", text: "Lembre-se disto."
    assert_select "aside.question-context img", 0
  end

  test "an unknown pose of the lesson falls back to the plain mascot in the bubble" do
    @lesson.update!(intro_image: nil)

    get question_url(@lesson.questions.first)

    assert_select ".question-pig img[src*='Mani-oficial']"
  end

  test "the footer keeps the sound toggle, the feedback and the action together" do
    get question_url(@lesson.questions.first)

    assert_select ".question-footer .sound-toggle"
    assert_select ".question-footer .answer-feedback"
    assert_select ".question-footer .right-buttons #check-button"
  end
end
