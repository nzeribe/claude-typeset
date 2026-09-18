# The Doctrine

Fifteen rules for setting a document from Markdown, each one the residue of a
specific failure. None of them is a preference. Where a number appears it was
arrived at by measuring a printed page, not by arithmetic, and the rule says so.

The book behind all of it is Robert Bringhurst, *The Elements of Typographic
Style*. What follows is not a summary of that book — it is what happened when
one chapter of it was aimed at a real pipeline that was producing ugly PDFs.

---

## Part I — The page

### 1. The measure is the first rule, and it is the whole game

**45–75 characters per line. 66 is ideal.** (Bringhurst, §2.1.2.)

Past about 75 characters the eye loses the line on the return sweep, and a page
of text stops being text and becomes a grey slab. Below about 45 the line
stutters and the reader spends more attention on returning than on reading.

Every ugly document begins here. Not with the font — with the measure. A
default print margin of 30 points on A4 leaves a 189mm column, which at a
normal body size is about **97 characters**: hopeless, and hopeless in a way
that looks like "the font is wrong" or "the theme is ugly" to everyone who has
not been told what to look at.

The measure is set by the column width, so it is the column you control:

```
render-doc report.md --pdf --measure 118mm
```

Everything else in this document is downstream of that one number.

### 2. Measure the artefact. Never compute the measure

**The point size does not carry the measure across a change of font or of
rendering engine.** This is the rule that cost the most to learn.

The same nominal size of the same named font, on the same column width, gave
**68 characters** through one renderer and **89** through another. The reason
is visible in this very repository: run `pdf-measure` on the specimen and the
body face comes back as `Unnamed-T3` — the browser embedded Gill Sans as a
*Type 3* face, setting it substantially narrower than the system's own
typesetter does.

So you cannot reason your way to a measure. You render, you measure the PDF,
and you adjust:

```
render-doc report.md --pdf
pdf-measure report.pdf          # → median 70 characters. In the band.
```

**Corollary, and the one people skip:** if you change the body font, the old
measure is void. `--measure` and `--body-font` move together, always. On a
machine with no Gill Sans the fallback sets at a different width and a column
tuned elsewhere will be out of band on arrival. Measure on *your* machine, on
*your* document, the first time — then never think about it again.

### 3. One stylesheet, two outputs

**What you see must be what prints.** Not approximately — actually.

The failure this replaces: a 940px web page on screen and a 118mm column on
paper, from one source file. Two different documents, one of which nobody ever
looked at until it came out of the printer. Desktop publishing was predicated
on what-you-see-is-what-you-get, and a preview that lies is worse than no
preview, because it is trusted.

So the screen shows **the page**: a white sheet on a grey desk, at the real
measure, in the real face, at the real size. The print stylesheet then does
exactly one thing — *it takes away the desk*. It removes the background, the
shadow and the rounded corner, and it changes nothing about how the text sets.
Every decision that governs the setting is written once, above the print block.

The cost is real and was accepted deliberately: the wide comfortable reading
column is gone from the screen. Screen reading is tighter in exchange for the
printed page being **knowable**. That is a good trade for anything that will be
printed and a bad one for anything that won't — so use this for documents, not
for web pages.

### 4. Dark mode dims the desk, not the sheet

A page is a page. In dark mode the *desk* goes dark and the paper is knocked
back off pure white so it isn't a torch in a dark room — but the paper stays
light and the ink stays dark. Invert the sheet and rule 3 is broken: what is on
screen is no longer what prints.

### 5. Serif headings against a humanist sans body

The pairing here is Georgia over Gill Sans. The contrast is **structural, not
decorative**: it says a heading is a different *kind* of thing from the text,
rather than a louder version of it. The same document set in one family with
size and weight doing all the work reads as an outline; set in two it reads as
a document.

Sizes fall away fast — 16 / 12.5 / 11 / 10.5pt against an 11.5pt body. A
heading needs to be *distinguishable*, not large. If you find yourself wanting a
fifth heading level, the document wants to be two documents.

### 6. A document must be self-contained

Images are embedded as `data:` URIs, never linked. The page carries its own
pictures and survives being moved, emailed, or opened on a machine with no
network. A linked image breaks the moment the file travels — which is the only
moment that matters, because travelling is what a document is for.

**A missing image is a hard failure at render time.** Not a broken-image icon,
not a silent omission — the render stops. A letter that renders without its
signature *looks finished and is not*, and it will pass every text-based check
you have, because all the words are present.

### 7. A real table needs a real CSS engine

Use a browser. The system typesetter behind most "print to PDF" paths cannot
draw a table at any price — tested with CSS `border-collapse` and with legacy
`border=` attributes; both flatten every cell onto its own line, silently.

A browser has a genuine CSS engine, so ruled tables, page-break control and
repeating header rows all work. This is the single technical reason the
pipeline ends in headless Chrome rather than anything more elegant.

### 8. Page-break discipline is typography, not plumbing

On paper, four rules earn their keep:

- **Never break after a heading.** A heading alone at the foot of a page is a
  promise the page does not keep.
