# A page to compare how a sum could grow in different kinds of investment. Everything is
# calculated on the server from the form (a plain GET), so it also works without JavaScript.
class SimulationsController < ApplicationController
  DEFAULT_INITIAL = "1000".freeze
  DEFAULT_MONTHLY = "0".freeze
  DEFAULT_MONTHS = 60

  def show
    @terms = InvestmentSimulator::TERMS
    @products = InvestmentSimulator::PRODUCTS
    @initial_text = params.fetch(:initial, DEFAULT_INITIAL).to_s
    @monthly_text = params.fetch(:monthly, DEFAULT_MONTHLY).to_s
    @months = @terms.key?(params[:months].to_i) ? params[:months].to_i : DEFAULT_MONTHS
    # The first visit has no form data yet: everything starts selected
    @selected = params.key?(:initial) ? Array(params[:products]).map(&:to_sym) & @products.map(&:key) : @products.map(&:key)

    @errors = validate
    return if @errors.any?

    @result = InvestmentSimulator.new(initial: @initial, monthly: @monthly, months: @months, product_keys: @selected).call
    @chart = SimulationChart.new(@result)
  end

  private

  def validate
    errors = []
    @initial = InvestmentSimulator.parse_money(@initial_text)
    @monthly = @monthly_text.strip.empty? ? 0.0 : InvestmentSimulator.parse_money(@monthly_text)

    if @initial.nil? || @initial.negative? || @initial > InvestmentSimulator::MAX_INITIAL
      errors << "Informe um valor inicial entre R$ 0 e R$ 10.000.000."
    end
    if @monthly.nil? || @monthly.negative? || @monthly > InvestmentSimulator::MAX_MONTHLY
      errors << "Informe um aporte mensal entre R$ 0 e R$ 1.000.000."
    end
    errors << "Escolha pelo menos um investimento para comparar." if @selected.empty?
    errors << "Informe um valor inicial ou um aporte mensal maior que zero." if errors.empty? && @initial.zero? && @monthly.zero?
    errors
  end
end
