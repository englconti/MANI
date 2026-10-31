# The geometry of the line chart of a simulation: where each axis tick, line and marker goes
# inside an SVG of WIDTH x HEIGHT. The SVG itself is drawn by the view.
class SimulationChart
  # A narrow drawing: on a phone it is shown at about 0.65 of this size, so the text stays readable
  WIDTH = 480
  HEIGHT = 340
  LEFT = 86
  RIGHT = 20
  TOP = 16
  BOTTOM = 52

  attr_reader :result, :top_value

  def initialize(result)
    @result = result
    @top_value = nice_top(all_values.max.to_f)
  end

  def plot_width = WIDTH - LEFT - RIGHT
  def plot_height = HEIGHT - TOP - BOTTOM

  def x(month)
    LEFT + plot_width * month.to_f / [result.months, 1].max
  end

  def y(value)
    TOP + plot_height * (1 - value.to_f / top_value)
  end

  # [[value, y], ...] from 0 up to the top of the chart
  def y_ticks
    step = top_value / 5.0
    (0..5).map { |index| [step * index, y(step * index)] }
  end

  # [[month, x, label], ...]: the label is only a number; x_unit says whether they are years or months
  def x_ticks
    unit = result.months > 24 ? 12 : (result.months > 12 ? 6 : (result.months > 6 ? 3 : 1))
    count = [result.months / unit, 6].min.clamp(1, 6)
    spacing = (result.months.to_f / count / unit).ceil * unit
    (0..result.months).step(spacing).map { |month| [month, x(month), x_label(month)] }
  end

  def x_unit
    result.months > 24 ? "anos" : "meses"
  end

  def path_for(key)
    path(result.series.fetch(key))
  end

  def invested_path
    path(result.invested)
  end

  def end_point(key)
    [x(result.months), y(result.series.fetch(key).last)]
  end

  private

  def all_values
    result.series.values.flatten + result.invested
  end

  def path(values)
    values.each_with_index.map { |value, month| "#{month.zero? ? 'M' : 'L'}#{x(month).round(1)} #{y(value).round(1)}" }.join(" ")
  end

  def x_label(month)
    result.months > 24 ? (month / 12).to_s : month.to_s
  end

  # Rounds the top of the chart up to 1, 2, 2.5, 5 or 10 times a power of ten, so the five steps are tidy
  def nice_top(maximum)
    return 100.0 if maximum <= 0

    magnitude = 10**Math.log10(maximum / 5.0).floor
    step = [1, 2, 2.5, 5, 10].map { |factor| factor * magnitude }.find { |candidate| candidate * 5 >= maximum }
    step * 5.0
  end
end
