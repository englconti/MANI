# MANI — Spec de modernização: Visão geral

Status: **proposta, aguardando aprovação** · Data: 2026-10-30

Documentos:
- [01-backend.md](01-backend.md): versões (Ruby, Rails), banco, gems, lógica de jogo e segurança, deploy.
- [02-frontend.md](02-frontend.md): UX, acessibilidade, mobile, stack de front e design system.

Método: spec em fases (visão, requisitos, design técnico, tarefas). A skill `tlc-spec-driven` não estava instalada; foi usada uma estrutura equivalente.

## Ordem de execução recomendada

| Fase | Conteúdo | Origem |
|---|---|---|
| 0 | Limpeza do repositório, CI mínimo, `.env.example` | back T0.x, front F20 |
| 1 | Testes e correções rápidas (URL do Heroku, vidas em GET, i18n, performance) | back R1, front F1 F2 F14 F18 |
| 2 | Regras do jogo no servidor (XP único por lição, validação de resposta, autorização, ids estáveis) | back R2 R8 R9, front F3 |
| 3 | Lição usável e acessível no mobile | front F4 F5 F6 F16 F17 |
| 4 | Upgrade de plataforma: Rails 7.0 → 7.1 → 7.2 → 8.1, Ruby 3.4, Webpacker → esbuild, Turbolinks → Turbo | back R3-R7, front F8 |
| 5 | Redesign e gamificação (mapa, celebração, vidas, streak, home, cadastro) | front F9-F13 F15 F19 F21 |
| 6 | Produção: hospedagem, segurança, monitoramento | back R10-R13 |

## Andamento (2026-10-30)

**Fases 0 e 1 executadas** (alterações no working tree, sem commit):
- Limpeza: removidos `aaddassa`, `adsa`, `show.html copy.erb`, `_writing-original`, `hello_controller.js`, `typewriter.js`, `products.js`. Criados `.env.example` e CI (`.github/workflows/ci.yml`).
- Banco: credenciais locais via `DATABASE_USERNAME/PASSWORD/HOST` no `.env` (não mais `DATABASE_URL`, que sobrescreveria o banco de teste).
- Testes: 27 testes, 3 pulados de propósito (B-1, B-3, B-4, a corrigir na fase 2). Estrutura em `test/`.
- Correções: URL do Heroku removida do JS (F1); vidas não são mais alteradas por GET na tela de resumo, "Refazer aula" é um POST (F2); app em pt-BR com `rails-i18n` e `devise-i18n` (F14); `answers#update` responde 204; `populate_answers` sem ids fixos; HTML inválido, viewport duplicado e `<link>` 404 corrigidos; `lang="pt-BR"`.
- **Não feito:** T0.2 (o ajuste do bootsnap em `config/boot.rb` continua, necessário por causa do acento no caminho); remoção do kit Font Awesome do CDN (F18 parcial); `html_safe` nos enunciados (F20 parcial).

**Fase 2 executada** (branch `fase-2-regras-do-jogo`):
- B-1: tabela `lesson_completions`; XP/manis só recompensam a melhora sobre a melhor nota já premiada (visitar o resumo de novo não soma nada).
- B-2: o servidor corrige a resposta (`Answer#submit!`, `Question#correct?`); o JS de escrita envia as palavras digitadas, não o veredito.
- B-3: `answers#update` só alcança respostas do próprio usuário (outra pessoa recebe 404).
- B-4: `User#lose_life!` nunca passa de 0 e há validação `lives >= 0`.
- B-5: `lessons.position` (migração preserva a ordem atual); o perfil lista as lições por posição, sem ids fixos; respostas de perguntas novas são criadas sob demanda.
- 33 testes, sem pulados.
- **Decisão pendente:** a regra de vidas continua a atual (o perfil recarrega para 5). A lição "FII I" passou a aparecer no mapa: antes o código a calculava mas a tela não a exibia.

**Fase 3 executada** (branch `fase-3-licao-acessivel`):
- F6: um único botão no rodapé ("Verificar", que vira o link "Continuar" ou "Ver resumo").
- F4: alternativas são radios nativos (teclado, leitor de tela), atalhos A-D/1-4 e Enter, `aria-live` no feedback, `aria-label` nos ícones, barra com `role=progressbar`, palavras do exercício de escrita como botões com `aria-pressed`.
- F5: tela de pergunta mobile-first (1 coluna no celular, 2 no desktop, `dvh`, sem `vw` fixo, vidas como contador).
- F16: contraste revisado (≥ 4.5:1), estado certo/errado também por ícone (✔/✘), `prefers-reduced-motion`.
- F17: sons gerados pelo Web Audio (sem arquivos nem domínios externos); botão de som único, ligado por padrão.
- F3 (adiantado): o servidor devolve JSON com o resultado e a resposta certa só depois de responder; `#correct-answer` saiu do HTML.
- F7 (adiantado): um único `lesson_controller.js` substitui os 4 controllers antigos.
- F20: enunciados de escrita passam por `sanitize` em vez de `html_safe`.
- 38 testes, sem pulados. Conferido no navegador: pergunta abcd (desktop e celular), resposta errada e pergunta de escrita.

Observação: o front-end recomenda **esbuild** (jsbundling) como bundler; a spec de back-end deixou em aberto "importmap ou jsbundling". Considerar resolvida a favor do esbuild se você aprovar.

## Decisões que dependem de você

1. Bundler: esbuild (recomendado) ou importmap.
2. Hospedagem e orçamento.
3. Regra de vidas (regenerar por tempo, por lição ou manter o refill).
4. O app tem usuários reais hoje? (define o cuidado na migração de dados)
5. Prioridade entre correções de lógica, visual e upgrade de plataforma.
6. Novas funcionalidades previstas (streak, ranking, notificações).
