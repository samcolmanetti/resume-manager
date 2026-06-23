# resume-manager

A code-based LaTeX resume system. Content lives in plain `.tex` files using a small set
of semantic macros; all formatting lives in `resume.cls`. One command produces a polished,
ATS-friendly, single-page PDF.

This is the **public engine**. Your real resume content stays in a **separate private
repo** and is never committed here. The engine and your content meet only at build time.

## How it works

```
resume-manager  (this repo, PUBLIC)        Your content repo (PRIVATE)
  resume.cls          engine                  resume-jane.tex     real data
  Makefile            build                    resume-jane-2026.tex
  resume-template.tex clean example                 │
  .claude/ .agents/   skills                        │ git clone
  docs/               conventions                   ▼
  resumes/   ◄── gitignored ──────────────►  resumes/  (the private repo, cloned here)
  build/     ◄── gitignored (output PDFs)
```

- `resumes/` and `build/` are **gitignored** in this repo. Real content never lands in
  public history.
- The build globs `resumes/resume-*.tex`. On a fresh public clone with no `resumes/`, it
  falls back to `resume-template.tex` so the engine still builds and validates.
- `make check` (and an optional pre-commit hook) enforces that no private content is ever
  tracked here.

## Prerequisites

- **xelatex**: ships with [MacTeX](https://tug.org/mactex/) or BasicTeX
- **Charter** system font: ships with macOS (required by `resume.cls`)
- **pdftotext**: optional, used by the verification checks (ships with MacTeX)

If building on Linux or a machine without Charter, see [Font fallback](#font-fallback).

## Setup

**One-time, with an existing private content repo:**

```bash
git clone <your-public-resume-manager> resume-manager
cd resume-manager
git clone <your-private-content-repo> resumes   # real .tex files land in resumes/
make                                             # build resumes/resume-*.tex -> build/
```

**Starting fresh (no private repo yet):**

```bash
git clone <your-public-resume-manager> resume-manager
cd resume-manager
mkdir resumes && (cd resumes && git init)        # your new PRIVATE content repo
cp resume-template.tex resumes/resume-yourname.tex
# edit resumes/resume-yourname.tex with your content
make
open build/resume-yourname.pdf
```

Then create a **private** repo on GitHub and push the `resumes/` directory to it. Keep it
private: it holds your real data.

## Daily workflow

```bash
cd resumes && git pull && cd ..   # get latest content
# edit resumes/resume-yourname.tex (or use the `resume` Claude skill)
make                              # rebuild all -> build/
# commit content changes INSIDE resumes/ (the private repo)
```

## File naming convention

| Pattern | Purpose |
|---------|---------|
| `resumes/resume-NAME.tex` | Active resume for user NAME |
| `resumes/resume-NAME-YEAR.tex` | Yearly archive (e.g. `resume-jane-2026.tex`) |
| `resume-template.tex` | Starter scaffold at the repo root (the only tracked `.tex` here) |

## Build

```bash
make                         # build resumes/resume-*.tex (or the template if none)
make build/resume-NAME.pdf   # build one specific file (NAME = basename, no resumes/ prefix)
make check                   # verify no private content is tracked by this repo
make clean                   # remove all build artifacts
make help                    # show available targets
```

The build runs `xelatex` from the repo root so `\documentclass{resume}` resolves
`resume.cls` even though the source lives in `resumes/`. Output names are flattened:
`resumes/resume-jane.tex` builds to `build/resume-jane.pdf`.

## Macros

Content files use only these macros (defined in `resume.cls`):

| Macro | Purpose |
|-------|---------|
| `\name{...}` | Centered name header |
| `\location{City, ST}` | Optional centered line under the name |
| `\contact{a \sep b \sep c}` | Centered contact line (`\sep` = separator) |
| `\section{Title}` | Bold uppercase section heading + rule |
| `\edu{School}{Right}{Degree line}{Right}` | Two-line education entry |
| `\skill{Label}{values}` | A `Label: values` skills line |
| `\entry{Role, Company, Location}{Dates}` | Bold experience header (dates flush right) |
| `\begin{bullets} \item ... \end{bullets}` | Compact bullet list |
| `\oneline{Left}{Right}` | One-line entry with right-aligned text/date |

Never put spacing or font commands in a content file. All layout lives in `resume.cls`.

## Adding new section types

Open `resume.cls` and add a `\newcommand` or `\newenvironment`; the file has a comment
block near the top explaining the pattern. Then use the new macro in your content file.

## Export to Google Drive (or anywhere)

1. Copy `config.local.mk.example` to `config.local.mk` (gitignored; your paths stay private)
2. Fill in `EXPORT_DIR` and `EXPORT_NAME`
3. Run `make export FILE=resume-yourname`

```bash
cp config.local.mk.example config.local.mk
# edit config.local.mk
make export FILE=resume-jane
```

## House rules

- **One page.** After every edit, confirm the build log says `(1 page)`.
- **No em dashes** (`—`). Use commas, semicolons, or restructure the sentence.
  En dashes (`--`) in date ranges are fine.
- **No orphan lines.** No bullet wraps to a trailing line of 1-2 words.
- **ATS-friendly.** Single column, selectable text, standard font, no text in graphics.

## Verify your build

Run these four checks after every content edit (`NAME` = your file's basename):

```bash
# 1. One page - must print "(1 page)"
grep -oE '\([0-9]+ pages?\)' build/resume-NAME.build.log | tail -1

# 2. No orphan lines - only section headers may appear (1-2 words)
pdftotext -layout build/resume-NAME.pdf - | awk 'NF>0 && NF<=2'

# 3. No em dashes - both commands must print nothing
grep -n -- "---" resumes/resume-NAME.tex
pdftotext -layout build/resume-NAME.pdf - | grep "—"

# 4. No overfull boxes
grep -i overfull build/resume-NAME.build.log
```

## Adding a new user

1. Ensure `resumes/` exists (clone your private repo or `mkdir resumes && cd resumes && git init`)
2. Copy the template: `cp resume-template.tex resumes/resume-yourname.tex`
3. Replace placeholder text with your content
4. Run `make` to verify it builds as 1 page
5. Copy `config.local.mk.example` to `config.local.mk` and set your export path

If you use Claude Code, the `/new-user` skill walks through these steps automatically.

## Keeping content out of the public repo

This repo must never track real resume content. Three layers enforce that:

1. `.gitignore` ignores `resumes/` and `build/`.
2. `make check` (`scripts/check-no-content.sh`) fails if any `resumes/` file or any root
   `.tex` other than `resume-template.tex` is tracked.
3. Optional pre-commit hook:
   ```bash
   ln -s ../../scripts/check-no-content.sh .git/hooks/pre-commit
   ```

## Font fallback

If building on a machine without Charter, change `\setmainfont{Charter}` in
`resume.cls` to another installed serif (e.g. `TeX Gyre Termes`, `Latin Modern Roman`).
