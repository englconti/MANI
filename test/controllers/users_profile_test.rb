require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  setup do
    Information.create!(text: "fato", img_url: "https://example.com/a.png", source: "https://example.com")
    @user = create_user
    sign_in @user
  end

  test "B-5: profile lists lessons by position, whatever their ids are" do
    third = Lesson.create!(title: "Terceira", description: "d", position: 3)
    first = Lesson.create!(title: "Primeira", description: "d", position: 1)
    second = Lesson.create!(title: "Segunda", description: "d", position: 2)
    [first, second, third].each do |lesson|
      Question.create!(lesson: lesson, question_type: "abcd", statement: "q", a: "a", b: "b",
                       c: "c", d: "d", correct_answer: "a")
    end

    get user_url(@user)

    assert_response :success
    titles = response.body.scan(%r{<p>(Primeira|Segunda|Terceira)</p>}).flatten
    assert_equal %w[Primeira Segunda Terceira], titles
  end

  test "profile shows the user's score per lesson" do
    lesson = create_lesson(title: "Aula X", count: 3)
    user = create_user # created after the lesson so it has an answer per question
    sign_in user
    user.answers.where(question: lesson.questions.first(2)).update_all(is_correct: true)

    get user_url(user)

    assert_response :success
    assert_includes response.body, "2 / 3"
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
end
