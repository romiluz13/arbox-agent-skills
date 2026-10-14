import { displace, fractal, Gfx, rng, type Ctx, type Env, type Medium, type P } from "./core";
import type { Film } from "./film";
import { clamp, mix, smooth } from "./gallery";
import { streakClip, streaks } from "./koiDrawKit";
import { letter, width } from "./drafting";
import { writeOn } from "./kinetic";

// ARBOX AGENT SKILLS · THE STUDIO, shared by the launch pieces (social card, square post, story,
// teaser). The same room as the README banner, minus its title: each piece frames the room through
// a View and letters its own words over it.
//
// The studio, before the 7am class. Originally a README hero for gym, Pilates and yoga
// studio owners: their own room (a reformer, a rolled mat, a kettlebell, the week's class board,
// a coffee going cold) with a friendly terminal on the bench and a spark of help dropping into it.
//
// STYLE: mid-century gouache (anidoodle `midCentury`), chosen because its flat warm shapes and
// loose off-register ink line read as a picture book, not a SaaS dashboard.
// MEDIUM: opaque matte gouache on warm board; flats laid big to small, dry brush dragged over
// them, then a loose brush-and-ink line printed off register. Lettering is pen strokes.
// ORDER: wall and floor, furniture and equipment, the small things; dry brush; the line; the
// title written last, then the finished still holds.
// LIGHT: high on the left; every object shows a darker right side and a flat shadow to the right.
// REFERENCE (from knowledge): a studio Pilates reformer seen side-on (wooden frame on short legs,
// padded carriage on rails, footbar at the foot end, springs from carriage to foot end, risers
// with straps at the head end); a cast-iron kettlebell (ball body, flat base, arched handle); a
// rolled yoga mat lying on its side showing its spiral end; a laptop on a low wooden bench. The terminal asks who stopped coming and has drafts ready:
// the agent reads and drafts, the owner sends, so the screen never claims a message went out.
// The spark is a generic four-point sparkle: no real logo or trademark is drawn.

export const T = { paint: [4, 132], dry: [136, 158], line: [162, 196], title: [200, 226] } as const;
export const C = {
  board: "#f1e1b8", wall: "#f5e8c8", arch: "#fbf2dc", floor: "#d9ad6c", floorD: "#b98a4c", cream: "#f5e8c8", pink: "#e8a296",
  ochre: "#e2a73a", turq: "#56aba2", white: "#f7efdc", tomato: "#d2462a", teal: "#244e4a", brown: "#7a4a33", dark: "#2b2724",
  olive: "#a6a340", leaf: "#4c8c52", leafD: "#356a3e", mustard: "#e9ae34", wood: "#b07a4a", woodD: "#86562f", steel: "#b9b7ae", ink: "#1d1a17",
};
const BRUSH: Medium = { nib: 1.15, taper: 1, pressure: 0.85, retrace: false, wobble: 1.4, rough: 0.35 };
const REG: P = [4, -3];
export const FLOOR = 520;

type Sh = { pts: P[]; col: string; ang: number };
type Dry = { path: P[]; w: number; col: string; seed: number };
type Ln = { pts: P[]; w: number; seed: number };
type Scene = { shapes: Sh[]; dry: Dry[]; lines: Ln[]; paintT: [number, number][]; dryT: [number, number][]; lineT: [number, number][] };

