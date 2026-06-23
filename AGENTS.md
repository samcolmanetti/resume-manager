# AGENTS.md

Code-based one-page resume system, split into a **public engine** (this repo) and
**private content**. Formatting lives in `resume.cls`; real content lives in
`resume-NAME.tex` files inside the gitignored `resumes/` directory, which is a clone of a
separate PRIVATE repo. Built with `xelatex` and the system Charter font.

- `make` builds every `resumes/resume-*.tex` to `build/` (falls back to the root
  `resume-template.tex` when no private content is present).
- `make build/resume-NAME.pdf` builds one file (NAME = basename, no `resumes/` prefix).
- The build runs from the repo root so `\documentclass{resume}` resolves `resume.cls`
  even though sources live in `resumes/`.

## Content is private; this repo is public

Real resume content must NEVER be committed to this repo. It lives in the gitignored
`resumes/` clone (a separate private repo). `resumes/` and `build/` are gitignored, and
`make check` (`scripts/check-no-content.sh`) fails if any private content is tracked here.
When editing content, commit inside `resumes/` (the private repo), not at the public root.

## Output / publishing

The finished PDF is published to a personal folder (Google Drive or similar). Each user
configures their own export path in a gitignored `config.local.mk` file (see
`config.local.mk.example`).

- `make export FILE=resume-NAME` builds and copies the PDF to your configured `EXPORT_DIR`.
- If `config.local.mk` is missing, the Makefile prints an actionable error.

## Working on a resume

Use the **`resume` skill** (`.claude/skills/resume/SKILL.md`) for any content or
formatting edit. It detects the target file in `resumes/`, builds, and runs all
acceptance-criteria checks.

To add a new user, use the **`new-user` skill** (`.claude/skills/new-user/SKILL.md`).

## Knowledge store

`docs/solutions/`: documented conventions and solutions with YAML frontmatter.
Start with `docs/solutions/best-practices/latex-resume-system-conventions-2026-06-02.md`
for toolchain gotchas and acceptance criteria.

## Conventions

- Never put spacing/font commands in content files (`resume-NAME.tex`). Change `resume.cls` instead.
- Real content stays in the private `resumes/` clone; never commit it to this public repo.
- Commit messages: no AI attribution.
