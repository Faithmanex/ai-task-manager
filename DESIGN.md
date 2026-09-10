# DESIGN.md — AI Task Manager Style Reference
> quiet precision instrument — Refero template adapted for a dark, calm productivity tool

**Theme:** dark

AI Task Manager's design system is a calm midnight workspace built on near-black surfaces (`#08090A`) with paper-white type and a single electric acid-lime accent (`#E4F222`) that functions as a functional flashlight — small, high-contrast, and used sparingly to signal the one primary action per view. The interface treats darkness as a substrate rather than a theme: text is crisp white at tight tracking, weights sit in a low 400–510 band rather than bold, and borders are hairline-thin to let geometry do the work that shadows usually would. Components feel precision-machined — 6px and 12px radii, compact 8–12px paddings, and almost no decorative ornament — letting the task list itself be the only visual texture in an otherwise quiet system.

*Template structure adapted from the Refero Styles DESIGN.md format (styles.refero.design).*

## Tokens — Colors

| Name | Value | Token | Role |
|------|-------|-------|------|
| Void | `#08090A` | `--color-void` | Page canvas, full-bleed backgrounds — the default everything sits on |
| Carbon | `#0F1011` | `--color-carbon` | Card surfaces, nav bars, list panels |
| Obsidian | `#161718` | `--color-obsidian` | Elevated surfaces, sheets, chat bubbles (assistant) |
| Graphite | `#23252A` | `--color-graphite` | Subtle borders, dividers, ghost button outlines |
| Smoke | `#383B3F` | `--color-smoke` | Hairline borders at higher contrast — section separators |
| Ash | `#62666D` | `--color-ash` | Muted body text, inactive icons, secondary metadata |
| Fog | `#8A8F98` | `--color-fog` | Tertiary text, placeholder copy, empty-state art |
| Mist | `#D0D6E0` | `--color-mist` | Secondary headings, button text on dark surfaces |
| Bone | `#E5E5E6` | `--color-bone` | Near-white surface fills, high-contrast button text |
| Paper | `#FFFFFF` | `--color-paper` | Primary headings, max-contrast emphasis text |
| Acid Lime | `#E4F222` | `--color-acid-lime` | THE primary action: FAB, submit, active nav indicator — one per view, never decoration |
| Pulse Green | `#27A644` | `--color-pulse-green` | Success / completed states, list color option |
| Coral Red | `#EB5757` | `--color-coral-red` | Overdue / destructive support wash — never body text |
| Signal Teal | `#02B8CC` | `--color-signal-teal` | Informational fills, AI suggestion outline |
| Iris Violet | `#6366F1` | `--color-iris-violet` | Tag/badge fills — list & category indicators |
| Lavender | `#8B5CF6` | `--color-lavender` | Secondary tag fills, "AI-generated" badge |

## Tokens — Typography

### Inter — Primary UI and heading typeface — used across nav, body, headings, buttons, cards · `--font-inter`
- **Substitute:** Inter (variable), or system-ui as fallback
- **Weights:** 300, 400, 510, 590
- **Sizes:** 10, 11, 12, 13, 14, 15, 16, 17, 20, 24, 32, 48, 64, 72
- **Line height:** 1.0–2.75
- **Letter spacing:** -0.022em at 48–72px, -0.012em at 20–32px, -0.011em at 15px, -0.010em at 13–16px
- **Role:** Primary UI and heading typeface — used across nav, body, headings, buttons, cards

### Berkeley Mono — Code-adjacent UI text · `--font-mono`
- **Substitute:** JetBrains Mono, IBM Plex Mono, or ui-monospace
- **Weights:** 400
- **Sizes:** 12, 14
- **Letter spacing:** -0.013em
- **Role:** Priority scores, keyboard shortcuts, timestamp metadata — never headings

### Type Scale

