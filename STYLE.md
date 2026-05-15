# STYLE.md — Focus App

> Este arquivo define as diretrizes visuais do projeto Focus.
> Todo agente ou desenvolvedor que trabalhar no front-end **deve seguir esta paleta e estas regras**.
> Nenhuma cor, fonte ou espaçamento deve ser escolhido arbitrariamente — tudo aqui tem justificativa para o público com dislexia e TDH.

---

## Stack de estilo

- **TailwindCSS** — utilitários base
- **Fonte principal:** [OpenDyslexic](https://opendyslexic.org/) — aplicada por padrão para todos os alunos com perfil dislexia ou ambos
- **Fonte secundária (fallback):** `Arial, sans-serif`
- **Fonte mínima:** `16px` / `text-base` no Tailwind — nunca abaixo disso

---

## Paleta de Cores

### Filosofia
Fundo branco puro (`#FFFFFF`) aumenta o ofuscamento para pessoas com dislexia (efeito Irlen). Cores saturadas e vibrantes aumentam a distração para pessoas com TDH. A paleta do Focus é **suave, quente e de baixo contraste excessivo** — legível sem agredir.

---

### 🎨 Cores Primárias

| Nome | Hex | Tailwind | Uso |
|---|---|---|---|
| `focus-blue` | `#3B6FE8` | `blue-600` aprox. | Botões primários, links, nível/XP |
| `focus-blue-dark` | `#1E40AF` | `blue-800` | Títulos, ícones ativos |
| `focus-blue-light` | `#DBEAFE` | `blue-100` | Fundos de cards, destaques suaves |

> **Por quê azul?** O azul de média saturação é amplamente associado a foco e calma na psicologia das cores, sem a ansiedade que tons quentes (vermelho, laranja) causam em pessoas com TDH.

---

### 🟡 Cor de Fundo Principal

| Nome | Hex | Tailwind | Uso |
|---|---|---|---|
| `focus-bg` | `#FAFAF7` | `stone-50` aprox. | Fundo geral de todas as telas |
| `focus-bg-card` | `#F5F5EF` | `stone-100` aprox. | Fundo de cards e painéis |

> **Por quê não branco puro?** O fundo levemente amarelado/bege (`#FAFAF7`) reduz o ofuscamento causado pelo contraste excessivo entre texto escuro e fundo branco — uma das principais queixas de pessoas com dislexia. Pesquisas indicam melhora significativa na leitura com fundos off-white ou levemente coloridos.

---

### ✅ Cores de Feedback (Positivo / Neutro / Atenção)

| Nome | Hex | Tailwind | Uso |
|---|---|---|---|
| `focus-success` | `#16A34A` | `green-600` | Acerto, conquista desbloqueada, XP ganho |
| `focus-success-light` | `#DCFCE7` | `green-100` | Fundo de mensagem de acerto |
| `focus-warning` | `#CA8A04` | `yellow-600` | Atenção, dica, lembrete suave |
| `focus-warning-light` | `#FEF9C3` | `yellow-100` | Fundo de dica |
| `focus-neutral` | `#6B7280` | `gray-500` | Textos secundários, labels, metadados |

> ⚠️ **NUNCA use vermelho para indicar erro.** Para o público com TDH e dislexia, vermelho ativa resposta de estresse e reforça memória negativa de fracasso escolar. Use o tom amarelo/âmbar para indicar "tente novamente" e verde para sucesso. O vocabulário visual deve sempre apontar para frente, não para o erro.

---

### 🔤 Cores de Texto

| Nome | Hex | Tailwind | Uso |
|---|---|---|---|
| `focus-text` | `#1C1917` | `stone-900` | Texto principal |
| `focus-text-soft` | `#44403C` | `stone-700` | Texto de suporte, descrições |
| `focus-text-muted` | `#78716C` | `stone-500` | Placeholders, datas, metadados |

> **Por quê stone em vez de gray?** Os tons `stone` têm um leve aquecimento que harmoniza com o fundo `#FAFAF7` e reduz o contraste excessivo, mantendo legibilidade sem agressividade visual.

---

### 🏅 Cores de Gamificação (XP e Níveis)

| Nível | Nome | Cor | Hex |
|---|---|---|---|
| 1 | Iniciante | Cinza suave | `#9CA3AF` |
| 2 | Explorador | Verde | `#16A34A` |
| 3 | Focado | Azul | `#3B6FE8` |
| 4 | Determinado | Roxo | `#7C3AED` |
| 5 | Mestre do Foco | Dourado | `#CA8A04` |

> As cores de nível progridem de neutro para vibrante, reforçando a sensação de conquista sem criar ansiedade nos níveis iniciais.

---

## Tipografia

```
Fonte principal:   OpenDyslexic (alunos com dislexia/ambos)
Fonte fallback:    Arial, Helvetica, sans-serif
Tamanho mínimo:    16px (text-base)
Peso do texto:     Regular (400) para corpo, Semibold (600) para destaques
Nunca use:         Itálico em textos longos — dificulta leitura para disléxicos
```

### Escala de tamanhos (Tailwind)

| Uso | Classe Tailwind | Tamanho |
|---|---|---|
| Título de tela | `text-2xl font-bold` | 24px |
| Subtítulo / seção | `text-xl font-semibold` | 20px |
| Corpo principal | `text-base` | 16px |
| Labels e metadados | `text-sm` | 14px |
| Nunca abaixo de | `text-sm` | 14px |

---

## Espaçamento e Layout

```
Espaçamento entre linhas:  leading-relaxed (1.625) para textos de missão
                           leading-loose (2.0) para alunos com perfil dislexia
Padding de botões:         py-4 px-6 — alvos de toque mínimo de 48px de altura
Margem entre seções:       space-y-6 como padrão
Border radius:             rounded-2xl para cards, rounded-full para badges e botões de ação
```

> **Por quê botões grandes?** Pessoas com TDH podem ter dificuldade motora fina. Alvos de toque pequenos aumentam a frustração e o abandono. O mínimo de 48px de altura é recomendação do Google Material Design para acessibilidade mobile.

---

## Regras de Interface — Obrigatórias

1. **Nunca use vermelho** — nem para erros, nem para alertas urgentes. Use âmbar/amarelo.
2. **Nunca use fundo branco puro** (`#FFFFFF`) como fundo de tela. Use sempre `#FAFAF7`.
3. **Uma coisa por vez** — para alunos com TDH, exibir informações progressivamente, nunca tudo de uma vez na tela.
4. **Feedback sempre positivo** — "Quase lá! Tente de novo." Nunca "Errado." ou "Incorreto."
5. **Sem animações desnecessárias** — animações só para feedback de conquista ou transição de tela. Nada piscando ou se movendo em loop.
6. **Texto nunca em itálico em blocos longos** — itálico dificulta a leitura para disléxicos.
7. **Contraste mínimo** — seguir WCAG AA: texto escuro sobre fundo claro, nunca cinza claro sobre branco.
8. **Ícones sempre acompanhados de texto** — nunca ícone sozinho como único indicador de ação.

---

## Tokens Tailwind customizados (tailwind.config.js)

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        'focus-blue':          '#3B6FE8',
        'focus-blue-dark':     '#1E40AF',
        'focus-blue-light':    '#DBEAFE',
        'focus-bg':            '#FAFAF7',
        'focus-bg-card':       '#F5F5EF',
        'focus-success':       '#16A34A',
        'focus-success-light': '#DCFCE7',
        'focus-warning':       '#CA8A04',
        'focus-warning-light': '#FEF9C3',
        'focus-neutral':       '#6B7280',
        'focus-text':          '#1C1917',
        'focus-text-soft':     '#44403C',
        'focus-text-muted':    '#78716C',
      },
      fontFamily: {
        'dyslexic': ['OpenDyslexic', 'Arial', 'sans-serif'],
        'default':  ['Arial', 'Helvetica', 'sans-serif'],
      },
      lineHeight: {
        'dyslexic': '2.0',
      }
    }
  }
}
```

---

## Exemplo de uso — card de missão

```html
<!-- Card de missão — exemplo correto -->
<div class="bg-focus-bg-card rounded-2xl p-6 space-y-4 shadow-sm">
  <span class="text-focus-text-muted text-sm">🎯 Missão de Foco</span>
  <h2 class="text-focus-text text-xl font-semibold leading-relaxed">
    Observe a imagem com atenção
  </h2>
  <p class="text-focus-text-soft text-base leading-relaxed font-dyslexic">
    Uma imagem aparecerá por 10 segundos. Depois, responda as perguntas sobre o que você viu.
  </p>
  <button class="bg-focus-blue text-white font-semibold py-4 px-6 rounded-full w-full text-base">
    Iniciar Missão
  </button>
</div>
```

---

*STYLE.md — Focus App · 2º Hackathon SIF/UniRios 2026*
