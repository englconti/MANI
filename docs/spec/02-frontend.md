# MANI — Spec de modernização: Front-end

Status: **proposta (nenhum código alterado)** · Data: 2026-10-30
Origem: análise feita por um agente de front-end sobre o app rodando em localhost:3000 e sobre o código. A skill `frontend-design` não estava disponível na sessão; foram aplicadas boas práticas equivalentes. Complementa `01-backend.md`.

**Cobertura da análise.** Vistas em tela: home, perfil (desktop e mobile), pergunta de múltipla escolha (desktop e mobile), resumo da lição e produtos (mobile). **Sem confirmação visual:** perguntas do tipo writing, cadastro, login, `/products/1`, `/friendships`. Vários SCSS, os partials de amigos e produtos e `friends_actions_controller.js` não foram lidos. Revisar essas áreas na fase de implementação.

## 1. Visão e metas

Tornar a experiência de lição mais clara, acessível e utilizável no celular, trocar a stack de front por uma suportada e dar ao app uma identidade visual consistente (o mascote porquinho é o fio condutor).

## 2. Diagnóstico

**Funciona bem:** mecânica estilo Duolingo reconhecível (barra de progresso, corações, cartões A/B/C/D, rodapé que muda de cor), botão "3D" com feedback tátil, resumo de aula com emoji e cor por desempenho, mascote, tom leve em português.

**Principais fraquezas:**
- **Mobile quebrado:** cartões de resposta em colunas de `15vw` com texto em 3-4 palavras por linha, corações quebrando em duas linhas, botões cortados, mapa de lições estourando a largura, imagem quebrada em `/products`. Só 2 `@media` no app inteiro; tudo em `vw`/`vh`.
- **Acessibilidade:** cartões são `<div>` clicáveis sem teclado nem `role`; sem `aria-live` no feedback; botões só com ícone; contraste insuficiente (`#6a6a81` sobre `#e5e5e5`, branco sobre cinza); cor como único indicador; sem `lang="pt-BR"`; HTML inválido; `html_safe` em enunciados (risco de XSS).
- **Fluxo de lição:** dois botões ("Confirmar" e "Próxima pergunta") em vez de um que muda de estado; sem tela de início/retomada; tooltip de lição fixo e quebrado (`data-toggle` do Bootstrap 4); `button_to ... method: :get` onde cabe `link_to`.
- **Gamificação rasa:** sem celebração no fim da aula, sem tela de "sem vidas", sem streak ou nível; corações são emoji concatenados; XP/M$ calculados na view e não vindos do servidor.
- **Código front:** controllers Stimulus duplicados (`next_question` e `wr_next_question`), uso de `document.querySelector` global, registro duplo de controllers contornado em `application.js`, `console.log` por toda parte, áudio de URLs externas em HTTP, mute com lógica invertida.
- **Bug crítico:** URL hardcoded do Heroku (`mani-finance.herokuapp.com`) e `location.replace` para https em `next_question_controller.js`: em localhost a resposta não é salva, ou é enviada para produção.
- **Segurança:** a resposta correta fica no DOM (`#correct-answer`), visível no inspetor.
- **Textos misturados:** "Sign up", "Login", "Log out", "Birthday" etc. em inglês numa app em português.
- **Performance:** Font Awesome duplicado (kit CDN + gem), `<link>` de `animate.css` com 404, CSS carregado por Sprockets e Webpacker ao mesmo tempo, Bootstrap JS inteiro, imagens sem dimensões.
- **Design system:** três conjuntos de cores que não conversam (`config/_colors.scss` x variáveis locais em `_question.scss`), hex soltos, estilos inline, `navbar-lewagon` herdada do template.

## 3. Tecnologia de front (recomendações)

| Tema | Recomendação |
|---|---|
| Bundler | **jsbundling-rails com esbuild + cssbundling (dart-sass)**. Importmap é mais simples, mas Bootstrap com Sass e vários módulos ficam melhores no esbuild. Vite seria uma peça a mais num app quase todo server-rendered. (A spec de back-end previa importmap *ou* jsbundling; este é o parecer do front e **decide a pendência**, sujeito à sua aprovação.) |
| Navegação | **Turbo (Hotwire)** no lugar do Turbolinks. Turbo Frames/Streams resolvem enviar resposta, atualizar vidas e trocar de pergunta sem `fetch` manual. `method: :delete` do logout vira `button_to`. |
| Stimulus | Manter, reorganizando em um `lesson_controller` com `targets/values/classes`. |
| CSS | Manter Bootstrap 5 via SCSS (só os módulos usados) + **tokens em CSS custom properties**. Tailwind só se houver redesign total. |
| Ícones | Um só provedor (SVG inline ou FA via npm), sem kit CDN. |
| Animações | CSS próprio com `prefers-reduced-motion`. |
| Fontes | Auto-hospedar Nunito; títulos em fonte arredondada (Baloo 2 ou Fredoka). |

## 4. Melhorias priorizadas