const sm = (a: P[], closed = true, per = 6) => smooth(a, closed, per);
const area = (s: P[]) => Math.abs(s.reduce((a, p, i) => { const q = s[(i + 1) % s.length]; return a + p[0] * q[1] - q[0] * p[1]; }, 0) / 2);
const ell = (cx: number, cy: number, rx: number, ry: number, rot = 0, n = 22): P[] => Array.from({ length: n }, (_, i) => { const a = (i / n) * Math.PI * 2, x = Math.cos(a) * rx, y = Math.sin(a) * ry; return [cx + x * Math.cos(rot) - y * Math.sin(rot), cy + x * Math.sin(rot) + y * Math.cos(rot)] as P; });
const arcP = (cx: number, cy: number, rx: number, ry: number, a0: number, a1: number, n = 16): P[] => Array.from({ length: n }, (_, i) => { const a = a0 + ((a1 - a0) * i) / (n - 1); return [cx + Math.cos(a) * rx, cy + Math.sin(a) * ry] as P; });
const rect = (x0: number, y0: number, x1: number, y1: number): P[] => [[x0, y0], [x1, y0], [x1, y1], [x0, y1]];
const rrect = (x0: number, y0: number, x1: number, y1: number, rad: number): P[] => [[x1 - rad, y0 + rad, -Math.PI / 2], [x1 - rad, y1 - rad, 0], [x0 + rad, y1 - rad, Math.PI / 2], [x0 + rad, y0 + rad, Math.PI]].flatMap(([cx, cy, a]) => arcP(cx, cy, rad, rad, a, a + Math.PI / 2, 5));
const plen = (s: P[]) => s.reduce((a, p, i) => (i ? a + Math.hypot(p[0] - s[i - 1][0], p[1] - s[i - 1][1]) : 0), 0);
const sparkle = (cx: number, cy: number, r: number, waist = 0.18): P[] => { const out: P[] = []; for (let i = 0; i < 4; i++) { const a = -Math.PI / 2 + (i * Math.PI) / 2; out.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); const b = a + Math.PI / 4; out.push([cx + Math.cos(b) * r * waist, cy + Math.sin(b) * r * waist]); } return out; };
const sparkleSoft = (cx: number, cy: number, r: number): P[] => { const out: P[] = []; for (let i = 0; i < 4; i++) { const a = -Math.PI / 2 + (i * Math.PI) / 2, b = a + Math.PI / 2; out.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); for (let k = 1; k < 6; k++) { const t = k / 6, p0: P = [cx + Math.cos(a) * r, cy + Math.sin(a) * r], p1: P = [cx + Math.cos(b) * r, cy + Math.sin(b) * r], m: P = [cx, cy], u = 1 - t; out.push([u * u * p0[0] + 2 * u * t * (m[0] * 0.82 + (p0[0] + p1[0]) * 0.09) + t * t * p1[0], u * u * p0[1] + 2 * u * t * (m[1] * 0.82 + (p0[1] + p1[1]) * 0.09) + t * t * p1[1]]); } } return out; };

