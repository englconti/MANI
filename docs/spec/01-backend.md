# MANI — Spec de modernização: Back-end

Status: **proposta (nenhum código alterado)** · Data: 2026-10-30

## 1. Visão e metas

O MANI é um app de educação financeira gamificado (lições, perguntas, XP, vidas, "manis", amigos). Foi escrito em 2022 e hoje roda localmente, mas sobre uma base sem suporte.

Metas do back-end:
1. Sair de versões sem patch de segurança (Ruby 3.0, Rails 6.1, Webpacker 5).
2. Corrigir falhas de lógica e segurança que afetam a gamificação (XP, vidas, respostas).
3. Criar uma rede de testes antes de mudar o comportamento.
4. Deixar deploy e configuração reproduzíveis.

Fora do escopo desta spec: novas funcionalidades de produto e redesign (ver `02-frontend.md`).

## 2. Situação atual (verificada no repositório)

| Item | Hoje | Situação |
|---|---|---|
| Ruby | 3.0.7 | Fim de vida. Atuais: 3.4 (manutenção normal até mar/2028), 4.0 (estável, lançado dez/2025), 3.3 (só segurança, até mar/2027). |
| Rails | 6.1.6 | Sem suporte. Linha atual: 8.1. A 8.0 chega ao fim em 07/11/2026, então o alvo é a 8.1. |
| Front build | Webpacker 5 + webpack 4 + Node 16 | Descontinuado; exige Node antigo. |
| Banco | PostgreSQL (17 local) | OK. Schema simples, 7 tabelas. |
| Auth | Devise 4.8.1 | Desatualizado, mas é a escolha certa; só precisa de upgrade. |
| Gems | simple_form via GitHub (sem versão), pg_search 2.3, redis 4, spring, webdrivers, font-awesome-sass 5.6 | Várias paradas ou desnecessárias (ver §4). |
| Testes | `test/` só com stubs gerados | Efetivamente **sem cobertura**. |
| CI / deploy | Nenhum arquivo (Procfile, workflow); CORS aponta para Heroku antigo | Indefinido. |

## 3. Problemas de lógica e segurança encontrados no código

Prioridade alta (afetam integridade do jogo ou segurança):

- **B-1 — XP e manis por GET.** `LessonsController#show` soma XP e manis a cada visita à página, então recarregar a lição infla a pontuação (`app/controllers/lessons_controller.rb:17-20`).
- **B-2 — Resposta confiada ao cliente.** Em perguntas do tipo `writing`, `AnswersController#update` aceita `params[:answer]` como o resultado (certo/errado) vindo do navegador. Qualquer um pode se declarar correto (`app/controllers/answers_controller.rb:13-18`).
- **B-3 — Falta de autorização em respostas.** `answers#update` busca `Answer.find(params[:answer_id])` sem checar se pertence ao `current_user`.
- **B-4 — Vidas sempre recarregadas.** `UsersController#show` restaura as vidas para 5 a cada visita ao perfil (`app/controllers/users_controller.rb:59-62`), e as vidas podem ficar negativas porque não há validação.
- **B-5 — Ids fixos e contíguos.** `render_lesson(1..7)` e `User#populate_answers` assumem que lições e perguntas têm ids sequenciais a partir de 1. Apagar ou reordenar uma pergunta quebra perfil e cadastro (`users_controller.rb:10-23,49-57`, `user.rb:25-32`).
- **B-6 — Estado em `puts`.** Logs com emoji e `puts` no controller; sem logger nem tratamento de erro.

Prioridade média:

- **B-7 — Amizades.** `create` com `receiver` inexistente (`nil`) tenta salvar e renderiza `new` sem mensagem de erro; faltam validações de unicidade e de auto-amizade; `index` e `new` são rotas GET sem ação útil.
- **B-8 — Rotas.** `get 'friendships/new|create|index|destroy'` soltos, além do `resources`; e `/users` (index) vazio.
- **B-9 — `answers#create`** declarado como rota, mas sem implementação; `questions#create` está na rota sem ação.
- **B-10 — N+1 e consultas manuais** em `find_friends` e `render_lesson`.
- **B-11 — Sem seeds idempotentes** para perguntas (cria duplicados se rodar duas vezes).
- **B-12 — `config/credentials.yml.enc` sem `master.key` no repositório**; o CORS aponta para um domínio antigo.

## 4. Requisitos de modernização

