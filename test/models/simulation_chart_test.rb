require "test_helper"

class SimulationChartTest < ActiveSupport::TestCase
  def chart(months: 60, **options)
    result = InvestmentSimulator.new(initial: 1000, months: months, **options).call
    SimulationChart.new(result)
  end

  test "the top of the chart is a tidy number above the highest line" do
    chart = chart(months: 120, monthly: 500)
    highest = chart.result.series.values.flatten.max

    assert_operator chart.top_value, :>=, highest
    assert_operator chart.top_value, :<, highest * 2
    assert_equal 0, (chart.top_value / 5) % (10**(Math.log10(chart.top_value / 5).floor - 1)).to_f
  end

  test "zero is at the bottom and the top value at the top of the plot" do
    chart = chart(months: 60)

    assert_in_delta SimulationChart::HEIGHT - SimulationChart::BOTTOM, chart.y(0), 0.001
    assert_in_delta SimulationChart::TOP, chart.y(chart.top_value), 0.001
  end

  test "the first month is at the left edge and the last at the right edge" do
    chart = chart(months: 36)

    assert_in_delta SimulationChart::LEFT, chart.x(0), 0.001
    assert_in_delta SimulationChart::WIDTH - SimulationChart::RIGHT, chart.x(36), 0.001
  end

  test "six y ticks from zero to the top" do
    ticks = chart.y_ticks

    assert_equal 6, ticks.size
    assert_equal 0, ticks.first.first
    assert_in_delta chart.top_value, ticks.last.first, 0.001
  end

  test "the x ticks are years for a long term and months for a short one" do
    long = chart(months: 120)
    short = chart(months: 6)

    assert_equal "anos", long.x_unit
    assert_equal %w[0 2 4 6 8 10], long.x_ticks.map(&:last)
    assert_equal "meses", short.x_unit
    assert_equal "0", short.x_ticks.first.last
    assert_equal "6", short.x_ticks.last.last
    assert_equal "meses", chart(months: 24).x_unit
    assert_equal "anos", chart(months: 36).x_unit
  end

  test "there are at most six x ticks" do
    [6, 12, 24, 36, 60, 120, 240].each do |months|
      assert_operator chart(months: months).x_ticks.size, :<=, 7, "#{months} months"
    end
  end

  test "each line is a path with one point per month, from the first month" do
    chart = chart(months: 12, product_keys: [:poupanca])
    path = chart.path_for(:poupanca)

    assert path.start_with?("M")
    assert_equal 13, path.scan(/[ML]/).size
  end

  test "the end marker sits at the last month and the last value" do
    chart = chart(months: 12, product_keys: [:cdb])
    x, y = chart.end_point(:cdb)

    assert_in_delta chart.x(12), x, 0.001
    assert_in_delta chart.y(chart.result.final(:cdb)), y, 0.001
  end

  test "a lines that grows goes up the screen (smaller y)" do
    chart = chart(months: 12, product_keys: [:cdb])

    assert_operator chart.y(chart.result.final(:cdb)), :<, chart.y(1000)
  end
end