const buildScene = (): Scene => {
  const shapes: Sh[] = [], dry: Dry[] = [], lines: Ln[] = [], r = rng(2026);
  const S = (pts: P[], col: string, ang = 0) => shapes.push({ pts, col, ang });
  const L = (pts: P[], w = 2) => lines.push({ pts, w, seed: 300 + lines.length });
  // a ruled line is drawn edge by edge: the pen smooths THROUGH its points and would round a corner into a loop
  const R = (pts: P[], w = 2) => pts.slice(1).forEach((b, i) => L([pts[i], b], w));
  const D = (path: P[], w: number, col: string) => dry.push({ path, w, col, seed: 700 + dry.length });
  const shadowR = (x0: number, x1: number, h = 10) => S(sm([[x0, FLOOR + 2], [x1, FLOOR + 2], [x1 + 46, FLOOR + h], [x0 + 30, FLOOR + h + 2]]), C.floorD, 0.05);

  // the room: wall wash, an arched window behind the title, the wooden floor
  S(sm([[-20, -20], [1620, -20], [1620, FLOOR + 4], [-20, FLOOR + 4]], true, 1), C.wall, 0.2);
  S([...arcP(800, 200, 330, 190, Math.PI, Math.PI * 2, 30), [1130, 440], [470, 440]], C.arch, 1.2);
  S(sm([[-20, FLOOR], [400, FLOOR - 3], [900, FLOOR + 1], [1620, FLOOR - 2], [1620, 620], [-20, 620]], true, 1), C.floor, 0.05);

  // the week's class board (Sunday first: most of the audience is in Israel)
  const bx0 = 46, by0 = 44, bx1 = 330, by1 = 250;
  S(rect(bx0 + 10, by0 + 12, bx1 + 10, by1 + 12), mix(C.wall, C.dark, 0.18), 0.3);
  S(rect(bx0, by0, bx1, by1), C.brown, 1.57);
  S(rect(bx0 + 10, by0 + 10, bx1 - 10, by1 - 10), C.white, 0.2);
  S(rect(bx0 + 10, by0 + 10, bx1 - 10, by0 + 40), C.turq, 0.1);
  const cols = 5, cw = (bx1 - bx0 - 20) / cols, ry0 = by0 + 64, rh = 44;
  const slot = [[1, 0, 2], [0, 1, 3], [2, 4, 1], [3, 0, 1], [1, 2, 0]], fills = [C.tomato, C.mustard, C.turq, C.pink, C.olive];
  for (let c = 0; c < cols; c++) for (let k = 0; k < 3; k++) { const v = slot[c][k]; if ((c + k) % 4 === 3) continue; const x = bx0 + 10 + c * cw + 5, y = ry0 + k * rh + 4; S(rect(x, y, x + cw - 10, y + rh - 12), fills[v], 1.57); }
  R([[bx0, by0], [bx1, by0], [bx1, by1]], 2); L([[bx0 + 10, by0 + 40], [bx1 - 10, by0 + 40]], 1.3);
  for (let c = 1; c < cols; c++) L([[bx0 + 10 + c * cw, by0 + 44], [bx0 + 10 + c * cw, by1 - 14]], 1);
  L([[188, 24], [188, 44]], 1.4);
  S(ell(188, 22, 5, 5), C.tomato, 0);

  // the reformer, side-on: legs, frame, carriage, footbar, springs, risers and straps
  const rx0 = 40, rx1 = 560, top = 418;
  shadowR(rx0 + 20, rx1 - 10, 14);
  [rx0 + 18, rx1 - 34].forEach((x) => { S(rect(x, top + 26, x + 18, FLOOR), C.woodD, 1.57); });
  S(rect(rx0, top, rx1, top + 30), C.wood, 0); S(rect(rx0, top + 20, rx1, top + 30), C.woodD, 0);
  S(rect(rx0 + 4, top - 8, rx1 - 4, top), C.steel, 0);
  const cx0 = 250, cx1 = 420;
  S(rrect(cx0 - 2, top - 36, cx1 + 2, top - 12, 6), C.tomato, 0);
  S(rect(cx0 + 6, top - 12, cx1 - 6, top - 6), C.dark, 0);
  S(rrect(cx1 - 28, top - 62, cx1 - 8, top - 34, 6), mix(C.tomato, C.dark, 0.15), 1.57);
  S(rrect(cx1 - 58, top - 62, cx1 - 38, top - 34, 6), mix(C.tomato, C.dark, 0.15), 1.57);
  S(rrect(cx1 + 4, top - 34, cx1 + 46, top - 18, 6), C.tomato, 0);
  // the footbar: a padded bar on two posts at the foot end
  S(rect(rx0 + 50, top - 120, rx0 + 60, top), C.steel, 1.57);
  S(rrect(rx0 + 28, top - 134, rx0 + 82, top - 116, 8), C.teal, 0);
  // the risers at the head end
  S(rect(rx1 - 22, top - 150, rx1 - 12, top), C.steel, 1.57);
  S(rect(rx1 - 30, top - 158, rx1 - 4, top - 148), C.dark, 0);
  // the platform at the foot end
  S(rect(rx0 + 4, top - 22, rx0 + 110, top - 8), C.teal, 0);
  R([[rx0, top], [rx1, top], [rx1, top + 30]], 1.8); L([[rx0, top + 30], [rx1 - 40, top + 30]], 1.4);
  R([[cx0 - 2, top - 36], [cx1 + 2, top - 36], [cx1 + 2, top - 12]], 1.7);
  for (let s = 0; s < 3; s++) { const y = top - 4 + s * 7, pts: P[] = []; for (let i = 0; i <= 18; i++) pts.push([rx0 + 112 + (i / 18) * (cx0 - rx0 - 114), y + (i % 2 ? -3 : 3)]); L(pts, 1); }
  L([[rx0 + 30, top - 132], [rx0 + 80, top - 132]], 1.6); L([[rx0 + 50, top - 116], [rx0 + 50, top]], 1.3);
  L([[rx1 - 22, top - 150], [rx1 - 22, top]], 1.3);
  L(sm([[rx1 - 18, top - 150], [rx1 - 70, top - 100], [cx1 - 20, top - 70]], false, 6), 1.2);
  L(sm([[rx1 - 14, top - 150], [rx1 - 50, top - 120], [cx1 + 20, top - 80], [cx1 + 6, top - 66]], false, 6), 1.2);
  S(ell(cx1 + 8, top - 70, 9, 6, 0.4), C.dark, 0);
  D([[rx0 + 20, top + 8], [rx1 - 20, top + 6]], 10, mix(C.wood, "#ffffff", 0.3));
  D([[cx0 + 8, top - 28], [cx1 - 10, top - 30]], 10, mix(C.tomato, "#ffffff", 0.35));

  // the rolled mat lying on its side, its spiral end toward us
  const mx0 = 618, mx1 = 790, my = FLOOR - 30, mr = 30;
  shadowR(mx0, mx1 + 20, 10);
  S(rect(mx0, my - mr, mx1, my + mr), C.turq, 0);
  S(rect(mx0, my + 8, mx1, my + mr), mix(C.turq, C.dark, 0.25), 0);
  S(ell(mx1, my, 16, mr, 0, 26), mix(C.turq, "#ffffff", 0.25), 0);
  S(ell(mx0, my, 16, mr, 0, 26), C.turq, 0);
  S(rect(mx0 + 42, my - mr - 2, mx0 + 54, my + mr + 2), C.mustard, 1.57); S(rect(mx1 - 56, my - mr - 2, mx1 - 44, my + mr + 2), C.mustard, 1.57);
  const spiral: P[] = Array.from({ length: 60 }, (_, i) => { const t = i / 59, a = t * Math.PI * 6; return [mx1 + Math.cos(a) * 14 * t, my + Math.sin(a) * 27 * t] as P; });
  L(spiral, 1.3); L([[mx0, my - mr], [mx1, my - mr]], 1.6); L([[mx0 + 4, my + mr], [mx1 - 6, my + mr]], 1.4);
  D([[mx0 + 10, my - 18], [mx1 - 20, my - 20]], 10, mix(C.turq, "#ffffff", 0.4));

  // the kettlebell: ball body, flat base, the handle arched over it
  const kx = 870, ky = FLOOR - 36, kr = 36;
  shadowR(kx - 20, kx + 40, 10);
  S(ell(kx, ky - kr - 6, 30, 30, 0, 28), C.dark, 0);
  S(ell(kx, ky - kr - 6, 18, 18, 0, 28), C.wall, 0);
  S(sm([[kx - 32, FLOOR], [kx + 32, FLOOR], [kx + kr, ky], [kx + 26, ky - 26], [kx, ky - kr], [kx - 26, ky - 26], [kx - kr, ky]], true, 6), C.dark, 1.2);
  S(ell(kx - 12, ky - 10, 9, 14, 0.5, 16), mix(C.dark, "#ffffff", 0.22), 0);
  L(arcP(kx, ky - kr - 6, 31, 31, Math.PI * 1.02, Math.PI * 1.98, 18), 1.6);
  L([[kx + kr, ky], [kx + 32, FLOOR]], 1.4);
  D([[kx - 22, ky - 4], [kx - 8, ky - 24]], 8, mix(C.dark, "#ffffff", 0.3));

  // the bench, the laptop on it, the terminal open
  const bz0 = 930, bz1 = 1390, bt = 448;
  shadowR(bz0 + 10, bz1 - 10, 12);
  [bz0 + 20, bz1 - 40].forEach((x) => S(rect(x, bt + 14, x + 20, FLOOR), C.woodD, 1.57));
  S(rect(bz0, bt, bz1, bt + 16), C.wood, 0); S(rect(bz0, bt + 11, bz1, bt + 16), C.woodD, 0);
  R([[bz0, bt], [bz1, bt], [bz1, bt + 16]], 1.6);
  const lx0 = 980, lx1 = 1250, ly0 = 270, ly1 = 438;
  S(rect(lx0 + 12, ly0 + 10, lx1 + 12, ly1 + 6), mix(C.wall, C.dark, 0.2), 0.2);
  S(sm([[lx0 - 6, ly0 - 6], [lx1 + 6, ly0 - 6], [lx1 + 6, ly1], [lx0 - 6, ly1]], true, 1), C.cream, 1.57);
  S(rect(lx0 + 6, ly0 + 6, lx1 - 6, ly1 - 12), C.teal, 1.57);
  S(sm([[lx0 - 34, ly1], [lx1 + 34, ly1], [lx1 + 24, bt], [lx0 - 24, bt]], true, 1), C.steel, 0);
  [[0, C.tomato], [16, C.mustard], [32, C.turq]].forEach(([dx, col]) => S(ell(lx0 + 18 + (dx as number), ly0 + 18, 4.5, 4.5, 0, 12), col as string, 0));
  S(rect(lx0 + 22, ly1 - 46, lx0 + 34, ly1 - 26), C.mustard, 1.57);
  R([[lx0 - 6, ly0 - 6], [lx1 + 6, ly0 - 6], [lx1 + 6, ly1]], 1.7); L([[lx0 - 34, ly1], [lx1 + 34, ly1]], 1.5);

  // a coffee going cold on the bench, steam still rising
  const qx = 1320, qy = bt;
  S(sm([[qx - 22, qy - 46], [qx + 22, qy - 46], [qx + 18, qy], [qx - 18, qy]], true, 1), C.white, 1.57);
  S(rect(qx - 21, qy - 30, qx + 20, qy - 20), C.tomato, 0);
  S(ell(qx + 26, qy - 26, 11, 12, 0, 18), C.white, 0); S(ell(qx + 26, qy - 26, 5, 6, 0, 14), C.wall, 0);
  S(ell(qx, qy - 46, 22, 5, 0, 18), C.brown, 0);
  R([[qx - 22, qy - 46], [qx - 18, qy], [qx + 18, qy]], 1.5);
  L(sm([[qx - 8, qy - 56], [qx - 14, qy - 72], [qx - 6, qy - 88], [qx - 12, qy - 104]], false, 6), 1.2);
  L(sm([[qx + 6, qy - 58], [qx + 12, qy - 76], [qx + 4, qy - 92]], false, 6), 1.2);

  // a potted plant at the end of the room
  const px = 1500;
  shadowR(px - 40, px + 30, 10);
  [[-0.9, 120, C.leaf], [-0.35, 150, C.leafD], [0.15, 160, C.leaf], [0.65, 130, C.leafD], [1.1, 104, C.leaf], [-1.35, 90, C.leafD]].forEach(([a, len, col]) => {
    const ang = -Math.PI / 2 + (a as number), b: P = [px, FLOOR - 70], tip: P = [b[0] + Math.cos(ang) * (len as number), b[1] + Math.sin(ang) * (len as number)], m: P = [(b[0] + tip[0]) / 2, (b[1] + tip[1]) / 2], n: P = [-Math.sin(ang), Math.cos(ang)], wd = (len as number) * 0.24;
    S(sm([b, [m[0] + n[0] * wd, m[1] + n[1] * wd], tip, [m[0] - n[0] * wd, m[1] - n[1] * wd]], true, 6), col as string, ang);
    L(sm([b, [m[0] + n[0] * 3, m[1] + n[1] * 3], tip], false, 6), 1.1);
  });
  S(sm([[px - 46, FLOOR - 76], [px + 46, FLOOR - 76], [px + 36, FLOOR], [px - 36, FLOOR]], true, 1), C.tomato, 1.57);
  S(rect(px - 50, FLOOR - 84, px + 50, FLOOR - 66), mix(C.tomato, C.dark, 0.2), 0);
  R([[px - 50, FLOOR - 84], [px + 50, FLOOR - 84], [px + 50, FLOOR - 66]], 1.4); L([[px + 46, FLOOR - 66], [px + 36, FLOOR]], 1.4);

  // the spark, and the trail it leaves down into the terminal
  const sx = 1360, sy = 150;
  S(sparkleSoft(sx, sy, 62), C.mustard, 0.8);
  S(sparkleSoft(sx - 6, sy - 4, 24), mix(C.mustard, "#ffffff", 0.45), 0.8);
  S(sparkleSoft(sx + 82, sy - 52, 20), C.tomato, 0.8);
  S(sparkleSoft(sx + 72, sy + 66, 14), C.turq, 0.8);
  S(sparkleSoft(sx - 92, sy + 40, 11), C.tomato, 0.8);
  L(sparkleSoft(sx, sy, 62).concat([[sx, sy - 62]]), 1.7);
  const trail = sm([[sx - 22, sy + 70], [sx - 40, sy + 104], [lx1 - 4, ly0 - 30], [lx1 - 22, ly0 + 2]], false, 3);
  for (let i = 2; i < trail.length; i += 3) S(ell(trail[i][0], trail[i][1], 3.2, 3.2, 0, 10), i % 2 ? C.mustard : C.tomato, 0);
  S(sparkleSoft(lx1 - 24, ly0 + 20, 9), C.mustard, 0.8);

  // dry brush: floorboards, wall weather, the arch's edge
  for (let i = 0; i < 9; i++) { const x = r() * 1500, y = FLOOR + 14 + i * 9 + r() * 4; D([[x, y], [x + 160 + r() * 160, y + 1]], 6, C.floorD); }
  [[372, 300], [380, 360], [1150, 40], [1440, 250], [20, 300]].forEach(([x, y]) => D([[x, y], [x + 80, y - 4]], 16, mix(C.wall, C.board, 0.8)));
  L([[0, FLOOR], [1600, FLOOR - 2]], 1.2);

  const span = (ws: number[], a: number, b: number): [number, number][] => { const tot = ws.reduce((x, y) => x + y, 0); let t = 0; return ws.map((w) => { const s: [number, number] = [a + ((b - a) * t) / tot, a + ((b - a) * (t + w)) / tot]; t += w; return s; }); };
  // paint follows the order written above: the room first, then each object from its back to its front
  const paintT = span(shapes.map((s) => 1.4 + Math.sqrt(area(s.pts)) / 30), T.paint[0], T.paint[1]);
  const dryT = span(dry.map((d) => 1 + plen(d.path) / 90), T.dry[0], T.dry[1]);
  const lineT = span(lines.map((l) => 1.2 + plen(l.pts) / 120), T.line[0], T.line[1]);
  return { shapes, dry, lines, paintT, dryT, lineT };
};

