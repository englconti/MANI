require "test_helper"

class LessonIntroTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = create_lesson(title: "Aula Um", count: 3)
    @lesson.update!(intro_title: "Vamos começar", intro_text: "Primeiro parágrafo.\n\nSegundo parágrafo.", intro_image: "golpes")
    @user = create_user
    sign_in @user
  end

  test "the introduction shows the title, the paragraphs and a button to start" do
    get intro_lesson_url(@lesson)

    assert_response :success
    assert_select "title", text: "Vamos começar · MANI"
    assert_select ".intro-card h1", text: "Vamos começar"
    assert_select ".intro-card p", text: "Primeiro parágrafo."
    assert_select ".intro-card p", text: "Segundo parágrafo."
    assert_select ".intro-meta", text: /Aula Um · 3 perguntas/
    assert_select ".intro-art img"
    assert_select "a#btn-start-lesson[href='#{question_path(@lesson.questions.first, skip_intro: 1)}']", text: "Começar a aula"
  end

  test "the first question opens the introduction first" do
    get question_url(@lesson.questions.first)

    assert_redirected_to intro_lesson_url(@lesson)
  end

  test "starting from the introduction goes to the question" do
    get question_url(@lesson.questions.first, skip_intro: 1)

    assert_response :success
  end

  test "other questions never go through the introduction" do
    get question_url(@lesson.questions.second)

    assert_response :success
  end

  test "practice and retrying the wrong ones skip the introduction" do
    LessonCompletion.create!(user: @user, lesson: @lesson)
    first = @lesson.questions.first

    get question_url(first, practice: 1)
    assert_response :success

    get question_url(first, retry: first.id.to_s)
    assert_response :success
  end

  test "a lesson without an introduction goes straight to the question" do
    other = create_lesson(count: 2)

    get question_url(other.questions.first)
    assert_response :success

    get intro_lesson_url(other)
    assert_redirected_to question_url(other.questions.first, skip_intro: 1)
  end

  test "a locked lesson has no introduction either" do
    locked = create_lesson(title: "Aula Trancada", count: 2, prerequisite: @lesson)
    locked.update!(intro_text: "Texto.")

    get intro_lesson_url(locked)

    assert_redirected_to user_url(@user)
  end

  test "the summary offers to see the introduction again" do
    get lesson_url(@lesson)

    assert_select "a#btn-lesson-intro[href='#{intro_lesson_path(@lesson)}']"
  end

  test "a reminder shows above its question" do
    question = @lesson.questions.second
    question.update!(context: "Lembre-se: golpes prometem ganho fácil.")

    get question_url(question)

    assert_select "aside.question-context[aria-label=Lembrete] p", text: "Lembre-se: golpes prometem ganho fácil."
  end

  test "a question without a reminder has no box" do
    get question_url(@lesson.questions.second)

    assert_select "aside.question-context", 0
  end

  test "the lesson picture falls back to the mascot when the file does not exist yet" do
    get intro_lesson_url(@lesson)

    assert_select ".intro-art img[src*='Mani-oficial']"
  end

  test "intro paragraphs split on blank lines and ignore empty ones" do
    lesson = Lesson.new(intro_text: "A\n\n\nB\r\n\r\nC\n")

    assert_equal %w[A B C], lesson.intro_paragraphs
    assert_not Lesson.new(intro_text: " ").intro?
  end

  test "every lesson of the CSV points at a pose that exists" do
    CSV.read(Rails.root.join("db/data/Mani - lessons_starter.csv"), headers: true).each do |lesson|
      pose = lesson["intro_image"]

      assert pose.present?, "#{lesson['title']} has no picture"
      assert File.exist?(Rails.root.join("app/assets/images/mascot/#{pose}.png")), "#{lesson['title']}: #{pose}.png does not exist"
    end
  end

  test "each lesson has its own pose" do
    poses = CSV.read(Rails.root.join("db/data/Mani - lessons_starter.csv"), headers: true).map { |lesson| lesson["intro_image"] }

    assert_equal poses.uniq, poses
  end

  test "the introduction shows the pose of the lesson" do
    @lesson.update!(intro_image: "pig-thinking")

    get intro_lesson_url(@lesson)

    assert_select ".intro-art img[src*='pig-thinking']"
  end

  test "the summary and the no lives screens show poses of the mascot" do
    @user.answers.update_all(is_correct: true)
    get lesson_url(@lesson)
    assert_select ".finish-mascot img[src*='pig-cheering']"

    @user.update!(lives: 0, lives_recharge_started_at: Time.current)
    get no_lives_url
    assert_select ".finish-mascot img[src*='pig-sleeping']"
  end

  test "an unknown pose falls back to the plain mascot" do
    @lesson.update!(intro_image: "pose-que-nao-existe")

    get intro_lesson_url(@lesson)

    assert_select ".intro-art img[src*='Mani-oficial']"
  end
end