Esforço: P/M/G. Dependências com o back-end estão marcadas.

| ID | Melhoria | Esforço | Risco | Depende |
|---|---|---|---|---|
| F1 | Remover URL do Heroku e `location.replace`; usar URL gerada por `answer_path` | P | Baixo | — |
| F2 | Tirar o reabastecimento de vidas do GET (`lessons/show.html.erb:49-50`) para ação POST | P | Baixo | **Back-end** (ver B-4) |
| F3 | Validar resposta no servidor, tirar `#correct-answer` do DOM, devolver `{correct, lives, xp}` | M | Médio | **Back-end** (B-2, B-3) |
| F4 | Acessibilidade das perguntas: cartões como `<button>`/radio, foco visível, teclas 1-4 e Enter, `aria-live`, `lang="pt-BR"` | M | Baixo | — |
| F5 | Reflow mobile-first da pergunta: 1 coluna <640px, `dvh`, rodapé fixo, vidas como contador | M | Baixo | — |
| F6 | Botão único "Verificar → Continuar"; `link_to` no lugar de `button_to ... get` | P | Baixo | — |
| F7 | Unificar controllers Stimulus, remover `console.log` e Popper não usado | M | Médio | F1, F3 |
| F8 | Webpacker → jsbundling/cssbundling; Turbolinks → Turbo | G | Médio-alto | **Back-end** (R3, R4, R5) |
| F9 | Design system: tokens, paleta única, escala tipográfica, remover estilos inline | M | Baixo | — |
| F10 | Mapa de lições em trilha, com estados concluída/atual/bloqueada | M | Baixo | **Back-end** (`status` da lição, R8) |
| F11 | Tela de fim de aula com celebração; XP/M$ vindos do servidor | M | Baixo | **Back-end** (B-1, `lesson_completions`) |
| F12 | Tela "sem vidas"; vidas como componente | M | Baixo | **Back-end** (regra de vidas) |
| F13 | Streak diário e meta de XP | M | Médio | **Back-end** (modelo novo) |
| F14 | Traduzir tudo para pt-BR via `config/locales` | P | Baixo | — |
| F15 | Reescrever cadastro/login (largura fluida, `type="date"`, erros inline) | M | Baixo | — |
| F16 | Corrigir contraste; estado também por ícone/texto; `prefers-reduced-motion` | P | Baixo | F9 |
| F17 | Áudio local, pré-carregado, mute correto e acessível | P | Baixo | — |
| F18 | Performance: um só FA, remover `<link>` 404, Bootstrap parcial, fontes locais, imagens com dimensões e `loading="lazy"` | P | Baixo | URLs de imagem dos produtos |
| F19 | Home: proposta de valor, CTA primário/secundário, "como funciona" | M | Baixo | — |
| F20 | Limpeza: `show.html copy.erb`, `_writing-original`, JS dentro de `views`, `hello_controller`, HTML inválido, `html_safe` | P | Baixo | **Back-end** (sanitizar conteúdo) |
| F21 | Produtos e amigos: cards responsivos, estado vazio, seguir/deixar de seguir com Turbo | M | Baixo | **Back-end** |

**Ordem sugerida:**
1. Correções rápidas: F1, F2, F14, F18, F20.
2. Lição usável e acessível: F6, F4, F5, F16, F17.
3. Fundação: F9, F7, F3.
4. Migração de stack: F8.
5. Visual e gamificação: F10, F11, F12, F13, F15, F19, F21.

## 5. Direção de design

- **Paleta:** verde de ação `#58CC02` com texto escuro `#1B3A00`; azul `#0B7FBF` com texto branco (o azul claro `#1CB0F6` só com texto escuro); amarelo `#FFC800` para M$/recompensa; vermelho `#E5484D` para erro e vidas; neutros quentes (`#F7F7F5`, `#E5E5E0`, `#3C3C3C`); modo escuro opcional via custom properties. Todos os pares precisam passar 4.5:1 (validar na implementação).
- **Tipografia:** Nunito no texto; títulos e números de XP em fonte arredondada de peso alto; tamanhos fluidos com `clamp()`.
- **Componentes-chave:** botão 3D único (primário, secundário, perigo), cartão de resposta com estados (idle, foco, selecionado, correto, errado, com ícone), barra de progresso animada, chips de vidas/XP, nó de lição com 4 estados, banner de feedback no rodapé com explicação da resposta, modal de celebração, mascote reagindo (feliz, triste, pensando).
- **Movimento:** microanimações de 150 a 300 ms, desligáveis por `prefers-reduced-motion`.

## 6. Decisões pendentes

1. Aprovar o bundler (esbuild) ou preferir importmap (mais simples, menos flexível).
2. Manter o estilo Duolingo ou buscar identidade própria mais distante?
3. Modo escuro entra no escopo?
4. Quais telas têm prioridade? (sugestão: lição/pergunta e mapa de lições)
5. Idioma: só pt-BR ou preparar para outros?
