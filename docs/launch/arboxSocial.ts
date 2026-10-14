import { Gfx, type Ctx, type Env } from "./core";
import type { Film } from "./film";
import { letter } from "./drafting";
import { writeOn } from "./kinetic";
import { BRUSH, C, FLOOR, dotted, paintStudio } from "./studio";

// ARBOX AGENT SKILLS · social card (GitHub social preview / link preview), 1280x640.
// The words sit in the top band inside the central safe area; the studio from the README banner
// stands below them, smaller, on the same floor.
const W = 1280, H = 640, S = 0.65, DX = 120, DY = 250;

export const drawArboxSocial = (ctx: Ctx, _f: number, env: Env) => {
  ctx.setTransform(env.scale, 0, 0, env.scale, 0, 0);
  ctx.fillStyle = C.wall; ctx.fillRect(0, 0, W, H);
  ctx.fillStyle = C.floor; ctx.fillRect(0, DY + FLOOR * S, W, H);
  paintStudio(ctx, env, 0, true, { s: S, dx: DX, dy: DY });
  writeOn(ctx, env, "ARBOX AGENT SKILLS", W / 2, 116, 60, 1, "ink", { align: "center", color: C.ink, slant: 0.05, track: 1.6, seed: 4, tool: false, weight: 1.15 });
  const g = new Gfx(ctx, env, 0, BRUSH);
  g.group("plain", () => {
    letter(g, "CLAUDE CODE  x  ARBOX", W / 2, 142, { cap: 24, color: C.tomato, seed: 31, align: "center", slant: 0, w: 2.8, track: 1.6 });
    dotted(g, ["FREE", "OPEN SOURCE", "FOR STUDIO OWNERS"], W / 2, 190, 15, C.dark, 41);
  });
  g.paper("coldpress", 0.14);
};

export const arboxSocial: Film = {
  meta: { title: "Arbox Agent Skills · social card", W, H, fps: 30, bpm: 60, durationFrames: 1 },
  assets: { images: {} },
  shots: [{ id: "card", start: 0, end: 1, draw: drawArboxSocial }],
};