| Role | Size | Line Height | Letter Spacing | Token |
|------|------|-------------|----------------|-------|
| caption | 13px | 1.2 | — | `--text-caption` |
| body-sm | 15px | 1.6 | -0.165px | `--text-body-sm` |
| body | 16px | 1.5 | -0.160px | `--text-body` |
| body-lg | 20px | 1.33 | -0.24px | `--text-body-lg` |
| subheading | 24px | 1.33 | -0.288px | `--text-subheading` |
| heading-sm | 32px | 1.13 | -0.704px | `--text-heading-sm` |
| heading | 48px | 1 | -1.056px | `--text-heading` |

## Tokens — Spacing & Shapes

**Base unit:** 4px · **Density:** compact

### Spacing Scale

| Name | Value | Token |
|------|-------|-------|
| 4 | 4px | `--spacing-4` |
| 8 | 8px | `--spacing-8` |
| 12 | 12px | `--spacing-12` |
| 16 | 16px | `--spacing-16` |
| 24 | 24px | `--spacing-24` |
| 32 | 32px | `--spacing-32` |
| 48 | 48px | `--spacing-48` |
| 96 | 96px | `--spacing-96` |

### Border Radius

| Element | Value |
|---------|-------|
| cards | 12px |
| pills | 9999px |
| small | 2px |
| badges | 4px |
| inputs | 6px |
| buttons | 6px |

### Shadows

| Name | Value | Token |
|------|-------|-------|
| subtle | `rgb(35, 37, 42) 0px 0px 0px 1px inset` | `--shadow-subtle` |
| sm | `rgba(0, 0, 0, 0.4) 0px 2px 4px 0px` | `--shadow-sm` |
| xl | `rgba(8, 9, 10, 0.6) 0px 4px 32px 0px` | `--shadow-xl` |

### Layout

- **Page max-width:** 1200px (web) · full-bleed on mobile
- **Section gap:** 96px · **Card padding:** 24px · **Element gap:** 8px

## Components

### Task Card
**Role:** The atomic unit of the product — one task row

Background `#0F1011`, radius 12px, inset hairline border `#23252A`, padding 16px. Circular checkbox (2px `#383B3F` outline; fills Pulse Green with white check when complete; strikethrough + Ash text on completion). Title Inter 15px/400 `#E5E5E6`; metadata row 13px `#8A8F98` with date chip (Coral Red tint if overdue). Priority dot 6px — Iris Violet (low) / Signal Teal (medium) / Acid Lime (high).

### Primary Action Button (Acid Lime)
**Role:** High-emphasis CTA — the one chromatic button in the view

Background `#E4F222`, text `#08090A`, radius 6px, padding 10px×16px, Inter 14px/510, letter-spacing -0.011em. Exactly one per view (e.g., "Add task" FAB, chat "Plan my day" submit).

### AI Suggestion Card
**Role:** Container for any AI-proposed content before commit

Background `#161718`, radius 12px, 1px Signal Teal-tinted inset border, Lavender "AI" corner badge (4px radius, 12px type). Contains editable parsed fields + action row: [Accept] Acid Lime filled / [Regenerate] Ghost / [Dismiss] text. User is always the final authority.

### Chat Bubble (Day Pilot)
**Role:** Assistant conversation UI

User: background `#23252A`, radius 12px (top-right 4px), Mist text, right-aligned. Assistant: background `#161718`, radius 12px (top-left 4px), Bone text, left-aligned, with optional inline action cards (see AI Suggestion Card).

### Ghost / Outline Button
**Role:** Secondary actions — regenerate, snooze, cancel

Transparent background, border 1px `#23252A`, text `#D0D6E0`, radius 6px, padding 8px×12px, Inter 13px/400.

### Text Input (Quick Capture)
**Role:** Natural-language task capture bar

