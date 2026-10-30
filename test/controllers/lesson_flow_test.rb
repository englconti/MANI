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

    assert_response :no_content
    assert answer.reload.is_correct
    assert_equal 5, @user.reload.lives
  end

  test "wrong abcd answer is stored as incorrect and costs one life" do
    answer = @user.answers.first

    patch answer_url(answer), params: { answer_id: answer.id, answer: "b", question_type: "abcd" }

    assert_not answer.reload.is_correct
    assert_equal 4, @user.reload.lives
  end

  test "writing answer flag from the client is stored (known gap B-2)" do
    answer = @user.answers.first

    patch answer_url(answer), params: { answer_id: answer.id, answer: "true", question_type: "writing" }

    assert answer.reload.is_correct
  end

  # ---- Known defects from docs/spec/01-backend.md; remove `skip` when fixed in phase 2 ----

  test "B-1: visiting the lesson summary twice must not credit xp twice" do
    skip "B-1 pendente (fase 2)"
    @user.answers.limit(2).update_all(is_correct: true)

    2.times { get lesson_url(@lesson) }

    assert_equal 10, @user.reload.xp
  end

  test "B-3: a user cannot change another user's answer" do
    skip "B-3 pendente (fase 2)"
    other = create_user
    answer = other.answers.first

    patch answer_url(answer), params: { answer_id: answer.id, answer: "a", question_type: "abcd" }

    assert_not answer.reload.is_correct
  end

  test "B-4: lives never go below zero" do
    skip "B-4 pendente (fase 2)"
    @user.update!(lives: 0)
    answer = @user.answers.first

    patch answer_url(answer), params: { answer_id: answer.id, answer: "b", question_type: "abcd" }

    assert_operator @user.reload.lives, :>=, 0
  end
end
