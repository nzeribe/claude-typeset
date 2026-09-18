---
title: Specimen Sheet
type: Specimen
date: every element this renderer knows
---

# Specimen Sheet

This page exercises every element `render-doc` can set. Render it, print it,
and you have seen the whole typeface of the system at once.

Render it to a page:

```
render-doc examples/specimen.md
```

Render it to paper:

```
render-doc examples/specimen.md --pdf
pdf-measure examples/specimen.pdf
```

The second command is not optional on a new machine. **The measure does not
travel.** If your machine has no Gill Sans, the fallback face sets at a
different width, and the column that gives 67 characters here may give 84 on
yours — outside the band, and the page reads as a slab. Measure, adjust with
`--measure`, measure again.

## Running prose

This paragraph exists to be measured. It should run to something close to
sixty-six characters a line, which is the width at which the eye can find the
start of the next line without losing its place, and at which a page of text
reads as a page rather than as a wall. Robert Bringhurst gives the band as
forty-five to seventy-five characters in *The Elements of Typographic Style*;
sixty-six is the figure he calls ideal for a single-column setting. Everything
else on this sheet is downstream of that one number.

Emphasis comes in two weights: *italic for a stressed word* and **bold for a
named thing**. Inline code sets in `monospace at a smaller size`, because a
monospace face at the same nominal size always reads too large beside a
humanist sans.

### A third-level heading

Headings are Georgia — a serif — against a sans body. The contrast is
structural rather than decorative: it tells you a heading is a *different kind
of thing* from the text, not merely a louder version of it.

#### A fourth-level heading

Below this level, use bold text in the paragraph. A fifth heading level is
usually a sign that the document wants to be two documents.

## Hard line breaks

A line ending in a backslash breaks **without** starting a new paragraph. This
is what a letterhead, a recipient block or a signature block needs — several
lines that are one block, with no inter-paragraph space opening up between
them:

The Manager\
Something Ltd\
14 Some Street\
Manchester M14 0AA

Markdown's two trailing spaces are deliberately *not* honoured, because an
invisible notation is not a notation. You cannot see it, so you cannot debug
it, and you can type it by accident.

## Lists

- A bulleted item.
- Another, long enough to wrap so you can see how a continued line sits
  against the bullet above it.
- A third.

1. A numbered item.
2. A second.
3. A third.

> A blockquote sits in a tinted panel with a rule down its left edge. On paper
> the tint drops away and only the rule survives, because a grey panel that
> looks quiet on screen costs real ink and reads heavy on the page.

## Tables

A browser has a real CSS engine, so this is a genuine ruled table: the header
row repeats on every printed page and no row is ever split across a page break.

| Element | Face | Size | Note |
|---|---|---|---|
| body | Gill Sans | 11.5pt | measured to ~67 characters |
| headings | Georgia | 16 / 12.5 / 11 / 10.5pt | serif against sans |
| code | SF Mono | 9pt | smaller, or it shouts |
| diagrams | SF Mono | 12.5px | dark on screen, outlined on paper |

## Fenced blocks

A fenced block becomes a dark panel on screen and an outlined, ink-cheap one on
paper. Whitespace is preserved exactly, so ASCII diagrams survive:

```
   ┌────────────┐        ┌────────────┐
   │  Markdown  │───────▶│   render   │
   └────────────┘        └─────┬──────┘
                               │
                   ┌───────────┴───────────┐
                   ▼                       ▼
            ┌────────────┐          ┌────────────┐
            │   screen   │          │   paper    │
            │  the sheet │═════════▶│  the sheet │
            └────────────┘   same   └────────────┘
                           stylesheet
```

The panel never splits across a page break.

---

## Links

An [external link](https://example.com) prints black, with its URL spelled out
after it in small grey type, so a paper copy stays traceable. A [[wikilink]]
renders as a styled span rather than a link, because the page it points at may
not exist outside your own notes.

## Images

`![alt](path)` embeds the image as a data URI — the page carries its own
pictures and survives being moved or emailed. A missing image is a **hard
failure at render time**, never a silent omission: a letter that renders
without its signature looks finished and is not.

Alt text of exactly `signature` sets the image at letter scale (46mm on a
118mm measure — about a third of the line, which is what a signed letter looks
like). Any other alt text gives a centred figure.

## The end

If everything above set correctly, the system is working. Now run
`pdf-measure` on the PDF and check where your machine actually landed.
