require "yaml"

# Projects how a sum of money would grow in a few kinds of investment. It is a teaching tool:
# the rates are fixed and made up for comparison, taxes, fees and inflation are not counted,
# and the "Ações" line repeats the monthly changes of the Ibovespa over the last 12 months.
class InvestmentSimulator
  Product = Struct.new(:key, :name, :summary, :monthly_rate, :color, :dash, :shape, keyword_init: true)

  # Fixed rates, per month. Each line has its own colour, dash and end marker, so it can be told
  # apart without relying on colour alone.
  PRODUCTS = [
    Product.new(key: :poupanca, name: "Poupança", summary: "0,5% ao mês", monthly_rate: 0.005,
                color: "#0e6b78", dash: nil, shape: :circle),
    Product.new(key: :cdb, name: "CDB", summary: "0,8% ao mês", monthly_rate: 0.008,
                color: "#d9503a", dash: "9 5", shape: :square),
    Product.new(key: :lci_lca, name: "LCI / LCA", summary: "0,85% ao mês", monthly_rate: 0.0085,
                color: "#2f9a5a", dash: "2 4", shape: :triangle),
    Product.new(key: :acoes, name: "Ações (Ibovespa)", summary: "curva do último ano do Ibovespa",
                monthly_rate: nil, color: "#1b1411", dash: nil, shape: :diamond)
  ].freeze

  TERMS = { 6 => "6 meses", 12 => "1 ano", 24 => "2 anos", 36 => "3 anos", 60 => "5 anos",
            120 => "10 anos", 240 => "20 anos" }.freeze

  MAX_INITIAL = 10_000_000
  MAX_MONTHLY = 1_000_000

  Result = Struct.new(:months, :series, :invested, :products, keyword_init: true) do
    def final(key) = series.fetch(key).last
    def gain(key) = final(key) - invested.last
    def gain_percent(key) = invested.last.zero? ? 0.0 : gain(key) * 100.0 / invested.last
    def best = products.max_by { |product| final(product.key) }
  end

  class << self
    def product(key)
      PRODUCTS.find { |product| product.key == key.to_sym }
    end

    def data
      @data ||= YAML.safe_load_file(Rails.root.join("config/ibovespa.yml"))
    end

    # Monthly changes of the Ibovespa as fractions (6.37 -> 0.0637), oldest first
    def ibovespa_returns
      data.fetch("months").map { |entry| entry.fetch("change") / 100.0 }
    end

    # What the Ibovespa did over those 12 months, in %
    def ibovespa_year_percent
      (ibovespa_returns.reduce(1.0) { |total, change| total * (1 + change) } - 1) * 100
    end

    # "1.234,56", "1234,56", "1234.56", "1.500" and "R$ 1.000" all become a number; anything else is nil.
    # Dots in groups of three digits ("1.500") are thousand separators; with a comma, dots always are.
    def parse_money(text)
      value = text.to_s.strip.delete_prefix("R$").strip
      return nil if value.empty?

      value = if value.include?(",") || value.match?(/\A\d{1,3}(\.\d{3})+\z/)
                value.delete(".").tr(",", ".")
              else
                value
              end
      Float(value)
    rescue ArgumentError
      nil
    end
  end

  attr_reader :initial, :monthly, :months, :products

  def initialize(initial:, monthly: 0, months: 60, product_keys: PRODUCTS.map(&:key))
    @initial = initial.to_f
    @monthly = monthly.to_f
    @months = months.to_i
    keys = product_keys.map(&:to_sym)
    @products = PRODUCTS.select { |product| keys.include?(product.key) }
  end

  def call
    Result.new(months: months, products: products, invested: invested_series,
               series: products.to_h { |product| [product.key, project(product)] })
  end

  private

  # Money put in so far: the first sum plus one deposit at the end of each month
  def invested_series
    (0..months).map { |month| (initial + monthly * month).round(2) }
  end

  # Each month the balance earns the month's rate and then the deposit comes in
  def project(product)
    balance = initial
    values = [balance.round(2)]
    (1..months).each do |month|
      balance = balance * (1 + rate_for(product, month)) + monthly
      values << balance.round(2)
    end
    values
  end

  def rate_for(product, month)
    return product.monthly_rate if product.monthly_rate

    returns = self.class.ibovespa_returns
    returns[(month - 1) % returns.size]
  end
end
