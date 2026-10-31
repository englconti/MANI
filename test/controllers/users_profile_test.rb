require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  setup do
    Information.create!(text: "fato", img_url: "https://example.com/a.png", source: "https://example.com")
    @user = create_user
    sign_in @user
  end

  def add_questions(lesson)
    Question.create!(lesson: lesson, question_type: "abcd", statement: "q", a: "a", b: "b",
                     c: "c", d: "d", correct_answer: "a")
  end

  test "B-5: the trail lists lessons by position, whatever their ids are" do
    third = Lesson.create!(title: "Terceira", description: "d", position: 3)
    first = Lesson.create!(title: "Primeira", description: "d", position: 1)
    second = Lesson.create!(title: "Segunda", description: "d", position: 2)
    [first, second, third].each { |lesson| add_questions(lesson) }

    get user_url(@user)

    assert_response :success
    titles = css_select(".trail-title .visually-hidden").map(&:text)
    assert_equal %w[Primeira Segunda Terceira], titles
  end

  test "level 1 lessons are available and level 2 is locked until its prerequisite is done" do
    first = create_lesson(title: "Aula 1", count: 2)
    create_lesson(title: "Aula 2", count: 2)
    create_lesson(title: "Aula 1 B", count: 2, prerequisite: first)

    get user_url(@user)

    assert_select "li.trail-node.is-available", 2
    assert_select "li.trail-node.is-locked", 1
    assert_select "li.trail-node.is-available a[href='#{question_path(first.questions.first)}']"
    assert_select "li.trail-node.is-locked a", 0
    assert_select "li.trail-node.is-locked .trail-meta", text: /Aula 1 para liberar/
    assert_select "li.track", 2
    assert_select "li.track:first-child li.trail-node", 2
    assert_select ".trail-subtitle", text: /2 aulas abertas/
  end

  test "a finished lesson shows its score and unlocks the next one" do
    lesson = create_lesson(title: "Aula X", count: 3)
    create_lesson(title: "Aula Y", count: 1, prerequisite: lesson)
    user = create_user # created after the lessons so it has an answer per question
    sign_in user
    user.answers.where(question: lesson.questions.first(2)).update_all(is_correct: true)
    LessonCompletion.create!(user: user, lesson: lesson, correct_count: 2)

    get user_url(user)

    assert_select "li.trail-node.is-completed", 1
    assert_select "li.trail-node.is-available", 1
    assert_includes response.body, "2 / 3 acertos"
  end

  test "lessons without questions are not listed" do
    Lesson.create!(title: "Vazia", description: "d")

    get user_url(@user)

    assert_response :success
    assert_not_includes response.body, "Vazia"
  end

  test "new lessons go to the end of the map" do
    create_lesson
    last = create_lesson

    assert_equal last, Lesson.ordered.last
  end

  test "the header shows the streak and the lives" do
    @user.update!(streak_count: 4, last_study_on: Time.zone.today)

    get user_url(@user)

    assert_select ".status-chip.is-streak", /4/
    assert_select ".status-chip.is-lives", /5/
  end
  test "the page title names the trail" do
    get user_url(@user)

    assert_select "title", text: "Sua trilha · MANI"
  end
end
