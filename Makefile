# Resume build. Requires xelatex (MacTeX/BasicTeX) and the system Charter font.
ENGINE  := xelatex
OUTDIR  := build
AUXDIR  := .build-aux

# Glob all resume source files in resumes/
SOURCES := $(wildcard resumes/resume-*.tex)
PDFS    := $(patsubst %.tex,$(OUTDIR)/%.pdf,$(notdir $(SOURCES)))
FILES   := $(notdir $(basename $(SOURCES)))

# Find sources in resumes/ so pattern rules can match by basename.
# resume.cls stays at the repo root and resolves via the build's working dir.
vpath %.tex resumes

# Per-user export config (gitignored). Copy config.local.mk.example to
# config.local.mk and set EXPORT_DIR and EXPORT_NAME for your machine.
-include config.local.mk

.PHONY: all clean export help check

all: $(PDFS)

help:
	@echo 'Targets:'
	@echo '  make                              build resumes/resume-*.tex -> build/'
	@echo '  make build/resume-NAME.pdf        build one specific file'
	@echo '  make export FILE=resume-NAME      export PDF to EXPORT_DIR (requires config.local.mk)'
	@echo '  make check                        verify no resume content is tracked by this repo'
	@echo '  make clean                        remove build artifacts'
	@echo ''
	@echo 'Available files: $(FILES)'

# Build then copy a specific PDF to EXPORT_DIR.
# Usage: make export FILE=resume-NAME
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

# Build to .build-aux/ (aux junk stays there), then copy the PDF to build/.
# Runs xelatex from the repo root so \documentclass{resume} resolves resume.cls.
$(OUTDIR)/%.pdf: %.tex resume.cls | $(OUTDIR) $(AUXDIR)
	$(ENGINE) -interaction=nonstopmode -halt-on-error -output-directory=$(AUXDIR) $< > $(AUXDIR)/$*.log 2>&1 \
		|| (echo "BUILD FAILED: see $(AUXDIR)/$*.log" && tail -n 20 $(AUXDIR)/$*.log && exit 1)
	cp $(AUXDIR)/$*.pdf $@
	@echo "Built $@: $$(grep -oE '\([0-9]+ pages?\)' $(AUXDIR)/$*.log | tail -1)"

$(OUTDIR) $(AUXDIR):
	mkdir -p $@

check:
	@scripts/check-no-content.sh

clean:
	rm -rf $(OUTDIR) $(AUXDIR)
