require "test_helper"

class SimulationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    sign_in @user
  end

  test "the simulator needs a login" do
    sign_out @user

    get simulator_url

    assert_redirected_to new_user_session_url
  end

  test "the first visit shows a simulation with every investment" do
    get simulator_url

    assert_response :success
    assert_select "title", text: "Simulador de investimentos · MANI"
    assert_select "svg.simulator-chart[role=img]"
    assert_select ".simulator-card", 4
    assert_select "input[name='products[]'][checked]", 4
    assert_select ".simulator-table-wrap tbody tr", 4
    assert_select "select#months option[selected]", text: "5 anos"
  end

  test "the form has the fields of the simulation" do
    get simulator_url

    assert_select "form[method=get][action='#{simulator_path}']"
    assert_select "input#initial[name=initial][value='1000']"
    assert_select "input#monthly[name=monthly][value='0']"
    assert_select "select#months option", InvestmentSimulator::TERMS.size
    assert_select "button[type=submit]", text: "Simular"
  end

  test "the numbers match the engine" do
    get simulator_url, params: { initial: "2000", monthly: "100", months: 12, products: %w[poupanca cdb] }

    expected = InvestmentSimulator.new(initial: 2000, monthly: 100, months: 12, product_keys: %i[poupanca cdb]).call
    assert_select ".simulator-card", 2
    assert_select ".simulator-card .card-value", text: ApplicationController.helpers.brl(expected.final(:poupanca))
    assert_select ".simulator-card .card-value", text: ApplicationController.helpers.brl(expected.final(:cdb))
    assert_select "table.simulator-table caption", text: "Valores ao fim de 1 ano"
  end

  test "only the chosen investments are drawn" do
    get simulator_url, params: { initial: "1000", months: 24, products: %w[acoes] }

    assert_select ".simulator-card h2", text: "Ações (Ibovespa)"
    assert_select ".simulator-card", 1
    assert_select ".chart-legend li", 2 # total invested + stocks
    assert_select "input[name='products[]'][checked]", 1
  end

  test "money typed the Brazilian way is understood" do
    get simulator_url, params: { initial: "1.500,50", monthly: "", months: 12, products: %w[poupanca] }

    assert_response :success
    assert_select ".simulator-error", 0
    assert_select ".simulator-cards .simulator-card", 1
  end

  test "a value that is not a number is explained" do
    get simulator_url, params: { initial: "muito", months: 12, products: %w[cdb] }

    assert_response :success
    assert_select ".simulator-error", text: /valor inicial/
    assert_select "svg.simulator-chart", 0
  end

  test "a negative or too large amount is refused" do
    get simulator_url, params: { initial: "-5", months: 12, products: %w[cdb] }
    assert_select ".simulator-error", text: /valor inicial/

    get simulator_url, params: { initial: "1000", monthly: "9999999999", months: 12, products: %w[cdb] }
    assert_select ".simulator-error", text: /aporte mensal/
  end

  test "with nothing chosen it asks for at least one investment" do
    get simulator_url, params: { initial: "1000", months: 12 }

    assert_select ".simulator-error", text: /pelo menos um investimento/
  end

  test "zero in both fields is explained" do
    get simulator_url, params: { initial: "0", monthly: "0", months: 12, products: %w[cdb] }

    assert_select ".simulator-error", text: /maior que zero/
  end

  test "a term that is not offered falls back to five years" do
    get simulator_url, params: { initial: "1000", months: 7, products: %w[cdb] }

    assert_select "select#months option[selected]", text: "5 anos"
  end

  test "an unknown investment key is ignored" do
    get simulator_url, params: { initial: "1000", months: 12, products: %w[cdb bitcoin] }

    assert_select ".simulator-card", 1
  end

  test "the chart can be understood without seeing it" do
    get simulator_url, params: { initial: "1000", months: 12, products: %w[poupanca] }

    assert_select "svg title", text: /Projeção do dinheiro/
    assert_select "svg text.axis-title", text: "Prazo em meses"
    assert_select "svg desc", text: /Poupança chega a R\$/
    assert_select "table.simulator-table th[scope=col]"
    assert_select "table.simulator-table th[scope=row]", text: "Poupança"
  end

  test "each line has its own dash or marker, not only a colour" do
    get simulator_url

    assert_select "svg.simulator-chart path.chart-line[stroke-dasharray]", minimum: 2
    assert_select "svg.simulator-chart circle, svg.simulator-chart rect, svg.simulator-chart polygon", minimum: 4
  end

  test "the page says it is a simulation, with no taxes and a source for the Ibovespa" do
    get simulator_url

    assert_select ".disclaimer", text: /não é recomendação de investimento/i
    assert_select ".simulator-notes", text: /não descontam Imposto de Renda|não descontam/i
    assert_select ".simulator-notes", text: /0,5%/
    assert_select ".simulator-notes", text: /0,8%/
    assert_select ".simulator-notes", text: /0,85%/
    assert_select ".simulator-notes a[href^='https://'][rel=noopener]", minimum: 1
    assert_select ".simulator-notes details tbody tr", 12
  end

  test "the stocks line can lose money in a short term" do
    get simulator_url, params: { initial: "1000", months: 6, products: %w[acoes] }

    assert_response :success
    assert_select ".simulator-card .card-gain", text: /Ganho de|Perda de/
  end

  test "the navigation links to the simulator" do
    get user_url(@user)

    assert_select "nav a.nav-link[href='#{simulator_path}']", text: "Simulador"
    assert_select "a.feature-card[href='#{simulator_path}']"
  end
end