const dens = (s: P[]): P[] => s.flatMap((a, i) => { const b = s[(i + 1) % s.length], n = Math.max(1, Math.ceil(Math.hypot(b[0] - a[0], b[1] - a[1]) / 4)); return Array.from({ length: n }, (_, k) => [a[0] + ((b[0] - a[0]) * k) / n, a[1] + ((b[1] - a[1]) * k) / n] as P); });
const edge = (s: Sh, i: number): P[] => { const a = Math.sqrt(area(s.pts)), amp = clamp(a * 0.008, 0.3, 2.2); return displace(dens(s.pts), amp, 0.11, 2, 40 + i); };
const trace = (c: Ctx, pts: P[]) => { c.beginPath(); pts.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y))); c.closePath(); };
const dryBrush = (c: Ctx, d: Dry, q: number) => {
  const [a, b] = [d.path[0], d.path[d.path.length - 1]], dx = b[0] - a[0], dy = b[1] - a[1], l = Math.hypot(dx, dy) || 1, nx = -dy / l, ny = dx / l, nb = Math.max(4, Math.round(d.w / 2.2)), steps = Math.max(6, Math.round(l / 3)), r = rng(d.seed);
  c.strokeStyle = d.col; c.lineWidth = 1.5; c.lineCap = "round"; c.globalAlpha = 0.7; c.beginPath();
  for (let k = 0; k < nb; k++) {
    const v = (k / (nb - 1) - 0.5) * d.w + (r() - 0.5) * 1.2, start = r() * 0.08, th = 0.2 + r() * 0.14; let on = false;
    for (let j = 0; j <= steps * q; j++) {
      const t = j / steps; if (t < start) continue;
      const skip = fractal(d.seed + k, t * l * 0.35, k * 3.1, 1, 1, 2) < th + t * 0.35, x = a[0] + dx * t + nx * v, y = a[1] + dy * t + ny * v;
      if (skip) { on = false; continue; } if (!on) { c.moveTo(x, y); on = true; } else c.lineTo(x, y);
    }
  }
  c.stroke(); c.globalAlpha = 1;
};

