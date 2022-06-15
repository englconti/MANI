require "csv"

# Creating Products ------------------------------------------------
puts "-=-=-=-=- CREATING PRODUCTS -=-=-=-=-"
products_path = "db/data/Mani - products_starter.csv"
CSV.foreach(products_path, headers: :first_row) do |row|
  if Product.find_by(title: row['title']).nil?
    Product.create!(title: row['title'],
                    description: row['description'],
                    definition: row['definition'],
                    kind: row['kind'],
                    how_to_invest: row['how_to_invest'])
    puts "Product created: #{Product.last.title}"
  end
end
# -------------------------------------------------------------------

# Creating Lessons -------------------------------------------------
puts "-=-=-=-=- CREATING LESSONS -=-=-=-=-"
lessons_path = "db/data/Mani - lessons_starter.csv"
CSV.foreach(lessons_path, headers: :first_row) do |row|
  if Lesson.find_by(title: row['title']).nil?
    Lesson.create!(title: row['title'], description: row['description'])
    puts "Lesson created: #{Lesson.last.title}"
  end
end
# ------------------------------------------------------------------

# Creating Questions -----------------------------------------------
puts "-=-=-=-=- CREATING QUESTIONS -=-=-=-=-"
questions_path = "db/data/Mani - questions_starter.csv"
# questions_path = "#{__FILE__}/../db/data/questions_starter.csv"
skipper = true
CSV.foreach(questions_path, headers: :first_row) do |row|
  if skipper
    # uncomment line bellow when all questions have different parameters
    # if Question.where(lesson: Lesson.find_by(title: row['lesson_title']), statement: row['statement'], a: row['a'])[0].nil?
    Question.create!(lesson: Lesson.find_by(title: row['lesson_title']),
                     question_type: row['question_type'],
                     level: row['level'],
                     statement: row['statement'],
                     a: row['a'],
                     b: row['b'],
                     c: row['c'],
                     d: row['d'],
                     img_url: row['img_url'],
                     correct_answer: row['correct_answer'])
    puts "Question created: #{Question.last.statement}"
  end
end
# ------------------------------------------------------------------

