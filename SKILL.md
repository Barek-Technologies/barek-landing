---
name: barek-landing
description: Build a calm, premium landing page for a mobile app or product: centred floating pill nav, a soft layered gradient glow behind one phone, a heavy headline with one italic serif phrase, pill buttons or an email waitlist, art orbiting the device, light cards, steps, FAQ, final call to action. One accent colour drives every tint. Use when the user wants a landing page, marketing site, waitlist or coming-soon page, a website for their app, or says their current site is busy or cluttered ("screens everywhere"). Ships a working HTML/CSS template, a contrast check and a desktop+phone preview script.
---

# Barek Landing

A landing page in the style of Barek's app sites (stylemanager.ai,
myloveclub.ai): one product, one promise, one phone, lots of air. It reads in
five seconds and feels expensive because it holds back.

`template/` is a working page (`index.html` + `styles.css`). Start from it
rather than from a blank file. `references/techniques.md` explains how each
piece works, so you can rebuild it in any framework.

## The thinking behind it

Read this before changing anything. Each rule is there because breaking it
made a real page worse.

1. **One phone, not a collage.** Five screenshots fanned across the hero read as "screens everywhere" and nobody looks at any of them. One device, centred, with one real screen, is a focal point. Put the other screens' *art* (illustrations, photo crops, icons) in small circles orbiting it. That gives the variety without the noise.
2. **Everything on the centre line.** Nav, tag, headline, lede, buttons, phone. A centred stack has no wrong reading order and survives every screen width unchanged. Only sections further down (cards, split features) use columns.
3. **The nav floats.** A pill, centred, `max-width` about 860px, frosted (`backdrop-filter`), sticky 12px from the top. Logo left, three or four section links centre, one dark CTA right. It narrows a little on scroll. On phones the links go and the logo + CTA stay.
4. **Two typefaces, one gesture.** A heavy geometric sans for the claim (Outfit 700), then **one** phrase in an italic serif (Playfair Display italic) in the brand colour for the feeling: "Get early *access*", "Know what to do *for them.*" Once per heading, at the end, never a whole sentence. Every section heading repeats the gesture; that repetition is the brand.
5. **The glow carries the colour; the page stays quiet.** Background is a warm off-white (never `#fff`). The hero gets a layered gradient: cream caps at the top and bottom, a tinted band through the middle where the phone sits. Text always lands on cream, and the colour sits behind the device. Two blurred orbs drift slowly on top. Below the hero the page goes back to off-white with light cards.
6. **One accent decides everything.** Four tokens (`--accent`, `--brand`, `--bg`, `--ink`); every tint, border, shadow and glow is `color-mix()` of those. A rebrand is four lines, and the page can't drift into a second palette.
7. **Pills everywhere.** Buttons, the tag, the waitlist field, the nav: all `border-radius: 999px`. Cards are 24px. Nothing is square.
8. **Motion is slow and optional.** Hero lines rise in from behind a mask, staggered 0.08–0.12s. Sections fade up as they enter (CSS scroll-driven animation, IntersectionObserver fallback). Orbit circles bob. Orbs drift. All of it switches off under `prefers-reduced-motion`, and the page is complete without JavaScript.
9. **Honest proof only.** "Join 70+ others" only if there are 70. No invented logos, ratings or testimonials. A privacy section and real pricing build more trust than a fake quote.

## Workflow

### 1. Read the product

From the codebase or the user: what it does, for whom, the one outcome people
want, whether it's live (store links) or pre-launch (waitlist), price model,
platforms, and the brand colours and fonts. Look for theme tokens (`theme.ts`,
`tailwind.config`, `tokens.js`, CSS variables). Find or capture **one** real
screen with realistic content for the phone (the `appstore-screenshots` skill
can capture it), plus 4–8 pieces of the app's own art for the orbit.

### 2. Set the four tokens and check them

Pick `--accent` (a mid-tone for the glow: the brand's light-medium shade),
`--brand` (dark enough for button text and links), `--bg` (warm off-white
tinted towards the accent), `--ink` (near-black tinted the same way).

```bash
scripts/contrast.mjs --accent "#aebe8e" --brand "#31440c" --bg "#fdfbf6" --ink "#15170f"
```

Fix every FAIL before building. A pastel brand colour usually fails as a
button. Keep it as `--accent` and use a darker shade as `--brand`.

### 3. Write the copy before the layout

Show the user the words first. They are cheap to change now.

- **Tag** (pill above the headline): 2–5 words. "Coming soon", "Free to start", "New: Android".
- **Headline:** 4–9 words, the outcome, ending in the italic phrase. Not the product name.
- **Lede:** one or two sentences, ≤ 46 characters per line at desktop (the CSS caps it at `46ch`). Who, what, the believable detail.
- **CTA:** launched → "Download for iPhone" (dark) + a ghost secondary ("See how it works →"). Pre-launch → the waitlist pill.
- **Sections**, in this order, cutting any you can't fill honestly: Features (4 cards, benefit titles) → How it works (3 steps) → one feature split or showcase → Privacy (if the product touches personal data) → Pricing (if public) → FAQ (4–6, real questions) → final CTA → footer with legal links.
- **Voice:** second person, plain words, no "revolutionary", no "AI-powered" as a headline.

### 4. Build

Copy `template/` into the project (or port it to the framework: Next.js,
Astro, Expo web; the CSS ports as-is). Then:

- Set the tokens, fonts (`<link>` or self-hosted), `<title>` (≤ 60 chars) and meta description (≤ 155), Open Graph image (1200×630, the phone on the glow).
- Replace `.phone__screen` with the real screenshot `<img>` (width/height set, `fetchpriority="high"`).
- Replace the orbit `<span>`s with `<img>` crops of the app's art (square, ~160px, WebP). Keep `aria-hidden`; they're decoration.
- Pre-launch: swap the CTA block for the commented waitlist form and point it at the user's provider (their API route, Supabase, Formspree, Loops, etc.). Never fake a submission.
- Add the store badges or links you really have; add `apple-itunes-app` meta for the Smart App Banner if it's on iOS.

### 5. Verify

```bash
scripts/preview.sh index.html preview/            # or http://localhost:3000
```

It writes `desktop.png` (1440 wide) and `phone.png` (a true 390px layout) and
fails if the page is wider than a phone. Look at both images. Check:

- No horizontal overflow at 390px (blurred orbs are the usual cause; the hero clips them).
- The headline breaks well at both widths. Add `<br>` or adjust `max-width: 15ch`.
- Orbit circles clear the phone at every width; phones show only the outer four.
- Text never sits on the darkest part of the glow.
- With reduced motion on (DevTools → Rendering), everything is visible and still.
- Lighthouse: performance and accessibility ≥ 95. The phone screenshot is the LCP; make sure it's preloaded and sized.

## Rules

- Never show UI the product doesn't have, or a device with someone else's app on it.
- Never invent social proof, waitlist counts, press logos or ratings.
- Keep one accent family. A second bright colour breaks the calm.
- The page must work without JavaScript; scripts only enhance.
