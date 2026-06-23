# Resume build. Requires xelatex (MacTeX/BasicTeX) and the system Charter font.
ENGINE  := xelatex
SRCDIR  := resumes
AUXDIR  := .build-aux

# Glob all resume source files
SOURCES := $(wildcard $(SRCDIR)/resume-*.tex)
PDFS    := $(patsubst %.tex,%.pdf,$(SOURCES))
FILES   := $(notdir $(basename $(SOURCES)))

# Per-user export config (gitignored). Copy config.local.mk.example to
# config.local.mk and set EXPORT_DIR and EXPORT_NAME for your machine.
-include config.local.mk

.PHONY: all clean export help check

all: $(PDFS)

help:
	@echo 'Targets:'
	@echo '  make                              build resumes/resume-*.tex -> resumes/'
	@echo '  make resumes/resume-NAME.pdf      build one specific file'
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
	@$(MAKE) $(SRCDIR)/$(FILE).pdf
	@mkdir -p "$(EXPORT_DIR)"
	cp "$(SRCDIR)/$(FILE).pdf" "$(EXPORT_DIR)/$(EXPORT_NAME)"
	@echo "Exported -> $(EXPORT_DIR)/$(EXPORT_NAME)"

# Build to .build-aux/ (aux junk stays there), then copy the PDF next to the source.
# Runs xelatex from the repo root so \documentclass{resume} resolves resume.cls.
$(SRCDIR)/%.pdf: $(SRCDIR)/%.tex resume.cls | $(AUXDIR)
	@$(ENGINE) -interaction=nonstopmode -halt-on-error -output-directory=$(AUXDIR) $< > $(AUXDIR)/$*.log 2>&1 \
		|| (echo "BUILD FAILED: see $(AUXDIR)/$*.log" && tail -n 20 $(AUXDIR)/$*.log && exit 1)
	@cp $(AUXDIR)/$*.pdf $@
	@echo "Built $@: $$(grep -oE '\([0-9]+ pages?\)' $(AUXDIR)/$*.log | tail -1)"

$(AUXDIR):
	mkdir -p $@

check:
	@scripts/check-no-content.sh

clean:
	rm -rf $(AUXDIR)
	find $(SRCDIR) -name '*.pdf' -delete 2>/dev/null; true