Background `rgba(255,255,255,0.02)`, border 1px `rgba(255,255,255,0.08)`, text `#D0D6E0`, radius 6px, padding 12px×14px, Inter 14px/400. Placeholder Fog 13px: "Try 'Email Dana the deck tomorrow 5pm'". Focus: border brightens to `#D0D6E0`, subtle outer glow `rgba(228,242,34,0.15)` 0 0 0 3px.

### Badge / Status Tag
**Role:** List chips, priority labels, inline metadata

Background `rgba(255,255,255,0.05)`, text `#8A8F98`, radius 4px, padding 0×6px, Inter 12px/400. Color variants: Pulse Green (done), Coral Red (overdue), Iris Violet (list), Lavender (AI).

### Navigation Rail (Web) / Bottom Bar (Mobile)
**Role:** Top-level navigation between Lists / Today / Assistant / Settings

Carbon surface; active item: Acid Lime 2px left indicator + Paper text; inactive: Ash. Icons 20px line-art, labels 13px.

## Surfaces

| Level | Name | Value | Purpose |
|-------|------|-------|---------|
| 0 | Void | `#08090A` | Page canvas |
| 1 | Carbon | `#0F1011` | Cards, list panels, nav |
| 2 | Obsidian | `#161718` | Elevated sheets, chat bubbles, suggestions |
| 3 | Slate | `#23252A` | Interactive tints, ghost fills |

## Elevation

Elevation comes from hairline borders (0.5–1px `#23252A`/`#383B3F`) and subtle inset shadows, not layered shadow stacks. Visual hierarchy flows from the surface progression (`#08090A → #0F1011 → #161718 → #23252A`) and border definition. The only true outer shadow in the system is the modal sheet (`--shadow-xl`).

## Imagery

No stock photography. Empty states use minimal single-color (Fog) line-art SVG — an empty checklist, a spark for the AI assistant. Icons are minimal line-art, single-color, grey-scale. The product's own UI (task cards, chat) is the visual content.

## Layout

Mobile-first single column; task list max-width 640px centered on web (1200px shell for nav rail + content). Chat panel is a bottom sheet on mobile, right dock (380px) on web ≥1024px. One focal point per screen: the list, or the conversation. Generous whitespace; never more than one chromatic element per view.

## Do's and Don'ts

### Do
- Use Inter with font-feature-settings `'cv01'`, `'ss03'`, `'zero'` on
- Use `#E4F222` exclusively for the single primary action per view
- Set body text at 16px Inter 400, line-height 1.5
- Use letter-spacing -0.022em at 48px and above
- Keep radii to the three-value vocabulary: 6px / 12px / pill
- Use 0.5px hairline borders (`#23252A`, `#383B3F`) instead of shadows for separation
- Keep the 8/12/24/96 spacing ladder

### Don't
- Do not use bold weights (700+) — cap at 590
- Do not use decorative gradients on buttons, cards, or text
- Do not introduce additional chromatic accents — acid-lime is the only chromatic action
- Do not use large radii (16px+) on cards or panels
- Do not use shadows to separate cards — hairline borders and insets only
- Do not use chromatic text colors for body copy — body text stays in the Mist/Fog/Ash greyscale
- Do not use Berkeley Mono for headings — reserve for scores, shortcuts, timestamps

## Agent Prompt Guide

**Quick Color Reference:**
- text (primary heading): `#FFFFFF` · text (body): `#D0D6E0` · text (muted): `#8A8F98`
- background (canvas): `#08090A` · background (card): `#0F1011` · border (hairline): `#23252A`
- accent (CTA): `#E4F222` — filled primary action, one per view

**3–5 Example Component Prompts:**

1. **Task list screen:** Full-bleed `#08090A` canvas. Header "Today" Inter 32px/400 `#FFFFFF`, tracking -0.022em. Subtext 15px `#8A8F98` ("3 of 7 done · 2 suggested by AI"). Task cards as specced above, 8px gaps, 24px screen padding, list max-width 640px.

