#!/usr/bin/env node
// Check the four brand tokens before building: WCAG contrast for the pairs the
// template actually uses.
//
//   contrast.mjs --accent "#aebe8e" --brand "#31440c" --bg "#fdfbf6" --ink "#15170f"

const args = Object.fromEntries(
  process.argv.slice(2).reduce((a, v, i, all) => (v.startsWith("--") ? [...a, [v.slice(2), all[i + 1]]] : a), []),
);
for (const k of ["accent", "brand", "bg", "ink"]) {
  if (!/^#?[0-9a-f]{6}$/i.test(args[k] ?? "")) {
    console.error('usage: contrast.mjs --accent "#rrggbb" --brand "#rrggbb" --bg "#rrggbb" --ink "#rrggbb"');
    process.exit(64);
  }
}

const rgb = (h) => h.replace("#", "").match(/../g).map((x) => parseInt(x, 16) / 255);
const lum = (h) => {
  const [r, g, b] = rgb(h).map((c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const ratio = (a, b) => {
  const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p);
  return (x + 0.05) / (y + 0.05);
};
// The hero's darkest glow point, where the phone sits: accent at ~70% over bg.
const mix = (a, b, t) => "#" + rgb(a).map((c, i) => Math.round((c * t + rgb(b)[i] * (1 - t)) * 255).toString(16).padStart(2, "0")).join("");
const glow = mix(args.accent, args.bg, 0.7);

const checks = [
  ["Headings (ink on bg)", args.ink, args.bg, 4.5],
  ["Italic word, links (brand on bg)", args.brand, args.bg, 4.5],
  ["Button label (bg on brand)", args.bg, args.brand, 4.5],
  ["Text over the glow (ink on glow)", args.ink, glow, 4.5],
  ["Glow is visible (accent vs bg)", args.accent, args.bg, 1.3],
];
let fail = 0;
for (const [label, fg, bgc, min] of checks) {
  const r = ratio(fg, bgc);
  const ok = r >= min;
  if (!ok) fail++;
  console.log(`${ok ? "ok  " : "FAIL"}  ${r.toFixed(2).padStart(5)}:1  (needs ${min})  ${label}`);
}
if (fail) console.log("\nDarken --brand or --ink, or pick a lighter --accent, then re-run.");
process.exit(fail ? 1 : 0);
