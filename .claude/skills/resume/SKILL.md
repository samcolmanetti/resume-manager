---
name: resume
description: >-
  Make edits to any user's code-based one-page LaTeX resume in this repo and
  verify them against fixed acceptance criteria. Use whenever changing content
  or formatting in resume-*.tex or resume.cls, starting a new yearly variant,
  or when a build breaks one-page fit or looks AI-generated. Triggers on
  "update the resume", "edit my resume", "add a bullet/role/skill", "fix the
  resume", "rebuild the resume", "start the 2027 resume".
---

# Resume edit + verify

This repo renders one-page resumes from `.tex` content files + `resume.cls`,
built with `xelatex` and the system **Charter** font. Your job when invoked:
make the requested edit, then prove it still meets every acceptance criterion
before reporting done.

Background and rationale live in
`docs/solutions/best-practices/latex-resume-system-conventions-2026-06-02.md`.
Read it if an edit fights the toolchain.

## Step 0: Identify the target file

Real resume content lives in the gitignored `resumes/` directory (a clone of your
PRIVATE content repo). Count the `resumes/resume-*.tex` files (excluding the
`resume-template.tex` scaffold):

```bash
ls resumes/resume-*.tex 2>/dev/null | grep -v resume-template.tex
```

- **One file found**: use it as `TARGET` (the basename, e.g. `resume-jane`).
- **Multiple files found**: ask the user which one they want to edit before
  proceeding. Store the answer as `TARGET` for use throughout this session.
- **Zero files found or `resumes/` missing**: no resume content is present. Tell the
  user to clone their private content repo into `resumes/`
  (`git clone <their-private-repo> resumes`) or run the `new-user` skill
  (`.claude/skills/new-user/SKILL.md`) to scaffold one, then stop.

`TARGET` is always the file's basename (e.g. `resume-jane`). The source file is
`resumes/TARGET.tex`; its built PDF and logs are flattened to `build/TARGET.pdf` and
`build/TARGET.build.log`. Substitute `TARGET` accordingly throughout this skill.

## Acceptance criteria (ALL must hold before you report done)

1. **Exactly one page**: build log says `(1 page)`.
2. **No em dashes**: zero `—`/`---` in source and rendered text. Use commas,
   semicolons, or restructure. En dashes (`--`) in date ranges are fine.
3. **No orphan trailing lines**: no bullet/entry wraps to a final line of just
   1-2 words. Section headers are the only allowed short lines.
4. **No words split across two lines**: no mid-word hyphenation (e.g. "hos-pitality").
5. **Not too dense**: keep breathing room between sections/entries; don't let
   the page become a wall of text.
6. **ATS-friendly**: single column, selectable text, standard font, no text in graphics.
7. **Clean**: dates flush-right, consistent alignment, no overfull-box warnings.

## Workflow

### 1. Locate the edit
- Content changes: the relevant `resumes/TARGET.tex`.
- Look/spacing changes: `resume.cls` only (never put spacing/font commands in content files).

### 2. Make the change
Use only the semantic macros: `\name`, `\location`, `\contact`, `\section`, `\edu`,
`\skill`, `\entry`, `bullets`, `\oneline`. Style rules:
- Oxford commas. `C\pp` for "C++" (kerns the plus signs).
- If a bullet must wrap, make its last line carry at least 3 words.

### 3. Build
```bash
export PATH="/Library/TeX/texbin:$PATH"
make build/TARGET.pdf    # prints "(N page)"
```
If the build fails, read `build/TARGET.build.log`.

### 4. Verify: run all four checks
```bash
# a) one page - must print "(1 page)"
grep -oE '\([0-9]+ pages?\)' build/TARGET.build.log | tail -1

# b) no orphan/short content lines - only SECTION HEADERS may appear
pdftotext -layout build/TARGET.pdf - | awk 'NF>0 && NF<=2'

# c) no em dashes - both commands must print nothing
grep -n -- "---" resumes/TARGET.tex
pdftotext -layout build/TARGET.pdf - | grep "—"

# d) no overfull boxes - must print nothing
grep -i overfull build/TARGET.build.log
```
For word-split (#4) and density (#5), render and look:
```bash
sips -s format png --resampleWidth 1275 build/TARGET.pdf --out build/inspect.png
magick build/inspect.png -fuzz 8% -trim info:   # content_bottom = yoff+H; slack = 1650-67-content_bottom
```
Read `build/inspect.png` to eyeball density and confirm no word is hyphenated across a
line break.

### 5. Fix failures, then reverify
- **Orphan (1-2 word last line):** pad the tail with an accurate word, or trim.
  Adding words near the *end* helps; trimming the head makes it worse.
- **Word split:** wrap the word in `\mbox{...}` or reword.
- **Two pages:** keep body font at 10pt; shorten/merge a bullet without dropping
  needed info; never shrink below 10pt.
- **Too dense / extra slack at bottom:** redistribute space via `\section`/`\entry`
  vspace in `resume.cls`.

### 6. Report
State the change, confirm "1 page", and that orphan/em-dash/overfull checks are clean.
Commit the edit inside `resumes/` (your private content repo), not in the public engine
repo (no AI attribution in messages).

## Starting a new year
```bash
cp resumes/TARGET.tex resumes/resume-NAME-YYYY.tex   # edit content; formatting is inherited
make build/resume-NAME-YYYY.pdf
```
Then run the full verify loop on the new file. Commit the new file inside `resumes/`
(your private repo), not in the public engine repo.

## Toolchain gotchas (don't relearn these)
- **BasicTeX**, not full MacTeX: `titlesec`/`enumitem`/`microtype` are absent - the
  class uses base packages only. Don't add them without `tlmgr install`.
- **Charter has no bold-small-caps** -> headers use bold `\MakeUppercase`.
- **Font size is bare pt numbers** in the class (`\fontsize` errors on unit arithmetic).
- **Header uses `{\centering ...\par}`**, not the `center` env, to avoid stray whitespace.
