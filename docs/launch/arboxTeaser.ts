import type { Film } from "./film";
import { SQUARE_HOLD, SQUARE_N, drawArboxSquare } from "./arboxSquare";

// ARBOX AGENT SKILLS · teaser: the square post drawing itself, then holding on the finished post.
// The studio's timeline paints the class board, the reformer and the mat (all outside this close-up)
// between studio frames 31 and 77, and inks the board between 170 and 177, so the teaser jumps over
// those stretches instead of showing a still wall.
const CUTS: [number, number][] = [[31, 77], [170, 177]], HOLD = SQUARE_HOLD;
const N = SQUARE_N - CUTS.reduce((a, [x, y]) => a + y - x, 0);
const studioFrame = (f: number) => CUTS.reduce((sf, [x, y]) => (sf >= x ? sf + y - x : sf), f);

export const arboxTeaser: Film = {
  meta: { title: "Arbox Agent Skills · teaser", W: 1080, H: 1080, fps: 30, bpm: 60, durationFrames: N, kind: "drawing", holds: [[N - HOLD, N, "the finished post"]] },
  assets: { images: {} },
  shots: [{ id: "post", start: 0, end: N, draw: (ctx, f, env) => drawArboxSquare(ctx, studioFrame(f), env, f >= N - HOLD) }],
};
