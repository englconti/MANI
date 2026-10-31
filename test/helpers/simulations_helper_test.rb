require "test_helper"

class SimulationsHelperTest < ActionView::TestCase
  test "brl uses the Brazilian format" do
    assert_equal "R$ 1.234,56", brl(1234.56)
    assert_equal "R$ 0,00", brl(0)
    assert_equal "R$ 1.000.000,00", brl(1_000_000)
  end

  test "brl_short for the axis" do
    assert_equal "R$ 0", brl_short(0)
    assert_equal "R$ 800", brl_short(800)
    assert_equal "R$ 12 mil", brl_short(12_000)
    assert_equal "R$ 2,5 mil", brl_short(2500)
    assert_equal "R$ 2,5 mi", brl_short(2_500_000)
    assert_equal "R$ 10 mi", brl_short(10_000_000)
  end

  test "percent_br" do
    assert_equal "12,3%", percent_br(12.28)
    assert_equal "-9,88%", percent_br(-9.88, precision: 2)
  end

  test "month_label" do
    assert_equal "nov/2025", month_label("2025-11")
    assert_equal "jan/2026", month_label("2026-01")
  end

  test "each marker has its own shape" do
    shapes = %i[circle square triangle diamond].map { |shape| chart_marker(shape, 10, 10, "#fff").to_s[/<(\w+)/, 1] }

    assert_equal %w[circle rect polygon polygon], shapes
  end
end
