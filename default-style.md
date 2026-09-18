<!-- claude-typeset:start -->
## Documents and PDFs — the default

Any document that becomes a PDF — report, letter, proposal, invoice, schedule,
activity report, specification — is set through the **typeset** skill. Never a
browser print dialog, never an editor's preview, never an app's export panel.
Read `~/.claude/skills/typeset/SKILL.md` before the first render in a session.

```bash
T=~/.claude/skills/typeset/bin
$T/render-doc <file>.md --pdf                    # set it
$T/pdf-check  <file>.pdf                         # verify BEFORE it is sent
```

**The measure is the first rule: 45–75 characters per line, 66 ideal.** It
cannot be computed, only measured off the finished PDF. Run
`$T/pdf-measure <file>.pdf` on the first render on this machine, after any
change of body font, and any time output "looks cheap" — that complaint is
almost never the font.

Multi-page documents get page numbers, computed and stamped **last**, because
rendering rewrites the PDF:

```bash
$T/pdf-paginate <file>.pdf "<label>"
```

When writing the Markdown: hard line breaks are a **trailing backslash** (not
two trailing spaces); hard-number any paragraph that will be cited, because
renderers restart ordered lists at 1; never `&nbsp;` — it prints literally.

Full reasoning, and what each rule cost: `~/.claude/skills/typeset/DOCTRINE.md`.
<!-- claude-typeset:end -->
