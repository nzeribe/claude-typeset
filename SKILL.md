---
name: typeset
description: Set a Markdown file as a real PAGE — a themed, self-contained HTML page and a properly measured PDF, using a typographic doctrine derived from Bringhurst's The Elements of Typographic Style. Use when the user types `/typeset`, or asks to render / export / "make a PDF of" / "print" / "make this look good" a document, letter, report, proposal, invoice, schedule or specification — and whenever a document is about to LEAVE THE HOUSE (be sent, filed, printed or handed over). Also use when a user complains that their generated PDFs look bad, cheap, or "like a wall of text". NOT for slide decks, NOT for web pages, NOT for reformatting code.
---

# /typeset

Turn a Markdown file into a document that can be sent to someone.

The engine is `bin/render-doc` in this skill's own folder. The reasoning behind
every number it uses is in **[DOCTRINE.md](./DOCTRINE.md)** — read it before
changing any of them, and before arguing with any of them.

## The one thing to understand

**The measure is the whole game.** 45–75 characters per line, 66 ideal. A
document that looks cheap almost never has a font problem; it has a column that
runs to 90+ characters, at which width the eye loses the line on the return
sweep and every page reads as a grey slab.

And the measure **cannot be computed** — only measured off the finished PDF.
See rule 2. This is why `pdf-measure` exists and why you run it.

## The pipeline

```bash
T=~/.claude/skills/typeset/bin        # adjust if installed elsewhere

$T/render-doc report.md --pdf                       # 1. set it
$T/pdf-measure report.pdf                           # 2. measure (see below)
$T/pdf-paginate report.pdf "Acme Ltd · Q3 Review"   # 3. LAST: page numbers
$T/pdf-check report.pdf --expect "<newest phrase>"  # 4. verify, then send
```

**Step 2 is conditional.** Run `pdf-measure` when:

- it is the **first render on this machine** (the fonts are not the author's),
- the **body font changed**, via `--body-font` or because a font is missing,
- the user says the page looks wrong and you cannot see why.

If it reports out of band, it prints the exact `--measure` value to try. Apply
it, render again, measure again. Two or three passes, then it is settled
forever and you never think about it again.

**Step 3 is genuinely last.** `render-doc` rewrites the PDF on every render, so
a re-render silently discards the page numbers. Re-render → re-paginate.

**Step 4 before anything is sent.** `pdf-check` exits non-zero on failure, so
it is safe to chain with `&&`.

## Authoring rules — obey these when you WRITE the Markdown

These are the ones that bite silently. A document can be wrong in all four ways
and still look finished.

1. **Hard line breaks are a trailing backslash**, not two trailing spaces.
   Letterheads, addresses and signature blocks are *one block of several lines*
   and must not open inter-paragraph space between them:

   ```
   The Manager\
   Something Ltd\
   14 Some Street
   ```

2. **Hard-number anything that will be cited.** Renderers restart ordered lists
   at 1. If the source reads `6.` `7.` `8.`, the PDF reads `1.` `2.` `3.` and
   every cross-reference in every downstream document points at nothing. Write
   `**6.** The respondent…` as its own paragraph instead.

3. **Never `&nbsp;`** — it prints *literally*, as seven characters. Indent with
   two real leading spaces (never four: that is a code block) or set flush.

4. **Images must exist.** `![alt](path)` is embedded, and a missing file is a
   hard failure by design. Alt text of exactly `signature` sets an ink
   signature at letter scale; anything else is a centred figure.

## When the user complains the output looks bad

Work in this order — it is ordered by how often each is the actual cause:

| symptom | first suspect |
|---|---|
| "wall of text", "looks cheap", "hard to read" | **the measure** — run `pdf-measure` |
| screen and print differ | something restyled in the print block — rule 3 |
| a table collapsed into one cell per line | not rendered through a browser — rule 7 |
| a signature or address ran together on one line | missing trailing backslashes — rule 10 |
| numbering is wrong in the PDF but right in the source | ordered-list restart — rule 12 |
| drafting notes reached a recipient | `strings` was trusted over `pdf-check` — rule 13 |

Do not offer to "try a different font". Measure first. The font is almost never
the problem, and changing it invalidates the measure — which makes it worse
while appearing to be an action.

## Options worth knowing

```
--measure 128mm       the text column (env TYPESET_MEASURE)
--body-font "..."     body font stack (env TYPESET_BODY_FONT)
--save / --out PATH   keep the HTML beside the source / at a path
--no-open             write it, don't open it
--title T             override the page title
```

`--measure` and `--body-font` **move together**: change one and the other is
void until re-measured.

Front matter (`title:`, `type:`, `date:`) is read; `type` and `date` set a
subtitle line under the first heading.

## Requirements

- **Python 3** and **PyMuPDF** (`pip install pymupdf`) for the three PDF tools.
- **A Chromium-family browser** (Chrome, Chromium, Brave, Edge) for `--pdf`.
  It is the typesetter: it is the only engine on a normal machine that draws a
  real ruled table and honours page-break control. macOS, Linux and Windows
  paths are all searched, plus `$PATH`.
- Gill Sans and Georgia if you want the exact page the doctrine was tuned on —
  otherwise the stack falls back, and you **measure**.

## Don't

- Don't print from a browser dialog, an editor's preview, or an app's export
  panel. One command, no settings — rule 15.
- Don't hand-keep a page number, a "page N of T", or a contents page column.
  Compute them — rule 11.
- Don't verify a PDF with `strings | grep`. It returns clean on contaminated
  documents — rule 13.
- Don't leave more than one PDF per document in a folder a pack is assembled
  from — rule 14.
