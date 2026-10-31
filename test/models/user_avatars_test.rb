require "test_helper"

class UserAvatarsTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @cheap = Avatar.find("pokehog") # 20 M$
    @dear = Avatar.find("iron-hog") # 120 M$
  end

  test "a new person uses the base avatar and owns only that" do
    assert_equal Avatar.default, @user.avatar
    assert_equal ["mani"], @user.owned_avatar_keys
    assert @user.owns_avatar?(Avatar.default)
    assert_not @user.owns_avatar?(@cheap)
  end

  test "buying takes the price from the M$ and records the purchase" do
    @user.update!(manis: 50)

    @user.buy_avatar!(@cheap)

    assert_equal 30, @user.reload.manis
    assert @user.owns_avatar?(@cheap)
    purchase = @user.avatar_purchases.find_by!(avatar_key: "pokehog")
    assert_equal 20, purchase.price
    assert_includes @user.owned_avatar_keys, "pokehog"
  end

  test "the exact balance is enough" do
    @user.update!(manis: 20)

    @user.buy_avatar!(@cheap)

    assert_equal 0, @user.reload.manis
  end

  test "without enough M$ nothing is bought and it says how much is missing" do
    @user.update!(manis: 100)

    error = assert_raises(Avatar::NotEnoughManis) { @user.buy_avatar!(@dear) }

    assert_equal 20, error.missing
    assert_equal 100, @user.reload.manis
    assert_not @user.owns_avatar?(@dear)
    assert_equal 0, @user.avatar_purchases.count
  end

  test "an avatar can only be bought once" do
    @user.update!(manis: 100)
    @user.buy_avatar!(@cheap)

    assert_raises(Avatar::AlreadyOwned) { @user.buy_avatar!(@cheap) }

    assert_equal 80, @user.reload.manis
    assert_equal 1, @user.avatar_purchases.count
  end

  test "two clicks in a row spend the M$ once" do
    @user.update!(manis: 25)
    same_person = User.find(@user.id)

    @user.buy_avatar!(@cheap)

    assert_raises(Avatar::AlreadyOwned) { same_person.buy_avatar!(@cheap) }
    assert_equal 5, @user.reload.manis
  end

  test "the base avatar is not for sale" do
    assert_raises(Avatar::Unknown) { @user.buy_avatar!(Avatar.default) }
  end

  test "an owned avatar can be put in use, and the base one always can" do
    @user.update!(manis: 20)
    @user.buy_avatar!(@cheap)

    @user.use_avatar!(@cheap)
    assert_equal @cheap, @user.reload.avatar

    @user.use_avatar!(Avatar.default)
    assert_equal Avatar.default, @user.reload.avatar
  end

  test "an avatar that was not bought cannot be used" do
    assert_raises(Avatar::NotOwned) { @user.use_avatar!(@cheap) }

    assert_equal Avatar.default, @user.reload.avatar
  end

  test "buying does not change the XP or the level" do
    @user.update!(manis: 50, xp: 60)

    @user.buy_avatar!(@cheap)

    assert_equal 60, @user.reload.xp
  end

  test "an avatar key outside the catalog is not valid" do
    @user.avatar_key = "hacker"

    assert_not @user.valid?
  end

  test "a stored key that left the catalog falls back to the base avatar" do
    @user.update_columns(avatar_key: "desapareceu")

    assert_equal Avatar.default, @user.avatar
  end

  test "deleting a person deletes their purchases" do
    @user.update!(manis: 20)
    @user.buy_avatar!(@cheap)

    assert_difference -> { AvatarPurchase.count }, -1 do
      @user.destroy
    end
  end

  test "the same avatar twice for one person is refused by the database too" do
    AvatarPurchase.create!(user: @user, avatar_key: "pokehog", price: 20)

    duplicate = AvatarPurchase.new(user: @user, avatar_key: "pokehog", price: 20)

    assert_not duplicate.valid?
  end

  test "a purchase of an avatar that does not exist is not valid" do
    assert_not AvatarPurchase.new(user: @user, avatar_key: "fantasma", price: 5).valid?
  end
end
