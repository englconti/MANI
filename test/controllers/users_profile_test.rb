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
    titles = response.body.scan(%r{<span class="trail-title">(Primeira|Segunda|Terceira)</span>}).flatten
    assert_equal %w[Primeira Segunda Terceira], titles
  end

  test "the first lesson is current and the others are locked" do
    first = create_lesson(title: "Aula 1", count: 2)
    create_lesson(title: "Aula 2", count: 2)

    get user_url(@user)

    assert_select "li.trail-node.is-current", 1
    assert_select "li.trail-node.is-locked", 1
    assert_select "li.trail-node.is-current a[href='#{question_path(first.questions.first)}']"
    assert_select "li.trail-node.is-locked a", 0
  end

  test "a finished lesson shows its score and unlocks the next one" do
    lesson = create_lesson(title: "Aula X", count: 3)
    create_lesson(title: "Aula Y", count: 1)
    user = create_user # created after the lessons so it has an answer per question
    sign_in user
    user.answers.where(question: lesson.questions.first(2)).update_all(is_correct: true)
    LessonCompletion.create!(user: user, lesson: lesson, correct_count: 2)

    get user_url(user)

    assert_select "li.trail-node.is-completed", 1
    assert_select "li.trail-node.is-current", 1
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
end
