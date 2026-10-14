# Launch assets

Drawn entirely in code with [anidoodle](https://github.com/alexgreensh/anidoodle) (Apache-2.0, by Alex Greenshpun), in its mid-century gouache style. They show the same studio as the README banner (`assets/readme/banner.*`). Not affiliated with Arbox or Anthropic: no logos are drawn, and the spark is a generic doodle. Every screen in these images only reads and drafts. None of them shows a message sent or a booking, charge or change made.

| File | Size | Use |
|---|---|---|
| `social-card.png` | 1280x640, 285 KB | GitHub social preview and link previews; key text is in the central safe area |
| `post-square.png` | 1080x1080, 455 KB | Instagram post, WhatsApp, X |
| `post-story.png` | 1080x1920, 766 KB | Instagram or WhatsApp story; repo address at the bottom |
| `teaser.gif` | 1080x1080, 1.5 MB, 8 s | the square post drawing itself, then holding |

Sources: `studio.ts` (the shared room), `arboxSocial.ts`, `arboxSquare.ts`, `arboxStory.ts`, `arboxTeaser.ts`.

## Regenerate

From the repo root (needs Node and ffmpeg):

```sh
git clone https://github.com/alexgreensh/anidoodle /tmp/anidoodle
node /tmp/anidoodle/skills/anidoodle/engine/tools/scaffold.mjs /tmp/art --film arboxSocial
cp docs/launch/*.ts /tmp/art/src/canvas-core/
cd /tmp/art && npm install
for n in arboxSquare arboxStory arboxTeaser; do printf 'import { %s } from "../canvas-core/%s";\nimport { mountFilm } from "./page";\nmountFilm(%s);\n' $n $n $n > src/hosts/page-$n.ts; done
for n in arboxSocial arboxSquare arboxStory; do node tools/still.mjs $n --frame 0 --out out/$n.png
  ffmpeg -y -i out/$n.png -vf "split[a][b];[a]palettegen=max_colors=256:stats_mode=full[p];[b][p]paletteuse=dither=sierra2_4a" out/$n-q.png; done
node tools/render.mjs arboxTeaser --out out/teaser.gif --gif-fps 15
```

`out/arboxSocial-q.png`, `out/arboxSquare-q.png` and `out/arboxStory-q.png` become `social-card.png`, `post-square.png` and `post-story.png`. The PNGs are reduced to 256 colours so each stays under 1.5 MB; the full-colour renders are 1.1 to 2.8 MB.
