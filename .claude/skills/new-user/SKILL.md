---
name: new-user
description: >-
  Add a new user to the resume repo by copying the template, replacing
  placeholders, and verifying the new file builds cleanly. Use when someone
  says "add a resume for NAME", "onboard NAME", "set up resume for NAME", or
  "create a resume for NAME".
---

# New user setup

All commands in this skill run from the repo root (the directory containing
`Makefile` and `resume-template.tex`). Verify with `ls resume-template.tex`
before proceeding.

Real resume content lives in the gitignored `resumes/` directory, which is a
clone of your PRIVATE content repo (see the README "Setup" section). This skill
creates the new content file **inside `resumes/`** so it is tracked by the
private repo, never by this public engine repo.

**First, ensure `resumes/` exists:**

```bash
ls resumes/ >/dev/null 2>&1 || echo "resumes/ missing"
```

If `resumes/` does not exist, tell the user to set it up first (one of):
- Clone their private content repo into it: `git clone <their-private-repo> resumes`
- Or start a fresh private content repo: `mkdir resumes && (cd resumes && git init)`

Do not create content files at the repo root. The `check` guardrail (`make check`)
will reject any real content tracked by this public repo.

This skill creates the new content file from the template, replaces placeholder
text, verifies it builds as exactly 1 page, and reminds the user to configure
local export.

## Step 1: Get the user's name

If the user hasn't provided a name, ask:
> "What name should I use for the file? (e.g. 'jane-doe' -> resume-jane-doe.tex)"

Derive a filename-safe slug: lowercase, hyphens for spaces, no special characters.
Example: "Jane Doe" -> `jane-doe`, "Sam" -> `sam`.

Set `SLUG` = the derived slug.

## Step 2: Create the content file

Check that `resumes/resume-SLUG.tex` does not already exist before proceeding. If it
does, warn the user and stop rather than overwriting their file.

```bash
cp resume-template.tex resumes/resume-SLUG.tex
```

Replace all placeholder text in `resumes/resume-SLUG.tex`:
- `Your Name` -> the user's actual full name (in `\name{}`, `\hypersetup`, and `pdfauthor`)
- `you@example.com` -> their email address (or leave as placeholder if not provided)
- `yourhandle` in the LinkedIn and GitHub URLs -> their handles (or remove those lines)
- `(555) 555-1234` -> their phone number (or remove if not provided)
- Keep the section structure; they'll fill in real content themselves

If the user provided their contact details up front, fill them in now. Otherwise,
leave the remaining placeholders for them to edit directly.

## Step 3: Build and verify

```bash
export PATH="/Library/TeX/texbin:$PATH"
make build/resume-SLUG.pdf
```

The build must say `(1 page)`. Verify from the build log (not make output, which may
be empty if the PDF was already built):

```bash
grep -oE '\([0-9]+ pages?\)' build/resume-SLUG.build.log | tail -1
grep -i overfull build/resume-SLUG.build.log
```

If the build fails, read `build/resume-SLUG.build.log` for the error.

(The build globs `resumes/resume-*.tex`, so `resume-SLUG.tex` is picked up
automatically; the output PDF name is flattened to `build/resume-SLUG.pdf`.)

## Step 4: Remind about local export config

Tell the user:

> To export your PDF to Google Drive or another folder, copy `config.local.mk.example`
> to `config.local.mk` (gitignored), fill in `EXPORT_DIR` and `EXPORT_NAME`, then run:
>
> ```bash
> make export FILE=resume-SLUG
> ```
> (Replace `resume-SLUG` with the actual filename, e.g. `resume-jane-doe`.)

## Step 5: Report

Confirm:
- File created: `resumes/resume-SLUG.tex`
- Build result: `(1 page)`
- No overfull warnings

Let the user know they can edit `resumes/resume-SLUG.tex` using only the macros in
`resume.cls` and run `make` to rebuild. The `resume` skill handles future content and
formatting edits. Remind them to commit the new file **inside `resumes/`** (their
private repo), not in the public engine repo.

## Notes

- **No Makefile changes needed.** The build globs `resumes/resume-*.tex` and picks up
  the new file automatically (the template is excluded from the glob).
- **Content stays private.** The new file lives in the gitignored `resumes/` clone, so
  it is never committed to the public engine repo.
- **Naming edge cases:** spaces in the slug become hyphens; uppercase becomes lowercase.
  "Alice M. Smith" -> `alice-m-smith` -> `resumes/resume-alice-m-smith.tex`.
- **Yearly archives:** once the user has content, they can copy to
  `resumes/resume-NAME-YEAR.tex` for a yearly snapshot.
