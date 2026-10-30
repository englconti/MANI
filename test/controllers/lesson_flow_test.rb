require "test_helper"

class LessonFlowTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = create_lesson(count: 3)
    @user = create_user
    sign_in @user
  end

  test "question page renders for an abcd question" do
    get question_url(@lesson.questions.first)

    assert_response :success
  end

  test "lesson summary renders and credits xp and manis for correct answers" do
    @user.answers.limit(2).update_all(is_correct: true)

    get lesson_url(@lesson)

    assert_response :success
    @user.reload
    assert_equal 10, @user.xp
    assert_equal 6, @user.manis
  end

  test "restarting a lesson refills lives and goes to its first question" do
    @user.update!(lives: 1)

    post restart_lesson_url(@lesson)

    assert_redirected_to question_path(@lesson.questions.first)
    assert_equal 5, @user.reload.lives
  end

  test "lesson summary does not touch lives" do
    @user.update!(lives: 2)

    get lesson_url(@lesson)

    assert_equal 2, @user.reload.lives
  end

  test "correct abcd answer is stored and keeps lives" do
    answer = @user.answers.first

    patch answer_url(answer), params: { answer_id: answer.id, answer: "a", question_type: "abcd" },
                              headers: { "Accept" => "application/json" }

    assert_response :success
    body = JSON.parse(response.body)
    assert body["correct"]
    assert_equal 5, body["lives"]
    assert answer.reload.is_correct
    assert_equal 5, @user.reload.lives
  end

  test "wrong answer response reveals the correct answer and the remaining lives" do
    answer = @user.answers.first

    patch answer_url(answer), params: { answer: "B" }, headers: { "Accept" => "application/json" }

    body = JSON.parse(response.body)
    assert_equal false, body["correct"]
    assert_equal 4, body["lives"]
    assert_equal "a: a", body["correct_answer_label"].downcase
  end

  test "question page does not leak the correct answer in the html" do
    question = @lesson.questions.first
    question.update!(correct_answer: "C", c: "resposta secreta xyz")

    get question_url(question)

    assert_response :success
    assert_select "input[type=radio][name=answer]", 4
    assert_select "#check-button[disabled]"
    assert_not_includes response.body, "resposta secreta xyz is correct" # sanity: never rendered as a verdict
    assert_no_match(/id="correct-answer"/, response.body)
    assert_no_match(/A resposta correta/, response.body)
  end

  test "question page exposes lesson progress and navigation to the client" do
    middle = @lesson.questions.second

    get question_url(middle)

    assert_select "[data-controller=lesson][data-lesson-index-value='1'][data-lesson-count-value='3']"
    assert_select "[data-lesson-next-url-value='#{question_path(@lesson.questions.third)}']"
    assert_select "[data-lesson-last-value='false']"
  end

  test "last question points to the lesson summary" do
    get question_url(@lesson.questions.last)

    assert_select "[data-lesson-last-value='true'][data-lesson-next-url-value='#{lesson_path(@lesson)}']"
  end

  test "writing question renders word buttons and strips unsafe markup" do
    lesson = create_lesson(count: 1, question_type: "writing")
    question = lesson.questions.first
    question.update!(a: "um dois tres",
                     statement: "Complete <div class='fill-ins'>_______</div><script>alert(1)</script>")
    user = create_user
    sign_in user

    get question_url(question)

    assert_response :success
    assert_select "button.wr-question-card", 3
    assert_select ".question-statement .fill-ins", 1
    assert_select ".question-statement script", 0
  end

  test "wrong abcd answer is stored as incorrect and costs one life" do
    answer = @user.answers.first

    patch answer_url(answer), params: { answer_id: answer.id, answer: "b", question_type: "abcd" }

    assert_not answer.reload.is_correct
    assert_equal 4, @user.reload.lives
  end

  # ---- Game rules enforced on the server (docs/spec/01-backend.md, B-1 to B-5) ----

  test "B-1: visiting the lesson summary twice must not credit xp twice" do
    @user.answers.limit(2).update_all(is_correct: true)

    2.times { get lesson_url(@lesson) }

    assert_equal 10, @user.reload.xp
    assert_equal 6, @user.manis
  end

  test "B-1: improving the score on a later visit only rewards the difference" do
    @user.answers.limit(1).update_all(is_correct: true)
    get lesson_url(@lesson)
    assert_equal 5, @user.reload.xp

    @user.answers.update_all(is_correct: true)
    get lesson_url(@lesson)
    get lesson_url(@lesson)

    assert_equal 15, @user.reload.xp
    assert_equal 9, @user.manis
  end

  test "B-2: a writing answer is graded by the server, not by the client's verdict" do
    lesson = create_lesson(count: 1, question_type: "writing")
    user = create_user
    sign_in user
    answer = user.answers.find_by(question: lesson.questions.first)

    patch answer_url(answer), params: { answer: "true" }
    assert_not answer.reload.is_correct
    assert_equal 4, user.reload.lives

    patch answer_url(answer), params: { answer: " palavra " }
    assert answer.reload.is_correct
    assert_equal 4, user.reload.lives
  end

  test "B-3: a user cannot change another user's answer" do
    other = create_user
    answer = other.answers.first

    patch answer_url(answer), params: { answer: "a" }

    assert_response :not_found
    assert_not answer.reload.is_correct
  end

  test "B-4: lives never go below zero" do
    @user.update!(lives: 0)
    answer = @user.answers.first

    patch answer_url(answer), params: { answer: "b" }

    assert_equal 0, @user.reload.lives
  end

  test "B-5: a question created after sign up still gets an answer row" do
    late = Question.create!(lesson: @lesson, question_type: "abcd", statement: "late",
                            a: "a", b: "b", c: "c", d: "d", correct_answer: "a")

    assert_difference -> { @user.answers.count } => 1 do
      get question_url(late)
    end
    assert_response :success
  end
end
