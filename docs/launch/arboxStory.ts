import { Gfx, type Ctx, type Env } from "./core";
import type { Film } from "./film";
import { letter } from "./drafting";
import { writeOn } from "./kinetic";
import { BRUSH, C, FLOOR, paintStudio } from "./studio";

// ARBOX AGENT SKILLS · story, 1080x1920: the hook, a close-up of the bench and the laptop, the
// whole studio as a strip below it, and the repository address lettered on the floor.
const W = 1080, H = 1920;
const CLOSE = { s: 1.65, dx: 540 - 1160 * 1.65, dy: 322, clip: [0, 450, W, 1196] as [number, number, number, number] };
const ROOM = { s: 0.675, dx: 0, dy: 1226, clip: [0, 1226, W, 1226 + 600 * 0.675] as [number, number, number, number] };

export const drawArboxStory = (ctx: Ctx, _f: number, env: Env) => {
  ctx.setTransform(env.scale, 0, 0, env.scale, 0, 0);
  ctx.fillStyle = C.wall; ctx.fillRect(0, 0, W, H);
  ctx.fillStyle = C.floor; ctx.fillRect(0, CLOSE.dy + FLOOR * CLOSE.s, W, CLOSE.clip[3] - CLOSE.dy - FLOOR * CLOSE.s); ctx.fillRect(0, ROOM.clip[3] - 4, W, H);
  paintStudio(ctx, env, 0, true, CLOSE);
  paintStudio(ctx, env, 0, true, ROOM);
  writeOn(ctx, env, "ASK YOUR", W / 2, 236, 118, 1, "ink", { align: "center", color: C.ink, slant: 0.05, track: 1.5, seed: 5, tool: false, weight: 1.2 });
  writeOn(ctx, env, "STUDIO", W / 2, 386, 118, 1, "ink", { align: "center", color: C.ink, slant: 0.05, track: 1.5, seed: 6, tool: false, weight: 1.2 });
  const g = new Gfx(ctx, env, 0, BRUSH);
  g.group("plain", () => {
    [CLOSE.clip[1], CLOSE.clip[3], ROOM.clip[3]].forEach((y, i) => g.pen([[24, y], [W / 2, y + 1.5], [W - 24, y]], { w: 2.4, color: C.ink, seed: 80 + i, wobble: 0.8, opacity: 0.9 }));
    letter(g, "ARBOX AGENT SKILLS", W / 2, 1690, { cap: 40, color: C.ink, seed: 61, align: "center", slant: 0, w: 4, track: 1.5 });
    letter(g, "GITHUB.COM/ROMILUZ13/", W / 2, 1772, { cap: 36, color: C.teal, seed: 62, align: "center", slant: 0, w: 3.6, track: 1.5 });
    letter(g, "ARBOX-AGENT-SKILLS", W / 2, 1832, { cap: 36, color: C.teal, seed: 63, align: "center", slant: 0, w: 3.6, track: 1.5 });
  });
  g.paper("coldpress", 0.14);
};

export const arboxStory: Film = {
  meta: { title: "Arbox Agent Skills · story", W, H, fps: 30, bpm: 60, durationFrames: 1 },
  assets: { images: {} },
  shots: [{ id: "story", start: 0, end: 1, draw: drawArboxStory }],
};
