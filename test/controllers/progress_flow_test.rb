require "test_helper"

class ProgressFlowTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = create_lesson(title: "Aula Um", count: 3)
    @user = create_user(username: "ana")
    sign_in @user
  end

  def json(answer, practice: nil)
    params = { answer: answer }
    params[:practice] = practice unless practice.nil?
    patch answer_url(@user.answers.first), params: params, as: :json, headers: { "Accept" => "application/json" }
  end

  # --- Progress panel ------------------------------------------------------------------------

  test "the panel shows the level, the goal and the streak" do
    get user_url(@user)

    assert_select ".progress-panel .tile-title", text: /Nível 1: Cofrinho/
    assert_select ".progress-panel .meter[role=progressbar][aria-valuenow='0']"
    assert_select ".progress-panel .tile-note", text: /Faltam 75 XP para Poupador/
    assert_select ".progress-panel .tile-note", text: /0 de 20 XP hoje/
    assert_select ".progress-panel .tile-title", text: /0 dias seguidos/
    assert_select ".progress-panel .tile-note", text: /Estude hoje para começar uma sequência/
  end

  test "the panel follows the XP of the day and the level" do
    @user.update!(xp: 100)
    XpDay.credit!(@user, 12)

    get user_url(@user)

    assert_select ".tile-title", text: /Nível 2: Poupador/
    assert_select ".tile-note", text: /12 de 20 XP hoje/
    assert_select ".meter.is-goal[aria-valuenow='12']"
  end

  test "reaching the goal says so" do
    XpDay.credit!(@user, 25)

    get user_url(@user)

    assert_select ".tile-title", text: /Meta do dia/
    assert_select ".tile-note", text: /Meta batida! 25 XP hoje/
    assert_select ".meter.is-goal[aria-valuenow='20']"
  end

  test "a streak at risk is a warning and one kept today is reassuring" do
    @user.update!(streak_count: 4, last_study_on: Time.zone.today - 1)
    get user_url(@user)
    assert_select ".tile-note.is-warning", text: /Sua sequência termina hoje/
    assert_select ".tile-title", text: /4 dias seguidos/

    @user.update!(last_study_on: Time.zone.today)
    get user_url(@user)
    assert_select ".tile-note.is-warning", count: 0
    assert_select ".tile-note", text: /Sequência garantida por hoje/
  end

  test "the panel offers the recommended lesson and the trail marks it" do
    other = create_lesson(title: "Aula Dois", count: 2)
    LessonCompletion.create!(user: @user, lesson: @lesson)

    get user_url(@user)

    assert_select "a#btn-continue-trail[href='#{question_path(other.questions.first)}']", text: /Continuar: Aula Dois/
    assert_select "li.trail-node.is-recommended .trail-start", text: "Próxima"
    assert_select "li.trail-node.is-recommended", 1
  end

  test "only one open lesson is recommended; the others just say start" do
    create_lesson(title: "Aula Dois", count: 2)

    get user_url(@user)

    assert_select "li.trail-node.is-available", 2
    assert_select "li.trail-node.is-recommended", 1
    assert_select "li.trail-node.is-available:not(.is-recommended) .trail-start", text: "Começar"
  end

  test "there is nothing to continue when every lesson is done" do
    LessonCompletion.create!(user: @user, lesson: @lesson)

    get user_url(@user)

    assert_select "a#btn-continue-trail", 0
  end

  test "a finished lesson offers practice on the trail" do
    LessonCompletion.create!(user: @user, lesson: @lesson)

    get user_url(@user)

    assert_select "li.trail-node.is-completed a.trail-practice[href='#{question_path(@lesson.questions.first, practice: 1)}']", text: "Praticar"
  end

  # --- Daily goal ----------------------------------------------------------------------------

  test "the goal can be changed to one of the steps" do
    patch daily_goal_url, params: { goal: 40 }

    assert_redirected_to user_url(@user)
    assert_equal 40, @user.reload.daily_goal
    follow_redirect!
    assert_select ".mani-flash", text: /Meta do dia: 40 XP/
    assert_select "button.goal-option[aria-pressed=true]", text: /Forte: 40 XP/
  end

  test "a goal that is not offered is refused" do
    patch daily_goal_url, params: { goal: 15 }

    assert_equal 20, @user.reload.daily_goal
    follow_redirect!
    assert_select ".mani-flash.is-alert"
  end

  test "changing the goal needs a login" do
    sign_out @user

    patch daily_goal_url, params: { goal: 40 }

    assert_redirected_to new_user_session_url
  end

  # --- Weekly ranking --------------------------------------------------------------------------

  test "the ranking lists me and the people I follow by XP of the week" do
    bia = create_user(username: "bia")
    caio = create_user(username: "caio")
    create_user(username: "fora") # not followed: not in the list
    [bia, caio].each { |friend| Friendship.create!(asker: @user, receiver: friend) }
    XpDay.credit!(bia, 40)
    XpDay.credit!(@user, 25)
    XpDay.credit!(caio, 5)

    get user_url(@user)

    names = css_select("ol.ranking-list li p:nth-of-type(1)").map(&:text)
    assert_equal %w[Bia Você Caio], names
    assert_equal %w[1 2 3], css_select("ol.ranking-list .rank").map { |rank| rank.text.gsub("Posição", "").strip }
    assert_select "li.friend-box.is-me", 1
    assert_select ".ranking-note", text: /zera toda segunda/
  end

  test "the same XP means the same place" do
    bia = create_user(username: "bia")
    Friendship.create!(asker: @user, receiver: bia)
    XpDay.credit!(bia, 20)
    XpDay.credit!(@user, 20)

    get user_url(@user)

    assert_equal %w[1 1], css_select("ol.ranking-list .rank").map { |rank| rank.text.gsub("Posição", "").strip }
  end

  test "XP of last week does not count and the ranking starts over on Monday" do
    bia = create_user(username: "bia")
    Friendship.create!(asker: @user, receiver: bia)
    sunday = Date.new(2026, 11, 1)
    XpDay.credit!(bia, 90, day: sunday)

    travel_to Time.zone.local(2026, 11, 3, 12) do # Tuesday
      get user_url(@user)
      xps = css_select("ol.ranking-list li").map { |item| item.css("p").last.text }
      assert_equal ["0 XP", "0 XP"], xps
    end

    travel_to Time.zone.local(2026, 11, 1, 12) do # still Sunday of the old week
      get user_url(@user)
      assert_equal "Bia", css_select("ol.ranking-list li p:nth-of-type(1)").first.text
    end
  end

  test "with no friends the list has only me and invites to follow" do
    get user_url(@user)

    assert_select "ol.ranking-list li", 1
    assert_select ".friends-empty", text: /Busque um amigo/
  end

  # --- Lesson summary ------------------------------------------------------------------------------

  test "the summary says when the lesson took the person to the next level" do
    @user.update!(xp: 65)
    @user.answers.update_all(is_correct: true)

    get lesson_url(@lesson)

    assert_select ".finish-banner", text: /Você subiu para o nível 2: Poupador/
  end

  test "the summary says when the daily goal was just reached" do
    @user.update!(daily_goal: 10)
    @user.answers.update_all(is_correct: true)

    get lesson_url(@lesson)

    assert_select ".finish-banner", text: /Meta do dia batida/
  end

  test "reloading the summary does not repeat the celebration" do
    @user.update!(daily_goal: 10)
    @user.answers.update_all(is_correct: true)
    get lesson_url(@lesson)

    get lesson_url(@lesson)

    assert_select ".finish-banner", count: 0
  end

  # --- Practice mode ------------------------------------------------------------------------------------

  test "practice on a finished lesson costs no life and changes no score" do
    LessonCompletion.create!(user: @user, lesson: @lesson)
    @user.answers.update_all(is_correct: true)

    json("B", practice: true)

    body = JSON.parse(response.body)
    assert_equal false, body["correct"]
    assert_equal 5, body["lives"]
    assert_equal 5, @user.reload.lives
    assert @user.answers.first.is_correct
  end

  test "practice also grades right answers without touching the streak or the score" do
    LessonCompletion.create!(user: @user, lesson: @lesson)

    json("a", practice: true)

    assert JSON.parse(response.body)["correct"]
    assert_equal false, @user.answers.first.reload.is_correct
    assert_nil @user.reload.last_study_on
  end

  test "a lesson that was not finished cannot be practiced: it counts for real" do
    json("B", practice: true)

    assert_equal 4, JSON.parse(response.body)["lives"]
    assert_equal 4, @user.reload.lives
  end

  test "without the practice flag a wrong answer still costs a life" do
    LessonCompletion.create!(user: @user, lesson: @lesson)

    json("B")

    assert_equal 4, @user.reload.lives
  end

  test "someone without lives can practice a finished lesson but not start a normal one" do
    LessonCompletion.create!(user: @user, lesson: @lesson)
    @user.update!(lives: 0, lives_recharge_started_at: Time.current)

    get question_url(@lesson.questions.first, practice: 1)
    assert_response :success
    assert_select ".practice-badge", text: /Prática/
    assert_select "[data-lesson-practice-value='true']"

    get question_url(@lesson.questions.first)
    assert_redirected_to no_lives_url
  end

  test "the practice flag is ignored for a lesson not finished" do
    @user.update!(lives: 0, lives_recharge_started_at: Time.current)

    get question_url(@lesson.questions.first, practice: 1)

    assert_redirected_to no_lives_url
  end

  test "practice keeps the flag on the way through the lesson and ends on the trail" do
    first, second, third = @lesson.questions.to_a
    LessonCompletion.create!(user: @user, lesson: @lesson)

    get question_url(first, practice: 1)
    assert_select "[data-lesson-next-url-value='#{question_path(second, practice: 1)}']"

    get question_url(third, practice: 1)
    assert_select "[data-lesson-next-url-value='#{user_path(@user)}']"
  end

  test "a normal question page has no practice badge" do
    get question_url(@lesson.questions.first)

    assert_select ".practice-badge", 0
    assert_select "[data-lesson-practice-value='false']"
  end

  test "the no lives page lists the finished lessons to practice" do
    LessonCompletion.create!(user: @user, lesson: @lesson)
    @user.update!(lives: 0, lives_recharge_started_at: Time.current)

    get no_lives_url

    assert_select ".practice-list a[href='#{question_path(@lesson.questions.first, practice: 1)}']", text: "Aula Um"
  end

  test "the no lives page tells to finish a lesson when there is none to practice" do
    @user.update!(lives: 0, lives_recharge_started_at: Time.current)

    get no_lives_url

    assert_select ".practice-list a", 0
    assert_select ".practice-list", text: /Conclua uma aula para liberar o modo prática/
  end

  test "the summary offers practice" do
    get lesson_url(@lesson)

    assert_select "a#btn-practice[href='#{question_path(@lesson.questions.first, practice: 1)}']"
  end
end
