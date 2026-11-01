require "test_helper"

class StoreControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user(username: "ana")
    sign_in @user
  end

  test "the store needs a login" do
    sign_out @user

    get store_url

    assert_redirected_to new_user_session_url
  end

  test "it lists the base avatar and the fifteen for sale" do
    get store_url

    assert_response :success
    assert_select "title", text: "Mani Store · MANI"
    assert_select "h1", text: "Mani Store"
    assert_select "li.store-card", 16
    assert_select "li.store-card .store-avatar img", 16
  end

  test "it shows the balance and the price of each avatar" do
    @user.update!(manis: 85)

    get store_url

    assert_select ".store-balance", text: /85 M\$/
    assert_select "li.store-card h2", text: "Pigdalf"
    assert_select "li.store-card .store-tier", text: "Épico"
  end

  test "the base avatar starts in use" do
    get store_url

    assert_select "li.store-card.is-in-use h2", text: "Mani"
    assert_select "li.store-card.is-in-use .store-badge", text: /Em uso/
  end

  test "what the person can pay for has a buy button and the rest says what is missing" do
    @user.update!(manis: 50)

    get store_url

    assert_select "form[action='#{purchase_avatar_path('pokehog')}'] button", text: "Comprar por 20 M$"
    assert_select "form[action='#{purchase_avatar_path('neo-hog')}'] button", text: "Comprar por 50 M$"
    assert_select "form[action='#{purchase_avatar_path('pigdalf')}']", 0
    assert_select ".store-locked", text: /Faltam 10 M\$/
    assert_select ".store-locked", text: /Faltam 100 M\$/
  end

  test "buying asks for confirmation before it spends" do
    @user.update!(manis: 50)

    get store_url

    assert_select "form[data-action='submit->purchase#ask'][data-avatar-name='Pokehog Trainer'][data-avatar-price='20'][data-avatar-tier='Comum']"
    assert_select "[data-controller=purchase][data-purchase-balance-value='50']"
    assert_select "dialog.store-modal [data-purchase-target=balance]"
    assert_select "dialog.store-modal button[data-action='purchase#confirm']", text: "Comprar"
    assert_select "dialog.store-modal button[autofocus]", text: "Cancelar"
    assert_select "form[data-turbo-confirm]", 0
  end

  test "buying takes the M$ and then offers to use the avatar" do
    @user.update!(manis: 50)

    post purchase_avatar_url("pokehog")

    assert_redirected_to store_url
    assert_equal 30, @user.reload.manis
    follow_redirect!
    assert_select ".mani-flash.is-notice", text: /Você comprou o avatar Pokehog Trainer/
    assert_select "form[action='#{use_avatar_path('pokehog')}'] button", text: "Usar"
    assert_select "form[action='#{purchase_avatar_path('pokehog')}']", 0
    assert_select ".store-balance", text: /30 M\$/
  end

  test "without enough M$ the purchase is refused and says how much is missing" do
    @user.update!(manis: 15)

    post purchase_avatar_url("pokehog")

    assert_redirected_to store_url
    assert_equal 15, @user.reload.manis
    follow_redirect!
    assert_select ".mani-flash.is-alert", text: /Faltam 5 M\$/
  end

  test "a second purchase of the same avatar is refused" do
    @user.update!(manis: 100)
    post purchase_avatar_url("pokehog")

    post purchase_avatar_url("pokehog")

    assert_equal 80, @user.reload.manis
    follow_redirect!
    assert_select ".mani-flash.is-alert", text: /já tem esse avatar/
  end

  test "an avatar that does not exist is refused" do
    post purchase_avatar_url("super-porco")

    assert_redirected_to store_url
    follow_redirect!
    assert_select ".mani-flash.is-alert", text: /não existe na loja/
  end

  test "the base avatar cannot be bought" do
    @user.update!(manis: 500)

    post purchase_avatar_url("mani")

    assert_equal 500, @user.reload.manis
    assert_equal 0, @user.avatar_purchases.count
  end

  test "a bought avatar can be used and then shows in the top bar" do
    @user.update!(manis: 20)
    post purchase_avatar_url("pokehog")

    post use_avatar_url("pokehog")

    assert_redirected_to store_url
    assert_equal "pokehog", @user.reload.avatar_key
    follow_redirect!
    assert_select ".mani-flash.is-notice", text: /Agora você usa o avatar Pokehog Trainer/
    assert_select "li.store-card.is-in-use h2", text: "Pokehog Trainer"
    assert_select "button.avatar-button img.avatar.is-custom[src*='pokehog']"
  end

  test "an avatar that was not bought cannot be used" do
    post use_avatar_url("pigdalf")

    assert_equal "mani", @user.reload.avatar_key
    follow_redirect!
    assert_select ".mani-flash.is-alert", text: /Compre o avatar antes/
  end

  test "going back to the base avatar is always possible" do
    @user.update!(manis: 20)
    post purchase_avatar_url("pokehog")
    post use_avatar_url("pokehog")

    post use_avatar_url("mani")

    assert_equal "mani", @user.reload.avatar_key
  end

  test "the ranking shows the avatar of each person" do
    friend = create_user(username: "bia")
    friend.update!(manis: 20)
    friend.buy_avatar!(Avatar.find("pokehog"))
    friend.use_avatar!(Avatar.find("pokehog"))
    Friendship.create!(asker: @user, receiver: friend)

    get user_url(@user)

    assert_select "ol.ranking-list li", 2
    assert_select "ol.ranking-list img.rank-avatar.is-base", 1
    assert_select "ol.ranking-list img.rank-avatar.is-custom[src*='pokehog']", 1
  end

  test "the navigation leads to the store" do
    get user_url(@user)

    assert_select "nav a.nav-link[href='#{store_path}']", text: "Loja"
    assert_select "nav a.status-chip.is-manis[href='#{store_path}']"
    assert_select "a.feature-card[href='#{store_path}']"
  end

  test "the store cannot be changed with a plain link" do
    get purchase_avatar_url("pokehog")

    assert_response :not_found
  end

  test "the card of the base avatar never asks for M$" do
    get store_url

    assert_select "li.store-card.is-in-use .store-locked", 0
    assert_select "li.store-card.is-in-use form", 0
  end

  test "the note explains where the M$ come from" do
    get store_url

    assert_select ".store-note", text: /3 M\$/
  end
end
