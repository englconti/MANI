require "test_helper"

class LevelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = create_lesson(count: 3)
    @user = create_user
    sign_in @user
  end

  test "the levels page needs a login" do
    sign_out @user

    get levels_url

    assert_redirected_to new_user_session_url
  end

  test "it lists every level with the XP it needs" do
    get levels_url

    assert_response :success
    assert_select "title", text: "Níveis · MANI"
    assert_select "ol.levels-list li.level-row", PlayerLevel::LEVELS.size
    names = css_select(".level-name").map(&:text)
    assert_equal PlayerLevel::LEVELS.map(&:first), names
    ranges = css_select(".level-range").map(&:text).map(&:strip)
    assert_equal "De 0 a 49 XP", ranges.first
    assert_equal "De 50 a 119 XP", ranges.second
    assert_equal "A partir de 340 XP", ranges.last
  end

  test "the current level is marked and the others are done or locked" do
    @user.update!(xp: 130)

    get levels_url

    assert_select "li.level-row.is-done", 2
    assert_select "li.level-row.is-current[aria-current=step] .level-name", text: "Investidor"
    assert_select "li.level-row.is-locked", 2
    assert_select "li.level-row.is-locked .level-state", text: /Faltam 90 XP/
    assert_select "li.level-row.is-done .level-state", text: /Concluído/
    assert_select "li.level-row.is-current .level-state", text: /Você está aqui/
  end

  test "it compares the current level with the next and says what is missing" do
    @user.update!(xp: 85)

    get levels_url

    assert_select ".compare-card.is-current .compare-name", text: "Nível 2: Poupador"
    assert_select ".compare-card.is-current .compare-xp", text: "A partir de 50 XP"
    assert_select ".compare-card:not(.is-current) .compare-name", text: "Nível 3: Investidor"
    assert_select ".compare-card:not(.is-current) .compare-xp", text: "A partir de 120 XP"
    assert_select ".compare-summary", text: /Você tem 85 XP/
    assert_select ".compare-summary", text: /Faltam 35 XP para Investidor/
    assert_select ".compare-summary", text: /7 respostas certas/
    assert_select ".meter[aria-valuenow='50']"
  end

  test "one answer away from the next level uses the singular" do
    @user.update!(xp: 119)

    get levels_url

    assert_select ".compare-summary", text: /1 resposta certa/
  end

  test "at the top level there is no next one" do
    @user.update!(xp: 500)

    get levels_url

    assert_select ".compare-card .compare-name", text: "Você chegou ao topo"
    assert_select ".compare-summary", text: /nível máximo/i
    assert_select "li.level-row.is-done", 4
    assert_select "li.level-row.is-current .level-name", text: "Mestre"
  end

  test "the level tile of the trail page opens it" do
    get user_url(@user)

    assert_select ".progress-panel a.tile-link[href='#{levels_path}']"
    assert_select ".progress-panel a.tile-more[href='#{levels_path}']", text: "Ver níveis"
  end

  test "the page leads back to the trail" do
    get levels_url

    assert_select ".levels-actions a[href='#{user_path(@user)}']", text: "Voltar à trilha"
  end

  test "the lesson summary sets up the celebration with the stars of the lesson" do
    @user.answers.update_all(is_correct: true)
    get lesson_url(@lesson)
    assert_select "[data-controller=celebration][data-celebration-stars-value='3']"

    @user.answers.update_all(is_correct: false)
    get lesson_url(@lesson)
    assert_select "[data-controller=celebration][data-celebration-stars-value='1']"
  end

  test "the lesson summary no longer carries the CSS confetti pieces" do
    @user.answers.update_all(is_correct: true)

    get lesson_url(@lesson)

    assert_select ".confetti", 0
  end
end