2. **Quick capture bar:** Bottom-docked input, Carbon surface, 6px radius, Inter 14px placeholder `#8A8F98`: "Try 'Email Dana the deck tomorrow 5pm'". Right-anchored Acid Lime send FAB (44px circle, plus glyph `#08090A`).

3. **AI suggestion card (subtasks):** Obsidian surface, 12px radius, 1px Signal Teal inset border, Lavender "AI" badge. Ordered subtask rows 15px `#D0D6E0` with drag handles Ash. Action row: [Add subtasks] acid-lime filled 6px radius, [Regenerate] ghost, [Dismiss] plain text Fog.

4. **Day Pilot chat empty state:** Centered Fog line-art spark SVG 64px, headline 20px/590 `#E5E5E6` "Plan your day", body 15px `#8A8F98`, single Acid Lime pill CTA "Plan my day".

## Type Scale Detail

Display: 72px / 510 / lh 1.0 / ls -0.022em
Section heading: 48px / 510 / lh 1.0 / ls -0.022em
Subheading: 32px / 400 / lh 1.13 / ls -0.022em
Heading: 24px / 400 / lh 1.33 / ls -0.012em
Body emphasis: 20px / 590 / lh 1.33 / ls -0.012em
Body: 16px / 400 / lh 1.5
Body small: 15px / 400 / lh 1.6 / ls -0.011em
Caption: 13px / 400 / lh 1.2
Label: 12px / 400 / lh 1.4
Micro: 10px / 510 / lh 1.5

## Quick Start

### CSS Custom Properties (web build)

```css
:root {
  --color-void: #08090A;
  --color-carbon: #0F1011;
  --color-obsidian: #161718;
  --color-graphite: #23252A;
  --color-smoke: #383B3F;
  --color-ash: #62666D;
  --color-fog: #8A8F98;
  --color-mist: #D0D6E0;
  --color-bone: #E5E5E6;
  --color-paper: #FFFFFF;
  --color-acid-lime: #E4F222;
  --color-pulse-green: #27A644;
  --color-coral-red: #EB5757;
  --color-signal-teal: #02B8CC;
  --color-iris-violet: #6366F1;
  --color-lavender: #8B5CF6;

  --font-inter: 'Inter', ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --font-mono: 'JetBrains Mono', ui-monospace, SFMono-Regular, Consolas, monospace;

  --spacing-4: 4px;  --spacing-8: 8px;   --spacing-12: 12px;  --spacing-16: 16px;
  --spacing-24: 24px; --spacing-32: 32px; --spacing-48: 48px; --spacing-96: 96px;

  --radius-sm: 2px; --radius-md: 6px; --radius-lg: 12px; --radius-pill: 9999px;

  --shadow-subtle: rgb(35, 37, 42) 0 0 0 1px inset;
  --shadow-sm: rgba(0, 0, 0, 0.4) 0 2px 4px 0;
  --shadow-xl: rgba(8, 9, 10, 0.6) 0 4px 32px 0;
}
```

### Flutter ThemeData Seed

```dart
// lib/core/theme.dart — canonical theme built from DESIGN.md tokens
const kVoid   = Color(0xFF08090A);
const kCarbon = Color(0xFF0F1011);
const kObsidian = Color(0xFF161718);
const kGraphite = Color(0xFF23252A);
const kSmoke  = Color(0xFF383B3F);
const kAsh    = Color(0xFF62666D);
const kFog    = Color(0xFF8A8F98);
const kMist   = Color(0xFFD0D6E0);
const kBone   = Color(0xFFE5E5E6);
const kPaper  = Color(0xFFFFFFFF);
const kAcidLime = Color(0xFFE4F222);
const kPulseGreen = Color(0xFF27A644);
const kCoralRed = Color(0xFFEB5757);
const kSignalTeal = Color(0xFF02B8CC);
const kIrisViolet = Color(0xFF6366F1);
const kLavender = Color(0xFF8B5CF6);
```
