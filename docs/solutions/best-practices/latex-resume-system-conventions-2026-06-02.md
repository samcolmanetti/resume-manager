---
module: resume
date: 2026-06-02
problem_type: best_practice
component: tooling
severity: medium
tags: [latex, xelatex, resume, one-page, ats, basictex, typography]
applies_when:
  - Editing or extending the code-based resume in this repo
  - Adding a new yearly resume variant
  - Debugging a build, one-page-fit, or typography issue
---

# Code-based LaTeX resume: conventions, acceptance criteria, and gotchas

## Context

This repo renders a one-page resume from `.tex` content files plus a single
formatting class (`resume.cls`), built with `xelatex` and the macOS system font
**Charter**. The system was built to replace a hand-maintained Word `.docx`.
Across the first session a set of acceptance criteria, build/verify steps, and
LaTeX gotchas emerged that are easy to re-trip on. This captures them so future
edits start from the known-good baseline instead of rediscovering it.

The companion **`resume` skill** (`.claude/skills/resume/SKILL.md`) operationalizes
this doc as a step-by-step edit/verify loop. This file is the rationale; the skill
is the procedure.

## Guidance

### Acceptance criteria (every build must pass all of these)

1. **Exactly one page.** Build log must say `(1 page)`.
2. **No em dashes** (`—` / `---` in source). Em dashes are a strong "AI-written"
   tell. Use semicolons, commas, or restructure. En dashes (`--`) in date ranges
   are fine and expected.
3. **No orphan trailing lines** — no bullet or entry should wrap to a final line of
   just 1–2 words. Only section headers may be short.
4. **No words split across two lines.** Avoid mid-word hyphenation breaks
   (e.g. "hos-pitality"). Wrap a vulnerable word in `\mbox{...}` or reword.
5. **Not too dense.** Keep deliberate breathing room between sections and entries;
   the page should not look like a wall of text.
6. **ATS-friendly.** Single column, selectable text, standard font, no text inside
   graphics. Verify by extracting text.
7. **Clean/professional.** Consistent alignment, dates flush-right, no overfull-box
   warnings.

### Build + verify workflow

```bash
# From the repo root (NAME = your file's name, e.g. resume-jane).
export PATH="/Library/TeX/texbin:$PATH"
make build/resume-NAME.pdf                  # prints "(N page)"

# Orphan / short-line scan (only section headers should appear):
pdftotext -layout build/resume-NAME.pdf - | awk 'NF>0 && NF<=2'

# Em-dash scan (must be empty in BOTH source and rendered text):
grep -n -- "---" resumes/resume-NAME.tex
pdftotext -layout build/resume-NAME.pdf - | grep "—"

# Bottom-slack measurement — how full is the page (page is 1650px tall @150dpi,
# bottom margin ~67px). Use to decide whether there's room to add spacing:
sips -s format png --resampleWidth 1275 build/resume-NAME.pdf --out build/inspect.png
magick build/inspect.png -fuzz 8% -trim info:   # WxH+xoff+yoff: content_bottom = yoff+H
```

`pdftotext -layout` line breaks are a faithful proxy for the PDF's visual wraps —
trust it for the orphan and word-split checks without rendering an image.

### Content / style conventions

- **Source of truth for content** is whatever authoritative source you maintain
  (a master `.docx`, a prior PDF, etc.); port faithfully, then apply the editorial rules.
- **All formatting lives in `resume.cls`.** Content files use only the semantic
  macros (`\name`, `\location`, `\contact`, `\section`, `\edu`, `\skill`, `\entry`,
  `bullets`, `\oneline`). Never put spacing/font commands in a content file.
- **Oxford commas** throughout (matches existing bullets).
- **Skills lines**: avoid redundant slashes — `TypeScript` not `JavaScript/TypeScript`,
  `Go` not `Go/Golang`, `C++` not `C/C++`. Keep meaningful groupings (`Hack/PHP`,
  `Android (Java/Kotlin/C++ JNI)`, `PostgreSQL/MySQL/MongoDB`). GraphQL leads
  Backend/Data; Android leads Web/Mobile.
- **Location** lives in the header (`\location{New York, NY}` under the name).
- Bullets fit one line where possible; if they wrap, the second line must carry
  ≥3 words (pad with an accurate qualifier or trim — don't leave 1–2 words).

### Gotchas specific to this toolchain

- **BasicTeX, not full MacTeX.** `titlesec`, `enumitem`, `microtype` are NOT
  installed. The class is intentionally written with base packages only
  (`geometry`, `fontspec`, `xcolor`, `hyperref`) plus hand-rolled `\section` and a
  `list`-based `bullets` env. Don't reintroduce those packages without `tlmgr install`.
- **Charter has no bold-small-caps shape.** Section headers use bold UPPERCASE
  (`\MakeUppercase`), not `\scshape`, to avoid a missing-font-shape warning.
- **`C++` renders with a gap** between the plus signs in Charter. Use the `\pp`
  macro (`C\pp`) which kerns them tight.
- **Font size is stored as bare pt numbers** (`\resume@ptsize` / `\resume@leading`),
  because `\fontsize` arithmetic like `1.18\resume@ptsize` errors when the value
  carries a unit. Body size is **10pt** — 10.5pt overflows to two pages with the
  current content.
- **Centered header blocks add stray vertical space.** The header macros use
  `{\centering ... \par}` (not the `center` environment) so spacing is explicit and
  tight; reclaimed space was redistributed into `\section`/`\entry` gaps.

## Why This Matters

One page is a hard constraint, and the failure modes (an extra line tipping to page
two, a lone "deals." orphan, a "hos-pitality" split, a stray em dash) are subtle and
recur on every content edit. A fixed checklist plus the `pdftotext`/slack-measurement
commands turns "eyeball it and hope" into a deterministic pass/fail, so edits stay
fast and the result stays clean. The toolchain gotchas (BasicTeX packages, Charter
shapes, the `\fontsize` unit bug) each cost a build cycle to rediscover.

## When to Apply

- Any content or formatting edit to a `resume-*.tex` file or `resume.cls`.
- Starting a new yearly variant (`cp resumes/resume-NAME-2026.tex resumes/resume-NAME-2027.tex`).
- When a build flips to two pages, shows overfull boxes, or a reviewer says it
  "looks AI-generated" (check em dashes first).

## Examples

- **Kill an orphan by padding the tail, not trimming the head.** To make a wrapped
  bullet's last line fuller, add an accurate word near the *end* (e.g. "drive
  **automated** remediation workflows") — trimming earlier text pulls more onto line
  one and makes the orphan worse.
- **Prevent a word split:** `... and \mbox{hospitality} operations ...` keeps
  "hospitality" whole instead of hyphenating across the line break.
- **Remove an em dash:** `Excellence in Computer Science (State University) ---
  granted to ...` → `... (State University), awarded to ...`.
