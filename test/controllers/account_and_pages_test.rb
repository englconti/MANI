require "test_helper"

class AccountAndPagesTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = create_lesson(count: 2)
    @user = create_user(username: "carla")
    sign_in @user
  end

  # --- Edit account ------------------------------------------------------------------

  test "the edit page asks for the data that can change and keeps deletion apart" do
    get edit_user_registration_url

    assert_response :success
    assert_select "title", text: "Editar dados · MANI"
    assert_select "input[name='user[email]']"
    assert_select "input[type=date][name='user[birthday]']"
    assert_select "input[name='user[password]']"
    assert_select "input[name='user[current_password]'][required]"
    assert_select "section.danger-zone h2", text: "Excluir conta"
    assert_select "section.danger-zone input[name=current_password][type=password]"
    assert_select "[style]", count: 0
  end

  test "the birthday can be changed with the current password and goes back to the trail" do
    put user_registration_url, params: { user: { birthday: "1990-05-17", current_password: "senha1234" } }

    assert_redirected_to user_url(@user)
    assert_equal Date.new(1990, 5, 17), @user.reload.birthday.to_date
  end

  test "nothing changes without the current password" do
    put user_registration_url, params: { user: { birthday: "1990-05-17", current_password: "" } }

    assert_response :unprocessable_entity
    assert_not_equal Date.new(1990, 5, 17), @user.reload.birthday.to_date
  end

  test "the account form cannot be used to change lives, score or the username" do
    put user_registration_url, params: { user: { lives: 99, score: 9999, username: "outro", current_password: "senha1234" } }

    @user.reload
    assert_not_equal 99, @user.lives
    assert_equal "carla", @user.username
  end

  test "sign up cannot set lives or score either" do
    sign_out @user

    post user_registration_url, params: { user: { username: "nova", email: "nova@example.com", birthday: "2000-01-01",
                                                  password: "senha1234", password_confirmation: "senha1234",
                                                  lives: 99, score: 9999 } }

    created = User.find_by!(username: "nova")
    assert_not_equal 99, created.lives
  end

  test "deleting the account needs the right password" do
    assert_no_difference -> { User.count } do
      delete user_registration_url, params: { current_password: "errada" }
    end

    assert_redirected_to edit_user_registration_url
    follow_redirect!
    assert_select ".mani-flash.is-alert[role=alert][data-flash-delay-value='0']", text: /Senha incorreta/
  end

  test "deleting the account removes the person and what belongs to them" do
    friend = create_user(username: "bia")
    Friendship.create!(asker: @user, receiver: friend)
    Friendship.create!(asker: friend, receiver: @user)
    LessonCompletion.create!(user: @user, lesson: @lesson)
    answers = @user.answers.count
    assert_operator answers, :>, 0

    assert_difference -> { User.count } => -1, -> { Answer.count } => -answers, -> { Friendship.count } => -2,
                      -> { LessonCompletion.count } => -1 do
      delete user_registration_url, params: { current_password: "senha1234" }
    end

    assert_redirected_to root_url
    assert User.exists?(friend.id)
  end

  # --- Messages ------------------------------------------------------------------------

  test "a notice closes by itself and an alert stays" do
    post friendships_url(receiver_username: create_user(username: "dani").username)
    follow_redirect!

    assert_select ".mani-flash.is-notice[role=status][data-flash-delay-value='6000']"
    assert_select ".mani-flash button[aria-label='Fechar aviso']"
  end

  test "the layout does not load the external icon kit" do
    get user_url(@user)

    assert_no_match(/fontawesome/i, response.body)
    assert_no_match(/\bfa-(solid|regular)\b|\bfas fa-/, response.body)
  end

  # --- Icons and the friends window -------------------------------------------------------

  test "the lesson screen uses its own icons for leaving and for sound" do
    get question_url(@lesson.questions.first)

    assert_select "a.question-cancel-btn svg.mani-icon-close_circle"
    assert_select "button.sound-toggle [data-sound-icon=on] svg"
    assert_select "button.sound-toggle [data-sound-icon=off][hidden] svg"
  end

  test "the friend search is a native dialog with a name and a real close button" do
    get user_url(@user)

    assert_select "dialog.friend-dialog[aria-labelledby='search-friend-statement']"
    assert_select "#search-friend-statement"
    assert_select "dialog.friend-dialog button.add-friend-cancel-btn[aria-label=Fechar] svg"
    assert_select ".overlay", count: 0
  end

  # --- Error pages -------------------------------------------------------------------------

  test "the static error pages are in Portuguese and lead back home" do
    {
      "404.html" => "Página não encontrada",
      "422.html" => "Não foi possível concluir",
      "500.html" => "Algo deu errado do nosso lado"
    }.each do |file, title|
      html = File.read(Rails.root.join("public", file), encoding: "UTF-8")

      assert_includes html, title, "#{file} title"
      assert_includes html, 'lang="pt-BR"'
      assert_includes html, 'href="/"'
      assert_includes html, "Voltar ao início"
      assert_no_match(/The page you were looking for|Sorry|Maybe you tried/i, html)
    end
    assert File.exist?(Rails.root.join("public/mani-erro.png"))
  end

  test "errors on the account form are in Portuguese" do
    put user_registration_url, params: { user: { birthday: "1990-05-17", current_password: "errada" } }

    assert_response :unprocessable_entity
    assert_select ".alert, .error_notification", text: /Corrija os problemas abaixo/
    assert_select ".invalid-feedback, .error", text: /está incorreta/
  end
end