| ID | Requisito | Benefício | Esforço | Risco |
|---|---|---|---|---|
| R1 | Criar suíte de testes (models, controllers, 1-2 testes de sistema do fluxo de lição) **antes** do upgrade | Rede de segurança | M | Baixo |
| R2 | Corrigir B-1 a B-5 (regras de jogo no servidor) | Integridade do jogo | M | Médio (muda comportamento) |
| R3 | Upgrade em etapas: Ruby 3.1 + Rails 7.0 → 7.1 → Ruby 3.3 + Rails 7.2 → Rails 8.1 (Ruby 3.4) | Segurança e suporte | G | Médio |
| R4 | Trocar Webpacker por **importmap** (ou jsbundling/Vite se o front exigir build) e Sprockets por **Propshaft** | Remove Node 16 e webpack 4 | M | Médio |
| R5 | Turbolinks → **Turbo (Hotwire)**; manter Stimulus | Alinha com Rails 7/8 | M | Baixo |
| R6 | Atualizar Devise (4.9+), pg_search, simple_form (versão do RubyGems, não do GitHub) | Segurança | P | Baixo |
| R7 | Remover gems desnecessárias: `spring`, `webdrivers`, `redis` (se o Action Cable não for usado), `listen`/`wdm` conforme o caso | Menos manutenção | P | Baixo |
| R8 | Modelagem: tornar a ordem das lições explícita (`position`), associar `lessons → questions → answers` por chaves, gerar `answers` sob demanda (ou ao concluir) em vez de pré-popular para cada usuário | Remove B-5, escala melhor | M | Médio (migração de dados) |
| R9 | Regras de domínio em services/modelos (`AnswerSubmission`, `LessonCompletion`); validações (`lives >= 0`, unicidade de amizade) | Código testável | M | Baixo |
| R10 | Segurança: Brakeman e bundler-audit no CI, `config.force_ssl`, CSP real, CORS atualizado, credenciais documentadas | Segurança | P | Baixo |
| R11 | CI (GitHub Actions: testes + rubocop + brakeman) e `.env.example` | Reprodutibilidade | P | Baixo |
| R12 | Deploy: decidir plataforma (Render, Fly.io, Railway ou Kamal em VPS) e usar `DATABASE_URL`; o Rails 8 traz Solid Queue/Cache/Cable sem Redis | Produção estável | M | Médio |
| R13 | Banco: manter PostgreSQL (subir para 17/18 em produção), adicionar índices e `NOT NULL`/FKs que faltam, `db/seeds` idempotente | Consistência | P | Baixo |

## 5. Design técnico (decisões propostas)

- **Rails:** ir direto para 8.1 como alvo, passando por 7.0, 7.1 e 7.2 (um upgrade de cada vez, com testes verdes entre eles). Não parar na 8.0, que acaba em 07/11/2026.
- **Ruby:** 3.4 como alvo (suportado até 2028, ampla compatibilidade de gems). Ruby 4.0 só depois de as gems principais o suportarem.
- **Assets/JS:** importmap + Propshaft + Stimulus + Turbo, se o front-end novo não precisar de bundler. Se a proposta de front exigir TypeScript ou componentes pesados, usar jsbundling-rails com esbuild. A decisão final fica para depois da spec de front-end.
- **Autenticação:** continuar com Devise (não migrar para o gerador nativo do Rails 8, sem ganho para este app).
- **Jobs/cache/cable:** Solid Queue, Solid Cache e Solid Cable (padrão do Rails 8), sem Redis, a menos que haja uso real de Action Cable.
- **Regras de jogo:** a resposta é validada **no servidor** (o cliente envia apenas a opção escolhida ou o texto), XP e manis são concedidos uma única vez por lição concluída (`lesson_completions` com índice único por usuário e lição), e as vidas se regeneram por tempo ou por regra de produto definida (decisão pendente).
- **Banco:** PostgreSQL; migrações com `strong_migrations` para upgrades seguros.

## 6. Tarefas em fases

**Fase 0 — Preparação** (pequena)
- T0.1 Repositório limpo: remover `aaddassa`, `adsa`, `show.html copy.erb`; criar `.env.example`.
- T0.2 Reverter o workaround do bootsnap em `config/boot.rb` quando houver upgrade (ou mover o projeto para um caminho sem acentos).
- T0.3 CI mínimo (rodar testes, rubocop, brakeman).

**Fase 1 — Rede de segurança**
- T1.1 Testes de modelos e controllers atuais (R1), incluindo o fluxo cadastro → lição → pergunta → perfil.
- T1.2 Testes que reproduzem B-1 a B-5 (falham hoje, passam depois).

**Fase 2 — Correções de lógica** (R2, R8, R9)
- T2.1 `lesson_completions` e XP idempotente.
- T2.2 Validação de respostas no servidor e autorização por usuário.
- T2.3 Vidas: regra definida, sem negativos.
- T2.4 `position` em lições e remoção dos ids fixos.

**Fase 3 — Upgrades de plataforma** (R3 a R7)
- T3.1 Rails 6.1 → 7.0 (Ruby 3.1).
- T3.2 7.0 → 7.1 → 7.2 (Ruby 3.3); troca Webpacker → importmap/jsbundling; Turbolinks → Turbo.
- T3.3 7.2 → 8.1 (Ruby 3.4); Propshaft; Solid Queue/Cache/Cable.
- T3.4 Atualizar Devise e demais gems; remover as desnecessárias.

**Fase 4 — Produção** (R10 a R13)
- T4.1 Escolha da plataforma, variáveis de ambiente, credenciais.
- T4.2 Segurança (force_ssl, CSP, CORS) e monitoramento de erros.

## 7. Decisões pendentes

1. Onde o app será hospedado e qual o orçamento?
2. Regra de vidas: regenerar por tempo, por lição ou manter o refill atual?
3. O app já tem usuários reais? Se sim, é preciso uma migração de dados cuidadosa em R8.
4. Haverá novas funcionalidades (ranking, streaks, notificações) que influenciem a escolha de jobs e cache?
5. Aceita-se uma janela de "congelamento" de funcionalidades durante as fases 1 a 3?

## Fontes

- [endoflife.date — Ruby](https://endoflife.date/ruby) e [ruby-lang.org — branches](https://www.ruby-lang.org/en/downloads/branches/)
- [isitpatched.com — Rails](https://isitpatched.com/rails) (datas de suporte; conferir em rubyonrails.org/maintenance)