- **Orphans and widows: 3.** No single line of a paragraph stranded on its own
  page.
- **Repeat the header row** of a table on every page (`thead` as a
  `table-header-group`), and **never split a row**.
- **Never split a fenced block.** An ASCII diagram cut in half is not a diagram.

### 9. Ink is not free

A screen affordance is not a paper affordance. The dark panel that makes a
fenced block legible on screen becomes, on paper, a page-sized slab of toner —
so on paper it inverts to a thin outlined box at a smaller size. Tinted
blockquote panels lose the tint and keep the rule.

Links print black, with the URL spelled out after them in small grey type, so a
paper copy stays traceable — but only *external* links earn that tail. An
anchor link with its href printed after it is noise.

---

## Part II — The notation

### 10. An invisible notation is not a notation

Markdown's hard line break is two trailing spaces. It is unusable in a document
system: you cannot see it, so you cannot debug it, and you can type it by
accident — in the corpus this was built against, trailing whitespace already
sat mid-paragraph in 72 lines.

So the hard break here is **a trailing backslash**:

```
The Manager\
Something Ltd\
14 Some Street
```

It appears nowhere in ordinary prose, cannot be typed by accident, and is
visible on the screen you are typing on.

The failure that produced this rule: a three-line signature block rendering as
one long run-on line, and the letterhead and recipient address collapsing the
same way — unnoticed, on **every letter the tool had ever produced**. A whole
class of document was quietly wrong for months because the notation for
"break here" was made of nothing.

### 11. Compute what a machine can compute. Author what carries judgement

Page numbers, a contents table's page column, "page N of T" — a machine can
derive all of these from the finished PDF, so a human must never hand-keep
them. A hand-kept derived field rots silently: it is right on the day it is
written and wrong forever after, and nothing announces the change.

The inverse is equally strict. A field carrying judgement — a summary, a
caption, a heading — must never be auto-filled, because it will be filled with
something empty.

```
pdf-paginate report.pdf "Acme Ltd · Q3 Review"     # computed, every time
```

### 12. Hard-number anything that will be cited

**Markdown renderers restart ordered lists at 1.** Source that reads 6, 7, 8
prints as 1, 2, 3 — silently, and a document with two paragraphs numbered "1"
is a document whose cross-references all point at nothing.

If a number will be *cited* by anyone — a reply, a reviewer, another document —
write it as literal text in its own paragraph (`**6.** The respondent…`), not
as a list item. Then verify the printed sequence rather than trusting it.

(Hard-numbering costs a page here and there, because each item becomes its own
paragraph. Repaginate afterwards: the page count changed.)

---

## Part III — The proof

### 13. Verify the artefact, not the source

**`strings file.pdf | grep TODO` lies.** It returns clean on documents that are
visibly contaminated, because a PDF's text lives in compressed streams that
`strings` cannot read. Three documents once passed that check with a count of
zero while being full of unresolved markers and internal commentary; a proper
extraction found every leak in seconds.

Read the PDF with a library that can actually read it:

```
pdf-check report.pdf --expect "the phrase only this version has"
```

**The second lesson is larger than the first: a check only finds what it is
told to look for.** The leak check above did not catch `&nbsp;` printing
literally as seven characters in a finished document, twice, because nobody had
told it to look. When a defect gets through, **widen the check** — do not just
fix the instance.

Never use `&nbsp;` for indentation. Use two real leading spaces, or flush text.

### 14. A folder a pack is assembled from holds exactly one PDF per document

Re-rendering does not reliably overwrite. Repeated builds leave `report 2.pdf`,
`report 3.pdf` beside the current file, and where a filename ends in a year the
collision logic increments *the year* — producing a sibling that reads as a
genuinely differently-dated document. One real folder held six PDFs for three
documents, including a covering letter apparently dated a year into the future.

Nothing in a filename says "superseded". So:

```
ls -1 *.pdf                 # exactly one per document
```

Park the rest in `_superseded/` — move, never delete; a deleted build cannot be
compared against. Then identify the survivor by **what it contains that the
stale ones don't**: pick a phrase only the newest version has and pass it to
`pdf-check --expect`. A stale build is recognised by what it is *missing*.

### 15. One command, no settings

```
render-doc report.md --pdf
```

Not a print dialog. Not an app's export panel. Not "remember to set the margins
to None and background graphics ON".

Every settings dialog is a place for the design to be lost by someone in a
hurry, including you. The margins, the measure, the face and the page-break
rules are decisions that were made once, with evidence, and written down in a
stylesheet. A dialog invites them to be re-made, badly, at the worst moment —
and the person who re-makes them will not know that the 35mm margin was not
taste.

Put the decisions in the tool. Then the tool is the decision.

---

## The loop, in four lines

```
render-doc report.md --pdf                    # set it
pdf-measure report.pdf                        # first time on a machine, or after a font change
pdf-paginate report.pdf "Label · Title"       # LAST — render rewrites the file
pdf-check report.pdf --expect "newest phrase" # before it leaves the house
```

---

*Rules 1, 5 and 8 are Bringhurst, applied. The rest were paid for.*
