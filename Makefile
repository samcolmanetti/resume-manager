# Resume build. Requires xelatex (MacTeX/BasicTeX) and the system Charter font.
ENGINE  := xelatex
OUTDIR  := build

# Real resume content lives in the gitignored resumes/ directory (a clone of your
# PRIVATE content repo). The build globs resumes/resume-*.tex. When no private
# content is present (e.g. a fresh public clone), it falls back to the clean
# resume-template.tex at the repo root so the engine still builds and validates.
CONTENT := $(filter-out resumes/resume-template.tex,$(wildcard resumes/resume-*.tex))
ifeq ($(strip $(CONTENT)),)
SOURCES := resume-template.tex
else
SOURCES := $(CONTENT)
endif

# Flatten output paths: resumes/resume-NAME.tex -> build/resume-NAME.pdf
PDFS  := $(patsubst %.tex,$(OUTDIR)/%.pdf,$(notdir $(SOURCES)))
FILES := $(notdir $(basename $(SOURCES)))

# Let the pattern rule below find sources in resumes/ as well as the repo root.
# resume.cls stays at the repo root and resolves via the build's working dir.
vpath %.tex resumes

# Per-user export config (gitignored). Copy config.local.mk.example to
# config.local.mk and fill in EXPORT_DIR and EXPORT_NAME for your machine.
-include config.local.mk

.PHONY: all clean export help check

all: $(PDFS)

help:
	@echo 'Targets:'
	@echo '  make                              build resumes/resume-*.tex -> build/ (template if none)'
	@echo '  make build/resume-NAME.pdf        build one specific file'
	@echo '  make export FILE=resume-NAME      export PDF to EXPORT_DIR (requires config.local.mk)'
	@echo '  make check                        verify no private content is tracked by this repo'
	@echo '  make clean                        remove build artifacts'
	@echo ''
	@echo 'Available files: $(FILES)'

# Build then copy a specific PDF to EXPORT_DIR.
# Usage: make export FILE=resume-NAME
# EXPORT_DIR and EXPORT_NAME must be set in config.local.mk.
export:
ifndef FILE
	$(error FILE is required. Usage: make export FILE=resume-NAME. Available: $(FILES))
endif
ifndef EXPORT_DIR
	$(error EXPORT_DIR is not set. Copy config.local.mk.example to config.local.mk and fill it in.)
endif
ifndef EXPORT_NAME
	$(error EXPORT_NAME is not set. Copy config.local.mk.example to config.local.mk and fill it in.)
endif
	@$(MAKE) $(OUTDIR)/$(FILE).pdf
	@mkdir -p "$(EXPORT_DIR)"
	cp "$(OUTDIR)/$(FILE).pdf" "$(EXPORT_DIR)/$(EXPORT_NAME)"
	@echo "Exported -> $(EXPORT_DIR)/$(EXPORT_NAME)"

# Run xelatex from the repo root (Make's working dir) so \documentclass{resume}
# resolves resume.cls from here, even when the source lives in resumes/.
$(OUTDIR)/%.pdf: %.tex resume.cls | $(OUTDIR)
	$(ENGINE) -interaction=nonstopmode -halt-on-error -output-directory=$(OUTDIR) $< > $(OUTDIR)/$*.build.log 2>&1 \
		|| (echo "BUILD FAILED: see $(OUTDIR)/$*.build.log" && tail -n 20 $(OUTDIR)/$*.build.log && exit 1)
	@echo "Built $@: $$(grep -oE '\([0-9]+ pages?\)' $(OUTDIR)/$*.build.log | tail -1)"

$(OUTDIR):
	mkdir -p $(OUTDIR)

check:
	@scripts/check-no-content.sh

clean:
	rm -f $(OUTDIR)/*.aux $(OUTDIR)/*.log $(OUTDIR)/*.out $(OUTDIR)/*.pdf $(OUTDIR)/*.build.log $(OUTDIR)/inspect.png
