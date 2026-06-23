#!/bin/sh
# check-no-content.sh: guardrail for the PUBLIC resume-manager repo.
#
# Asserts that no private resume content is tracked by this repo. Real resume
# content lives in the gitignored resumes/ directory (a clone of your PRIVATE
# content repo) and must never be committed here.
#
# Exits non-zero (and names the offenders) if a violation is found, so it is
# safe to wire as a pre-commit hook or a CI step. Dependency-free: POSIX sh + git.
#
# Usage:
#   scripts/check-no-content.sh        # or: make check
#
# Install as a pre-commit hook:
#   ln -s ../../scripts/check-no-content.sh .git/hooks/pre-commit

set -eu

status=0

# 1. No tracked files anywhere under resumes/ (the private clone).
tracked_resumes=$(git ls-files -- 'resumes/' || true)
if [ -n "$tracked_resumes" ]; then
	echo "ERROR: private content under resumes/ is tracked by this public repo:"
	echo "$tracked_resumes" | sed 's/^/  - /'
	echo "  -> resumes/ must stay gitignored. Run: git rm -r --cached resumes/"
	status=1
fi

# 2. The only tracked .tex at the repo root may be resume-template.tex.
#    Real content files (resume-NAME.tex) belong in the private repo, not here.
root_tex=$(git ls-files -- '*.tex' | grep -v '/' | grep -v '^resume-template\.tex$' || true)
if [ -n "$root_tex" ]; then
	echo "ERROR: unexpected resume .tex file(s) tracked at the repo root:"
	echo "$root_tex" | sed 's/^/  - /'
	echo "  -> only resume-template.tex (clean placeholder data) belongs in this public repo."
	echo "  -> move real content into your private repo cloned at resumes/."
	status=1
fi

if [ "$status" -eq 0 ]; then
	echo "OK: no private resume content is tracked by this repo."
fi

exit "$status"
