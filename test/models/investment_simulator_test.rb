require "test_helper"

class InvestmentSimulatorTest < ActiveSupport::TestCase
  def simulate(**options)
    InvestmentSimulator.new(initial: 1000, **options).call
  end

  test "the savings account grows 0.5% a month, compounded" do
    result = simulate(months: 12, product_keys: [:poupanca])

    assert_in_delta 1000 * 1.005**12, result.final(:poupanca), 0.01
    assert_equal 13, result.series[:poupanca].size
    assert_equal 1000.0, result.series[:poupanca].first
  end

  test "CDB and LCI / LCA use 0.8% and 0.85% a month" do
    result = simulate(months: 24, product_keys: %i[cdb lci_lca])

    assert_in_delta 1000 * 1.008**24, result.final(:cdb), 0.01
    assert_in_delta 1000 * 1.0085**24, result.final(:lci_lca), 0.01
    assert_operator result.final(:lci_lca), :>, result.final(:cdb)
  end

  test "a monthly deposit enters at the end of each month, after the interest" do
    result = simulate(monthly: 100, months: 2, product_keys: [:poupanca])

    month_one = 1000 * 1.005 + 100
    month_two = month_one * 1.005 + 100
    assert_in_delta month_one, result.series[:poupanca][1], 0.01
    assert_in_delta month_two, result.series[:poupanca][2], 0.01
  end

  test "the money put in is the first sum plus the deposits" do
    result = simulate(monthly: 250, months: 6)

    assert_equal [1000.0, 1250.0, 1500.0, 1750.0, 2000.0, 2250.0, 2500.0], result.invested
  end

  test "the stocks line follows the last 12 months of the Ibovespa" do
    result = simulate(months: 12, product_keys: [:acoes])

    expected = 1000 * (1 + InvestmentSimulator.ibovespa_year_percent / 100)
    assert_in_delta expected, result.final(:acoes), 0.05
    assert_in_delta 1000 * 1.0637, result.series[:acoes][1], 0.01
    assert_in_delta 1000 * 1.0637 * 1.0129, result.series[:acoes][2], 0.01
  end

  test "after 12 months the stocks curve starts over with the same monthly changes" do
    result = simulate(months: 24, product_keys: [:acoes])

    assert_in_delta result.series[:acoes][12] * 1.0637, result.series[:acoes][13], 0.05
    assert_in_delta result.series[:acoes][12] * (1 + InvestmentSimulator.ibovespa_year_percent / 100), result.series[:acoes][24], 0.1
  end

  test "the stocks line goes down in a bad month, unlike the fixed ones" do
    result = simulate(months: 12, product_keys: %i[poupanca acoes])

    drop = result.series[:acoes].each_cons(2).any? { |before, after| after < before }
    assert drop
    assert result.series[:poupanca].each_cons(2).all? { |before, after| after > before }
  end

  test "the Ibovespa data has 12 months, a date and sources" do
    data = InvestmentSimulator.data

    assert_equal 12, data["months"].size
    assert_equal data["months"].map { |entry| entry["month"] }, data["months"].map { |entry| entry["month"] }.sort
    assert_equal data["months"].map { |entry| entry["month"] }.uniq, data["months"].map { |entry| entry["month"] }
    assert data["as_of"].present?
    assert_operator data["sources"].size, :>=, 1
    data["sources"].each { |source| assert_match(%r{\Ahttps://}, source["url"]) }
  end

  test "the year of the Ibovespa is the product of its months" do
    assert_in_delta 12.28, InvestmentSimulator.ibovespa_year_percent, 0.1
  end

  test "only the chosen products are projected, in the usual order" do
    result = simulate(months: 6, product_keys: %i[acoes poupanca])

    assert_equal %i[poupanca acoes], result.products.map(&:key)
    assert_equal %i[poupanca acoes], result.series.keys
  end

  test "gain, gain percent and the best product" do
    result = simulate(monthly: 100, months: 12, product_keys: %i[poupanca lci_lca])

    assert_in_delta result.final(:poupanca) - 2200, result.gain(:poupanca), 0.01
    assert_in_delta result.gain(:poupanca) * 100 / 2200, result.gain_percent(:poupanca), 0.01
    assert_equal :lci_lca, result.best.key
  end

  test "money can be typed in the Brazilian or the plain way" do
    {
      "1000" => 1000.0, "1.000" => 1000.0, "1.234,56" => 1234.56, "1234,56" => 1234.56,
      "1234.56" => 1234.56, "R$ 1.500" => 1500.0, " 50 " => 50.0, "0" => 0.0
    }.each do |text, expected|
      assert_equal expected, InvestmentSimulator.parse_money(text), text
    end
  end

  test "text that is not money is refused" do
    ["", "abc", "12abc", "1,2,3", nil].each do |text|
      assert_nil InvestmentSimulator.parse_money(text), text.inspect
    end
  end

  test "the terms offered are 6 months to 20 years" do
    assert_equal [6, 12, 24, 36, 60, 120, 240], InvestmentSimulator::TERMS.keys
  end

  test "every line has its own colour, so none looks like another" do
    colors = InvestmentSimulator::PRODUCTS.map(&:color)
    shapes = InvestmentSimulator::PRODUCTS.map(&:shape)

    assert_equal colors.uniq, colors
    assert_equal shapes.uniq, shapes
  end
end
