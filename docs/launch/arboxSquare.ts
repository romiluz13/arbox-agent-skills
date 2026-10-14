import { Gfx, type Ctx, type Env } from "./core";
import type { Film } from "./film";
import { clamp } from "./gallery";
import { letter } from "./drafting";
import { writeOn } from "./kinetic";
import { BRUSH, C, FLOOR, T, paintStudio } from "./studio";

// ARBOX AGENT SKILLS · square post, 1080x1080: a close-up of the bench, the laptop asking who
// stopped coming, the spark above it, and the hook written over the wall. The teaser is this same
// picture drawing itself (arboxTeaser); the still is its last frame.
const W = 1080, H = 1080, S = 1.65, DX = 540 - 1160 * S, DY = 14;
export const SQUARE_N = 300, SQUARE_HOLD = 74;

export const drawArboxSquare = (ctx: Ctx, f: number, env: Env, fin = true) => {
  const at = (w: readonly [number, number]) => (fin || f >= w[1] ? 1 : f <= w[0] ? 0 : (f - w[0]) / (w[1] - w[0]));
  ctx.setTransform(env.scale, 0, 0, env.scale, 0, 0);
  ctx.fillStyle = C.board; ctx.fillRect(0, 0, W, H);
  paintStudio(ctx, env, f, fin, { s: S, dx: DX, dy: DY });
  if (at(T.paint) >= 1) { ctx.fillStyle = C.floor; ctx.fillRect(0, DY + 620 * S - 2, W, H); }
  const ttl = at(T.title);
  if (ttl > 0) {
    writeOn(ctx, env, "ASK YOUR", 66, 172, 104, clamp(ttl * 2), "ink", { color: C.ink, slant: 0.05, track: 1.5, seed: 5, tool: !fin, weight: 1.2 });
    writeOn(ctx, env, "STUDIO", 66, 302, 104, clamp(ttl * 2 - 1), "ink", { color: C.ink, slant: 0.05, track: 1.5, seed: 6, tool: !fin, weight: 1.2 });
  }
  const sub = at([T.title[0] + 8, T.title[1]]);
  const g = new Gfx(ctx, env, 0, BRUSH);
  if (sub > 0) g.group("plain", () => {
    letter(g, "ARBOX AGENT SKILLS", W / 2, DY + FLOOR * S + 62, { cap: 34, color: C.ink, seed: 51, align: "center", slant: 0, w: 3.6, track: 1.5, progress: clamp(sub * 1.6) });
    letter(g, "CLAUDE CODE  x  ARBOX", W / 2, DY + FLOOR * S + 116, { cap: 20, color: C.tomato, seed: 52, align: "center", slant: 0, w: 2.4, track: 1.6, progress: clamp(sub * 1.6 - 0.6) });
  });
  g.paper("coldpress", 0.14);
};

export const arboxSquare: Film = {
  meta: { title: "Arbox Agent Skills · square post", W, H, fps: 30, bpm: 60, durationFrames: 1 },
  assets: { images: {} },
  shots: [{ id: "post", start: 0, end: 1, draw: (ctx, f, env) => drawArboxSquare(ctx, f, env, true) }],
};
