# Resume Manager

![Resume preview](docs/preview.png)

A code-based LaTeX resume system. Content lives in plain `.tex` files, formatting
lives in `resume.cls`, and one command builds a polished, ATS-friendly, single-page PDF.

**Why keep your resume in code:**

- **Version control.** Track every change, revert anything, see exactly what you edited and when.
- **AI-native.** Agents can read, edit, and reason about plain text. PDFs are opaque blobs.
- **Tailored versions.** Branch or duplicate for each job posting, diff what changed, merge improvements back.
- **Separation of concerns.** Content and formatting are independent. Tweak spacing or fonts in one place without touching your content.
- **Automation.** Skills for bullet rewriting, ATS optimization, job match scoring, and more run directly in your editor.

## AI agents

This repo includes skills for agents in `.claude/skills/` or `.agents/skills/`. Ask natural questions, or invoke a skill directly.

**Getting started**

- `/new-user`: scaffold a new resume from the template, replace placeholders, verify it builds
- `/resume`: make content edits and verify against acceptance criteria (one page, no em dashes, no orphans)

**Improving content**

- `/resume-bullet-writer`: rewrite weak bullets as achievement-focused statements with impact
- `/resume-quantifier`: find opportunities to add metrics; estimates where exact data is unavailable
- `/resume-tailor [job posting]`: customize the resume for a specific role without inventing facts
- `/tech-resume-optimizer`: optimize framing for software engineering and technical roles

**Job search**

- `/job-description-analyzer [posting]`: score your resume against a job description, identify gaps
- `/resume-ats-optimizer`: check ATS compatibility and keyword match

## Prerequisites

- **xelatex**: ships with BasicTeX (all required packages are included, no `tlmgr` installs needed)
- **Charter** system font: ships with macOS
- **pdftotext**: optional, for quality checks

```bash
brew install --cask basictex   # ~100 MB
brew install poppler           # optional: adds pdftotext for quality checks
```

## Setup

```bash
git clone https://github.com/samcolmanetti/resume-manager
cd resume-manager
mkdir resumes
cp resume-template.tex resumes/resume-yourname.tex
# edit resumes/resume-yourname.tex
make
open resumes/resume-yourname.pdf
```

`PDFs go under resumes/` by default (gitignored). 

To export a finished PDF to Google Drive, Dropbox, or any folder on your machine,
copy `config.local.mk.example` to `config.local.mk` and set:

- `EXPORT_DIR` - destination folder (e.g. `~/GoogleDrive/Resumes/Current`)
- `EXPORT_NAME` - filename for the exported copy (e.g. `Sam Colmanetti Resume 2026.pdf`)

Then `make export FILE=resume-yourname` builds and drops the PDF there.

## Build

```bash
make                          # build all resumes/resume-*.tex -> resumes/
make resumes/resume-NAME.pdf  # build one file
```

## Macros

Content files use only these macros (all formatting stays in `resume.cls`):

| Macro | Purpose |
|-------|---------|
| `\name{...}` | Centered name header |
| `\location{City, ST}` | Optional centered line under the name |
| `\contact{a \sep b \sep c}` | Centered contact line |
| `\section{Title}` | Bold uppercase section heading + rule |
| `\edu{School}{Right}{Degree line}{Right}` | Two-line education entry |
| `\skill{Label}{values}` | `Label: values` skills line |
| `\entry{Role, Company, Location}{Dates}` | Bold experience header |
| `\begin{bullets} \item ... \end{bullets}` | Compact bullet list |
| `\oneline{Left}{Right}` | One-line entry with right-aligned text |

Never put spacing or font commands in a content file. Change `resume.cls` instead.

## House rules

- **One page.** Confirm the build log says `(1 page)` after every edit.
- **No em dashes** (`—`). Use commas, semicolons, or restructure.
- **No orphan lines.** No bullet wraps to a trailing line of 1-2 words.
- **ATS-friendly.** Single column, selectable text, standard font, no text in graphics.
