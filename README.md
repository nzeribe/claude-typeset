# claude-typeset

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that makes
your model set documents like a typographer instead of a word processor.

Point it at a Markdown file and you get a real page: a self-contained HTML
sheet and a properly **measured** PDF, plus the three instruments that keep it
honest — one that measures the finished page, one that numbers it, one that
verifies it before it goes anywhere.

The reason it works is not the stylesheet. It is that the model is carrying a
**doctrine** — fifteen rules taken from Bringhurst's *The Elements of
Typographic Style* and paid for in real, specific failures. Each rule says what
it cost. That is in [DOCTRINE.md](./DOCTRINE.md), and it is the part worth
reading even if you never install anything.

## Why your PDFs look cheap

Almost certainly not the font. **The measure.**

Bringhurst's first rule of the page is 45–75 characters per line, 66 ideal.
Past about 75 the eye loses the line on the return sweep and the page stops
being text and becomes a grey slab. A default 30pt print margin on A4 leaves a
189mm column — about **97 characters**. That is what "it looks cheap" usually
is, and no amount of font-swapping will fix it.

The second rule is the one that costs people a day: **you cannot compute the
measure, only measure it.** The same nominal size of the same named font on the
same column gave 68 characters through one renderer and 89 through another —
the browser had embedded the face as Type 3 and set it narrower. So the
pipeline ends by reading the finished PDF back and counting.

## Install

Claude Code skills live in `~/.claude/skills/<name>/`:

```bash
git clone https://github.com/nzeribe/claude-typeset.git ~/.claude/skills/typeset
pip install pymupdf
```

You also need a Chromium-family browser (Chrome, Chromium, Brave or Edge)
installed — it is the typesetter, for the reason in rule 7.

Optional, so you can run the tools from anywhere:

```bash
ln -s ~/.claude/skills/typeset/bin/* ~/bin/          # or wherever your PATH points
```

Check it works:

```bash
~/.claude/skills/typeset/bin/render-doc ~/.claude/skills/typeset/examples/specimen.md --pdf
~/.claude/skills/typeset/bin/pdf-measure ~/.claude/skills/typeset/examples/specimen.pdf
```

The specimen exercises every element the renderer knows, so if it sets
correctly you have seen the whole system. The measure report tells you where
*your* machine landed — if it is outside 45–75, it prints the column width to
try next.

## Use

In any Claude Code session:

| you say | it does |
|---|---|
| `/typeset report.md` | renders the page, opens it |
| "make me a PDF of this" | the full pipeline, verified before it hands it back |
| "why do my PDFs look terrible" | measures the artefact instead of guessing at fonts |

Or drive the tools directly:

```bash
render-doc report.md --pdf                       # set it
pdf-measure report.pdf                           # first run on a machine, or after a font change
pdf-paginate report.pdf "Acme Ltd · Q3 Review"   # LAST — rendering rewrites the PDF
pdf-check report.pdf --expect "a phrase only this version has"
```

## What's in the box

| file | what |
|---|---|
| [`DOCTRINE.md`](./DOCTRINE.md) | the fifteen rules and what each one cost |
| [`SKILL.md`](./SKILL.md) | the instructions your model reads |
| `bin/render-doc` | Markdown → self-contained HTML → PDF. One command, no settings |
| `bin/pdf-measure` | counts characters per line in the finished PDF, against the band |
| `bin/pdf-paginate` | computes and stamps a running footer with page numbers |
| `bin/pdf-check` | reads the PDF back and asks it five questions before you send it |
| `examples/specimen.md` | every element on one sheet |

## The five questions `pdf-check` asks

Because `strings file.pdf | grep TODO` **lies** — a PDF's text lives in
compressed streams that `strings` cannot read, so it returns clean on documents
that are visibly contaminated.

1. Are there drafter's notes still in it?
2. Did any HTML entity (`&nbsp;`) print *literally*?
3. Did an ordered list silently restart at 1?
4. Does a multi-page document carry page numbers?
5. Is the newest change actually in this build, or is this a stale sibling?

Each question was added the day something got past the ones above it. That is
the method: **a check only finds what it is told to look for — so when a defect
gets through, widen the check, don't just fix the instance.**

## Design notes

- **One stylesheet, two outputs.** The screen shows the sheet at the real
  measure in the real face; the print rules only take away the desk. If a
  preview lies, it is worse than no preview, because it is trusted.
- **Self-contained.** Images are embedded as data URIs, so the page survives
  being moved or emailed. A missing image is a hard failure, never a silent
  omission — a letter without its signature looks finished and is not.
- **Dark mode dims the desk, not the sheet.** A page is a page.
- **A trailing backslash is the hard line break**, not Markdown's two trailing
  spaces. An invisible notation is not a notation.

## Credit

The typographic rules are Robert Bringhurst's, from *The Elements of
Typographic Style* — the measure, the heading scale, the page-break discipline.
Everything else is what happened when that book was aimed at a pipeline that
was quietly producing bad PDFs, and the pipeline lost.

## License

[MIT](./LICENSE) — fork it, rebind it, make it yours.
