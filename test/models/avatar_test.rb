require "test_helper"
require "csv"

class AvatarTest < ActiveSupport::TestCase
  test "the base avatar comes first and is not for sale" do
    assert_equal "mani", Avatar.all.first.key
    assert Avatar.default.default?
    assert_equal 0, Avatar.default.price
    assert_not_includes Avatar.for_sale, Avatar.default
  end

  test "the store has the fifteen avatars of the sheet" do
    assert_equal 15, Avatar.for_sale.size
  end

  test "keys are unique, tidy and have a picture" do
    keys = Avatar.keys

    assert_equal keys.uniq, keys
    keys.each { |key| assert_match(/\A[a-z0-9-]+\z/, key) }
    Avatar.for_sale.each do |avatar|
      assert File.exist?(Rails.root.join("app/assets/images", avatar.image)), "#{avatar.key} has no picture"
    end
    assert File.exist?(Rails.root.join("app/assets/images", Avatar.default.image))
  end

  test "every avatar has a name, a line of text and a price" do
    Avatar.for_sale.each do |avatar|
      assert avatar.name.present?, avatar.key
      assert avatar.description.present?, avatar.key
      assert_operator avatar.price, :>, 0, avatar.key
    end
    names = Avatar.all.map(&:name)
    assert_equal names.uniq, names
  end

  test "the avatars are named after a pig, a hog or the like" do
    Avatar.for_sale.each do |avatar|
      assert_match(/pig|hog|porker|porco/i, avatar.name, "#{avatar.name} should play with pig, hog or porker")
    end
  end

  test "the store lists the cheapest first" do
    prices = Avatar.for_sale.map(&:price)

    assert_equal prices.sort, prices
  end

  test "the tier follows the price" do
    assert_equal "Comum", Avatar.find("pokehog").tier
    assert_equal "Raro", Avatar.find("piggy-porker").tier
    assert_equal "Épico", Avatar.find("obi-pig").tier
    assert_equal "Lendário", Avatar.find("hog-of-thrones").tier
    assert_equal "Inicial", Avatar.default.tier
  end

  test "the cheap avatars can be bought with the first lessons" do
    one_perfect_lesson = 10 * LessonCompletion::MANIS_PER_CORRECT_ANSWER

    assert_operator Avatar.for_sale.first.price, :<=, one_perfect_lesson
  end

  test "all the lessons together pay for several avatars, but not for the whole store" do
    questions = CSV.read(Rails.root.join("db/data/Mani - questions_starter.csv"), headers: true).size
    all_manis = questions * LessonCompletion::MANIS_PER_CORRECT_ANSWER
    cheapest_five = Avatar.for_sale.first(5).sum(&:price)

    assert_operator cheapest_five, :<=, all_manis
    assert_operator Avatar.for_sale.sum(&:price), :>, all_manis
  end

  test "find and find!" do
    assert_equal "Pigdalf", Avatar.find("pigdalf").name
    assert_nil Avatar.find("nao-existe")
    assert_raises(Avatar::Unknown) { Avatar.find!("nao-existe") }
  end

  test "pictures: the base one is a file of its own, the others are in avatars" do
    assert_equal "avatar-mani.webp", Avatar.default.image
    assert_equal "avatars/pigdalf.png", Avatar.find("pigdalf").image
  end

  test "two avatars with the same key are the same" do
    assert_equal Avatar.find("pigdalf"), Avatar.find("pigdalf")
    assert_not_equal Avatar.find("pigdalf"), Avatar.find("bat-hog")
  end
end
