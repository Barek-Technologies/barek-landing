# How each piece works

Reference for porting the template to a framework or adapting a piece. Class
names match `template/styles.css`.

## The hero glow (`.hero__glow`)

Four backgrounds stacked on one element, top layer first:

```css
background:
  /* 1. cream cap: covers the top so the headline sits on clean ground */
  radial-gradient(120% 72% at 50% -20%, var(--bg) 45%, color-mix(in oklab, var(--bg) 92%, transparent) 60%, transparent 78%),
  /* 2. the tinted band: an ellipse centred where the phone is (≈ 52–62%) */
  radial-gradient(130% 58% at 50% 62%, color-mix(in oklab, var(--accent) 95%, transparent) 0%, … transparent 80%),
  /* 3. cream cap at the bottom so the hero hands off to the page */
  radial-gradient(130% 75% at 50% 116%, var(--bg) 42%, … transparent 78%),
  /* 4. vertical base: bg → accent → bg, so the band never shows a hard edge */
  linear-gradient(180deg, var(--bg) 0%, … var(--bg) 92%);
mask-image: linear-gradient(180deg, #000 78%, transparent);
```

Tuning:

- **Band height**: the second number of layer 2 (`58%`). Larger = more colour.
- **Band position**: `at 50% 62%`. Move it to wherever the device's centre is.
- **Intensity**: the accent percentages in layers 2 and 4. Keep the peak near 70% accent; beyond that, text over it loses contrast.
- The `mask-image` fades the last fifth so the hero never ends in a line.

The orbs are two absolutely positioned circles with `filter: blur(64px)` and a
14s `translate/scale` drift. The hero has `overflow: hidden` because a blurred
orb extends past its box and would make phones scroll sideways.

## Centred pill nav (`.nav`, `.nav__pill`)

The outer `header` is `position: sticky; top: 12px`, full width, flex-centred,
and `pointer-events: none` so the empty sides don't block clicks; the pill
turns pointer events back on. The pill is `width: min(860px, 100%)`, 56px tall,
`backdrop-filter: saturate(160%) blur(16px)` over an 82% bg. A scroll listener
(rAF-throttled) toggles `.is-compact` past 40px, which narrows the pill.

## Headline gesture

`h1 em, h2 em` switch to the serif italic at weight 500, brand colour, tighter
tracking. The sans headline uses `letter-spacing: -0.03em` and `line-height:
1.05`; the serif needs less negative tracking or it collides.

## Line reveal (`.line`)

Each hero line is `<p class="line"><span style="--d:.2s">…</span></p>`. The
outer clips (`overflow: hidden`), the inner animates `translateY(105%) → 0`
with `cubic-bezier(.2,.7,.2,1)` over 0.9s, delayed by `--d`. Stagger 0, .08,
.2, .32s for tag, headline, lede, CTA. The CTA wrapper turns clipping off so
button shadows aren't cut.

## Scroll reveal (`.r`)

Where `animation-timeline: view()` is supported, a pure-CSS animation runs as
the element enters (`animation-range: entry 0% entry 36%`). Elsewhere, the
inline script adds `html.js`, hides `.r` elements, and an IntersectionObserver
adds `.in` when each enters (`rootMargin: 0 0 -12% 0`). No JS means no hiding,
so the content is always reachable.

## Phone + orbit (`.stage`)

The phone is pure CSS: `aspect-ratio: 9 / 19.5`, radius 17% of its width,
3.5% bezel, a `::before` pill for the Dynamic Island, and a brand-tinted drop
shadow. Size it with `--w`.

The orbit is an ellipse with radii `--rx`/`--ry`. Each dot gets `--x: cos(θ)`
and `--y: sin(θ)` inline and is placed with:

```css
left: calc(50% + var(--x) * var(--rx) - var(--s) / 2);
top:  calc(50% + var(--y) * var(--ry) - var(--s) / 2);
```

Angles that keep dots beside the phone (not over it): ±25°, ±52°, ±128°,
±155°. cos/sin: (.906, .423), (.616, .788). On phones the ellipse widens to
46vw, the device shrinks to 52vw, and only the outer four (|x| = .906) show.
Each dot bobs 8px over 6s, offset by `--i × -0.7s` so they never move in sync.

## Colour derivation

```css
--line: color-mix(in oklab, var(--ink) 10%, var(--bg));
--card: color-mix(in oklab, var(--accent) 6%, var(--bg));
--tint: color-mix(in oklab, var(--accent) 22%, var(--bg));
```

`color-mix()` is supported by every current browser (Safari 16.2+, Chrome
111+). For older targets, compute the mixes once and hard-code them.

## Waitlist pill

One rounded container holds the input (transparent, no border) and the submit
button (46px, inside a 58px pill with 6px padding). The label is visually
hidden but present for screen readers. `type="email"`, `required`,
`autocomplete="email"`. On submit, replace the form with a one-line thank-you;
don't navigate away.

## Countdown (optional, pre-launch)

Style Manager shows days/hours/minutes/seconds in four frosted squares below
the phone: `background: rgba(255,255,255,.18)`, `backdrop-filter: blur(20px)`,
1px white/55% border, 16–24px radius, tabular numerals. Only use it with a
real launch date, and hide it once the date passes.
