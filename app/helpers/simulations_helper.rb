module SimulationsHelper
  MONTHS = %w[jan fev mar abr mai jun jul ago set out nov dez].freeze

  # R$ 1.234,56
  def brl(value)
    number_to_currency(value, unit: "R$ ", format: "%u%n", separator: ",", delimiter: ".", precision: 2)
  end

  # Short form for the axis: R$ 800, R$ 12 mil, R$ 2,5 mi
  def brl_short(value)
    value = value.to_f
    if value >= 1_000_000
      "R$ #{short_number(value / 1_000_000)} mi"
    elsif value >= 1000
      "R$ #{short_number(value / 1000)} mil"
    else
      "R$ #{short_number(value)}"
    end
  end

  def percent_br(value, precision: 1)
    "#{number_with_precision(value, precision: precision, separator: ',', delimiter: '.')}%"
  end

  # "2025-11" -> "nov/2025"
  def month_label(text)
    year, month = text.split("-")
    "#{MONTHS[month.to_i - 1]}/#{year}"
  end

  # The marker at the end of a line: a different shape for each investment
  def chart_marker(shape, x, y, color)
    size = 7
    case shape
    when :circle then tag.circle(cx: x.round(1), cy: y.round(1), r: size, fill: color, stroke: "#1b1411", "stroke-width": 2)
    when :square then tag.rect(x: (x - size).round(1), y: (y - size).round(1), width: size * 2, height: size * 2, fill: color, stroke: "#1b1411", "stroke-width": 2)
    when :triangle
      points = [[x, y - size - 2], [x + size + 2, y + size], [x - size - 2, y + size]].map { |px, py| "#{px.round(1)},#{py.round(1)}" }.join(" ")
      tag.polygon(points: points, fill: color, stroke: "#1b1411", "stroke-width": 2)
    else
      points = [[x, y - size - 2], [x + size + 2, y], [x, y + size + 2], [x - size - 2, y]].map { |px, py| "#{px.round(1)},#{py.round(1)}" }.join(" ")
      tag.polygon(points: points, fill: color, stroke: "#fff", "stroke-width": 2)
    end
  end

  # One sentence for people who cannot see the chart
  def simulation_summary(result, term_label)
    parts = result.products.map { |product| "#{product.name} chega a #{brl(result.final(product.key))}" }
    "Em #{term_label}, com #{brl(result.invested.first)} no início e #{brl(result.invested.last - result.invested.first)} em aportes, " \
      "o total investido é #{brl(result.invested.last)}. #{parts.join('; ')}."
  end

  private

  def short_number(value)
    rounded = value.round(1)
    text = rounded == rounded.to_i ? rounded.to_i.to_s : rounded.to_s.tr(".", ",")
    text
  end
end