export type View = { s: number; dx: number; dy: number; clip?: [number, number, number, number] };
// the room through a view (scene px -> canvas px: p * s + d), optionally clipped to a canvas rect.
// `fin` draws every mark complete; otherwise frame f follows the timeline T.
export const paintStudio = (ctx: Ctx, env: Env, f: number, fin: boolean, v: View) => {
  let sc = env.cache.get("studio:scene") as Scene | undefined; if (!sc) { sc = buildScene(); env.cache.set("studio:scene", sc); }
  let edges = env.cache.get("studio:edges") as P[][] | undefined; if (!edges) { edges = sc.shapes.map((s, i) => edge(s, i)); env.cache.set("studio:edges", edges); }
  const at = (w: readonly [number, number]) => (fin || f >= w[1] ? 1 : f <= w[0] ? 0 : (f - w[0]) / (w[1] - w[0]));
  const view = () => ctx.setTransform(env.scale * v.s, 0, 0, env.scale * v.s, env.scale * v.dx, env.scale * v.dy);
  const g = new Gfx(ctx, env, 0, BRUSH);
  ctx.save();
  if (v.clip) { ctx.setTransform(env.scale, 0, 0, env.scale, 0, 0); const [x0, y0, x1, y1] = v.clip; ctx.beginPath(); ctx.rect(x0, y0, x1 - x0, y1 - y0); ctx.clip(); }
  view();
  sc.shapes.forEach((s, i) => {
    const q = at(sc!.paintT[i]); if (q <= 0) return;
    ctx.save(); ctx.fillStyle = s.col;
    if (q < 1) { const a = Math.sqrt(area(s.pts)); streakClip(ctx, streaks([edges![i]], clamp(a / 5, 5, 58), s.ang, 60 + i, clamp(a * 0.9, 60, 340)), q); }
    trace(ctx, edges![i]); ctx.fill(); ctx.restore();
  });
  sc.dry.forEach((d, i) => { const q = at(sc!.dryT[i]); if (q > 0) dryBrush(ctx, d, q); });
  const lq = sc.lines.map((_, i) => at(sc!.lineT[i]));
  g.push(v.dx + REG[0] * v.s, v.dy + REG[1] * v.s, v.s);
  if (lq.some((q) => q > 0)) g.group("plain", () => sc!.lines.forEach((l, i) => { if (lq[i] > 0) g.pen(l.pts, { w: l.w, color: C.ink, seed: l.seed, wobble: 0.9, opacity: 0.92, progress: lq[i] >= 1 ? 1 : lq[i] }); }));
  g.pop(); g.push(v.dx, v.dy, v.s);
  const sp = at([T.line[0], T.line[0] + 12]);
  if (sp > 0) g.group("plain", () => ["SUN", "MON", "TUE", "WED", "THU"].forEach((d, i) => letter(g, d, 56 + (i + 0.5) * 52.8, 63, { cap: 12, color: C.white, seed: 11 + i, align: "center", slant: 0, w: 1.6, progress: sp })));
  // the terminal only ever reads and drafts: the owner sends
  const tp = at([T.line[1] - 20, T.line[1] + 4]);
  if (tp > 0) g.group("plain", () => {
    g.pen([[996, 312], [1005, 318.5], [996, 325]], { w: 2, color: C.mustard, seed: 20, wobble: 0.2, progress: clamp(tp * 4) });
    letter(g, "WHO STOPPED COMING?", 1016, 312, { cap: 13, color: C.arch, seed: 21, slant: 0, w: 1.8, progress: clamp(tp * 2) });
    letter(g, "7 TO CALL", 996, 344, { cap: 13, color: C.mustard, seed: 22, slant: 0, w: 1.8, progress: clamp(tp * 3 - 1) });
    letter(g, "DRAFTS READY", 996, 370, { cap: 13, color: C.mustard, seed: 23, slant: 0, w: 1.8, progress: clamp(tp * 3 - 2) });
  });
  g.pop();
  if (tp >= 1) { view(); ctx.fillStyle = C.arch; ctx.fillRect(996, 396, 11, 16); }
  ctx.restore();
  ctx.setTransform(env.scale, 0, 0, env.scale, 0, 0);
};

// a plain hand-lettered line with real middle dots between its parts (the drafting hand has no "·")
export const dotted = (g: Gfx, parts: string[], cx: number, y: number, cap: number, color: string, seed: number, progress = 1) => {
  const gap = cap * 1.4, ws = parts.map((p) => width(p, cap, 1.4)), tot = ws.reduce((a, b) => a + b, 0) + gap * (parts.length - 1);
  let x = cx - tot / 2;
  parts.forEach((p, i) => {
    const pr = clamp(progress * parts.length - i); if (pr <= 0) return;
    letter(g, p, x, y, { cap, color, seed: seed + i, slant: 0, track: 1.4, w: Math.max(1.4, cap * 0.12), progress: pr });
    x += ws[i];
    if (i < parts.length - 1 && pr >= 1) { const c = g.cur; g.touch(x, y, x + gap, y + cap); c.fillStyle = color; c.beginPath(); c.arc(x + gap / 2, y + cap * 0.55, Math.max(1.6, cap * 0.11), 0, Math.PI * 2); c.fill(); }
    x += gap;
  });
};
export { BRUSH };