# creating Products -------------------------
# Product.create!([
#                   { title: "LCI/LCA", description: nil, definition: "Sigla para Letras de Crédito Imobiliário,a LCI funciona para o investidor como um empréstimo
#                     fornecido aos bancos que, por sua vez, usam o capital para investir em empreendimentos do setor imobiliário.
#                     Ao investir em uma LCI, o investidor está  oferecendo um empréstimo ao banco em troca de uma rentabilidade
#                     A LCA é a Letra de Crédito do Agronegócio. Ela também é um título renda fixa emitido pelos bancos.
#                     A diferença para a LCI é o foco de investimento.
#                     Neste caso, a captação é direcionada para financiar as atividades do setor do agronegócio. ", kind: "Prefixados: têm taxa de juro fixa, definida ainda na aplicação, o que permite ao investidor saber quanto vai receber no vencimento. Exemplo: 10% ao ano.
#                     Pós-fixados: têm rendimento atrelado a algum índice econômico, como Selic, DI ou IPCA, com variação ao longo do tempo. Exemplo: 100% do CDI.
#                     Híbridos: unem a taxa prefixada com um índice econômico para compensar a variação da taxa pós-fixada. Exemplo: CDI + 3% ao ano.", how_to_invest: "As Letras de Crédito estão disponíveis em bancos e corretoras de investimentos habilitados para a emissão desses títulos.
#                     Para aplicar, o investidor precisa ter CPF em situação regular, uma conta e o valor disponível.
#                     As LCIs e LCAs ficam listadas no home broker do banco com as outras opções de investimentos em renda fixa. Durante a operação,
#                     é preciso escolher a opção que melhor se encaixa aos objetivos, considerando montante, liquidez e juros." },
#                   { title: "CRI/CRA", description: nil, definition: "Sigla para Certificados de Recebíveis Imobiliários e Certificados de Recebíveis Agrícolas, respectivamente, CRI e CRA são
#                     são títulos de renda fixa. Eles são lastreados em operações de crédito ligadas ao setor de imóveis e do agronegócio, respectivamente.
#                     Os títulos são usados para antecipar os recebimentos da empresa que emite o crédito.
#                     Dessa forma, o investidor pode receber o valor investido acrescido de juros do emissor periodicamente ou na data de vencimento do certificado.
#                     Para viabilizar a operação, as empresas que concedem o crédito contratam companhias privadas para emitir os títulos.
#                     Elas são conhecidas como securitizadoras e são responsáveis por disponibilizar as aplicações aos investidores interessados.", kind: "Prefixados: têm taxa de juro fixa, definida ainda na aplicação, o que permite ao investidor saber quanto vai receber no vencimento. Exemplo: 10% ao ano.
#                     Pós-fixados: têm rendimento atrelado a algum índice econômico, como Selic, DI ou IPCA, com variação ao longo do tempo. Exemplo: 100% do CDI.
#                     Híbridos: unem a taxa prefixada com um índice econômico para compensar a variação da taxa pós-fixada. Exemplo: CDI + 3% ao ano.", how_to_invest: "É possível investir sozinho em CRI (assim como em CRA), diretamente com a securitizadora, ou por meio de uma corretora,
#                     dentro de uma carteira de fundos de investimentos. Alguns CRI podem ser adquiridos pelo valor mínimo de R$ 1.000.
#                      Já outros somente investidores profissionais ou qualificados podem adquirir, com valores iniciais bem mais elevados." },
#                   { title: "Tesouro direto", description: nil, definition: "Criado em 2002, o Tesouro Direto foi desenvolvido pelo governo federal para captar recursos e financiar as dívidas públicas.
#                     Sob gestão do Tesouro Nacional, ele se assemelha a uma operação de crédito pessoal,
#                     em que uma pessoa física ou jurídica empresta dinheiro ao governo em troca de um rendimento futuro.
#                     Nos últimos anos, esse tipo de investimento tem crescido entre a população,
#                     especialmente pela facilidade em se aplicar e pelo baixo risco de crédito. Na operação, o investidor compra um título público por um preço e,
#                     tempos depois, recebe aquela mesma importância acrescida de juros.
#                     Ao emitir um título de crédito, o Tesouro Direto define o valor de cada unidade, a remuneração a ser paga por ela e a data de vencimento.", kind: "Títulos prefixados: têm uma taxa de juro fixa, definida ainda na aplicação, o que permite ao investidor saber quanto vai receber no vencimento.
#                     Exemplo: 10% ao ano.
#                    Pós fixado: também chamados de Tesouro Selic, têm rendimento proporcional à taxa básica de juros, portanto, contam com variação ao longo do tempo.
#                     Exemplo: Selic + 0,5% ao ano.
#                    Híbridos (IPCA+): são corrigidos pelo resultado da inflação, medida pelo Índice Nacional de Preços ao Consumidor Amplo,
#                    e carregam alguma porcentagem adicional para garantir uma remuneração maior do que a taxa inflacionária. Exemplo: IPCA + 5% ao ano.", how_to_invest: "Para aplicar no Tesouro Direto, o interessado precisa ter CPF em situação regular, além de cadastro em um banco ou corretora de investimentos.
#                     Inicialmente, no caso de quem nunca investiu, é necessário responder um questionário que indica se o perfil do investidor é aderente àquele produto.
#                    Depois disso, é preciso acessar a tela de investimentos do aplicativo financeiro e escolher uma das opções, de acordo com o valor,
#                    a remuneração e a data de vencimento. Há bancos oferecem essa aplicação de forma gratuita, sem cobrar taxa. No site do Tesouro Nacional,
#                    há uma lista com todas as instituições habilitadas." },
#                   { title: "Ações", description: nil, definition: "Se uma empresa fosse um bolo, as ações seriam pequeninas fatias que podem ser compradas por qualquer pessoa interessada em ter seu pedaço do doce.
#                     Ou seja, comprar uma ação significa virar dono daquele pedacinho da empresa. Para isso acontecer, a empresa precisa ser uma
#                     Sociedade Anônima de Capital Aberto e estar devidamente registrada na Comissão de Valores Mobiliários (CVM),
#                      órgão estatal responsável por regular e fiscalizar o mercado de valores mobiliários brasileiros.", kind: "Os tipos mais conhecidos são ações ordinárias (ON), ações preferenciais (PN) e units.
#                      As ações ordinárias dão direito a voto nas assembleias gerais e participação nas decisões das empresas.
#                      Já as ações preferenciais não dão poder de voto nas assembleias, mas oferecem preferência em caso de distribuição de lucros e compensações.
#                      As units são um ativo composto: quando uma pessoa compra uma unit, ela está comprando ações de diferentes tipos num único pacote.
#                       Ela pode ser composta por duas ações preferenciais e uma ação ordinária, por exemplo.", how_to_invest: "Para negociar na bolsa, o investidor precisa ter conta em uma corretora, instituição financeira autorizada a operar no pregão.
#                       Elas recebem as ordens de compra ou de venda e executam as operações na B3 em nome deles." },
#                   { title: "FIIs", description: nil, definition: "Um fundo imobiliário é uma espécie de “condomínio” de investidores, que reúnem seus recursos para que sejam aplicados em conjunto
#                     no mercado imobiliário. A dinâmica mais tradicional é que o dinheiro seja usado na construção ou na aquisição de imóveis,
#                     que depois sejam locados ou arrendados. Os ganhos obtidos com essas operações são divididos entre os participantes,
#                     na proporção em que cada um aplicou.
#                     As decisões sobre o que fazer com os recursos são tomadas pelo gestor do fundo e precisam seguir objetivos e políticas pre-definidos.
#                     Os investimentos podem ser bem-sucedidos ou não, e isso determinará a valorização ou a desvalorização das cotas dos fundos.", kind: "Os tipos mais conhecidos são fundos de papel e fundos de tijolo.
#                     Os Fundos Imobiliários de papel são investimentos de Renda Variável que aplicam o patrimônio dos seus cotistas em instrumentos
#                      financeiros do setor imobiliário, tais como CRIs, LCIs e LHs. Eles também distribuem ao menos 95% do resultado líquido aos cotistas.
#                    Os Fundos Imobiliários de tijolo são investimentos de Renda Variável que aplicam o seu patrimônio na construção e/ou exploração comercial
#                     de imóveis físicos. Ao menos 95% dos resultados é distribuído regularmente entre os cotistas. Os fundos de tijolo podem ser de vários tipos,
#                      como por exemplo, lajes corporativas, shoppings centers, galpões de logística, agências bancárias etc.", how_to_invest: "Para comprar um fii, o investidor precisa ter conta em uma corretora, instituição financeira autorizada a operar no pregão.
#                      Elas recebem as ordens de compra ou de venda e executam as operações em nome deles." },
#                   { title: "CDB", description:  nil, definition: "Sigla para Certificado de Depósito Bancário,o CDB é um investimento de renda fixa que oferece rendimento
#                     de acordo com o período de aplicação. Ele funciona como uma operação de crédito pessoal,em que o
#                     investidor empresta uma quantia para as instituições financeiras visando remuneração futura.", kind: "Os títulos privados são divididos em três categorias: prefixados, pós-fixados e híbridos.Veja:
#                     Prefixados: têm taxa de juro fixa, definida ainda na aplicação, o que permite ao investidor saber quanto vai receber no vencimento. Exemplo: 10% ao ano.
#                     Pós-fixados: têm rendimento atrelado a algum índice econômico, como Selic, DI ou IPCA, com variação ao longo do tempo. Exemplo: 100% do CDI.
#                     Híbridos: unem a taxa prefixada com um índice econômico para compensar a variação da taxa pós-fixada. Exemplo: CDI + 3% ao ano.", how_to_invest: " Para usar qualquer produto financeiro, o investidor precisa ter CPF em situação regular e cadastro
#                     em um banco ou corretora. Antes do primeiro investimento, deve responder um questionário que indica
#                       quais os produtos mais indicados para o perfil do investidor.

#                     Na sequência, é preciso acessar o home broker (tela de investimentos do aplicativo financeiro), buscar
#                     por renda fixa e clicar na opção de CDB. Feito isso, entre as opções disponíveis, escolha a que melhor
#                       atenda seu objetivo, considerando valor mínimo, remuneração e data de vencimento. A maioria dos bancos
#                       não cobra taxas por essa operação.

#                     No vencimento do CDB, o valor aplicado é devolvido ao investidor acrescido de juros pela operação, na
#                     mesma conta corrente. Nos casos de produtos com liquidez diária, é possível resgatar o valor a qualquer
#                       momento ou esperar pela data final." }
#                 ])
# --------------------------------------------
