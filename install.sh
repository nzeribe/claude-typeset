#!/usr/bin/env bash
# install.sh — make claude-typeset the DEFAULT way this machine makes PDFs.
#
#   bash install.sh            # install + wire it in as the default
#   bash install.sh --check    # just report what's present, change nothing
#
# A skill only fires when something triggers it. This also appends a short block
# to ~/.claude/CLAUDE.md, which Claude Code loads at the start of every session —
# so "make me a PDF" goes down this pipeline without anyone having to remember
# the skill exists. The block is fenced with markers and is idempotent: run this
# twice and it updates in place rather than duplicating.
#
# Nothing here is destructive. Your CLAUDE.md is backed up before it is touched.

set -euo pipefail

SKILL_DIR="${HOME}/.claude/skills/typeset"
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
START='<!-- claude-typeset:start -->'
END='<!-- claude-typeset:end -->'
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_ONLY=false
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; }

echo
echo "  claude-typeset"
echo "  ──────────────────────────────────────────────────────────"

# --- requirements ------------------------------------------------------------
if command -v python3 >/dev/null 2>&1; then
  ok "python3 $(python3 -c 'import sys;print(".".join(map(str,sys.version_info[:3])))')"
else
  bad "python3 not found — the three PDF tools need it"; exit 1
fi

if python3 -c 'import fitz' >/dev/null 2>&1; then
  ok "PyMuPDF"
else
  warn "PyMuPDF missing — pdf-measure, pdf-check and pdf-paginate need it:"
  echo "      pip install pymupdf"
fi

BROWSER=""
for b in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium" \
  "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
  /usr/bin/google-chrome /usr/bin/google-chrome-stable \
  /usr/bin/chromium /usr/bin/chromium-browser /snap/bin/chromium
do
  [[ -x "$b" ]] && { BROWSER="$b"; break; }
done
if [[ -n "$BROWSER" ]]; then
  ok "browser — $(basename "$BROWSER")"
else
  warn "no Chromium-family browser found. --pdf needs one (it is the typesetter:"
  echo "      the only engine that draws a real ruled table). Chrome/Chromium/Brave/Edge."
fi

# --- the skill itself ---------------------------------------------------------
if [[ "$HERE" == "$SKILL_DIR" ]]; then
  ok "skill installed at $SKILL_DIR"
elif [[ -L "$SKILL_DIR" && "$(cd "$SKILL_DIR" && pwd -P)" == "$HERE" ]]; then
  ok "skill already linked: $SKILL_DIR → $HERE"
elif [[ -e "$SKILL_DIR" ]]; then
  warn "something already at $SKILL_DIR — leaving it alone."
  echo "      This repo is at $HERE. If that other thing is an older clone of this,"
  echo "      update it with:  git -C \"$SKILL_DIR\" pull"
else
  if $CHECK_ONLY; then
    warn "skill not installed (would symlink $SKILL_DIR → $HERE)"
  else
    mkdir -p "$(dirname "$SKILL_DIR")"
    ln -s "$HERE" "$SKILL_DIR"
    ok "linked $SKILL_DIR → $HERE"
  fi
fi

chmod +x "$HERE"/bin/* 2>/dev/null || true

# --- make it the default ------------------------------------------------------
BLOCK="$(cat "$HERE/default-style.md")"

if [[ -f "$CLAUDE_MD" ]] && grep -qF "$START" "$CLAUDE_MD" 2>/dev/null; then
  if $CHECK_ONLY; then
    ok "already the default in $CLAUDE_MD"
  else
    cp "$CLAUDE_MD" "$CLAUDE_MD.bak-$(date +%Y%m%d%H%M%S)"
    python3 - "$CLAUDE_MD" "$START" "$END" <<'PY' "$BLOCK"
import sys, pathlib
path, start, end = sys.argv[1], sys.argv[2], sys.argv[3]
block = sys.argv[4]
p = pathlib.Path(path); s = p.read_text()
a, b = s.index(start), s.index(end) + len(end)
p.write_text(s[:a] + block.strip() + s[b:])
PY
    ok "refreshed the default block in $CLAUDE_MD (previous version backed up)"
  fi
elif $CHECK_ONLY; then
  warn "not yet the default — would append a block to $CLAUDE_MD"
else
  mkdir -p "$(dirname "$CLAUDE_MD")"
  [[ -f "$CLAUDE_MD" ]] && cp "$CLAUDE_MD" "$CLAUDE_MD.bak-$(date +%Y%m%d%H%M%S)"
  { [[ -s "$CLAUDE_MD" ]] && printf '\n'; printf '%s\n' "$BLOCK"; } >> "$CLAUDE_MD"
  ok "made it the default — appended to $CLAUDE_MD"
fi

echo "  ──────────────────────────────────────────────────────────"
if $CHECK_ONLY; then
  echo "  (--check: nothing was changed)"
else
  cat <<'EOF'
  Done. Start a new Claude Code session and ask it to make a PDF of
  anything — it will go down this pipeline without being told to.

  See it working first:

      ~/.claude/skills/typeset/bin/render-doc \
        ~/.claude/skills/typeset/examples/specimen.md --pdf
      ~/.claude/skills/typeset/bin/pdf-measure \
        ~/.claude/skills/typeset/examples/specimen.pdf

  That second command tells you where YOUR machine landed. If it is
  outside 45-75 characters it prints the column width to try next.
EOF
fi
echo
