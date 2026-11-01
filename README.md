# MANI

App de educação financeira gamificado (lições, perguntas, XP, vidas e amigos).
Rails 8.1, Ruby 3.4, PostgreSQL, Hotwire (Turbo + Stimulus), Propshaft, esbuild e Sass.

## Requisitos

- Ruby 3.4 (veja `.ruby-version`)
- Node 22 ou mais novo e Yarn 1
- PostgreSQL 17 ou mais novo

## Configuração

```bash
cp .env.example .env     # ajuste usuário e senha do PostgreSQL
bundle install
yarn install
bin/rails db:create db:schema:load db:seed
```

## Rodar em desenvolvimento

Em Linux e macOS:

```bash
bin/dev                  # servidor + build do JS e do CSS em modo watch
```

Em Windows (sem foreman), em terminais separados:

```bash
yarn build --watch
yarn build:css --watch
bin/rails server
```

Os arquivos gerados ficam em `app/assets/builds` (ignorados pelo Git).
No Windows, rode as tarefas do Rails com `SKIP_CSS_BUILD=1`, porque o cssbundling usa `command -v`, que só existe em shells POSIX; gere o CSS com `yarn build:css`.

## Testes

```bash
yarn build && yarn build:css
bin/rails test
```

Veja o plano de modernização e o andamento em [docs/spec](docs/spec/00-overview.md).
