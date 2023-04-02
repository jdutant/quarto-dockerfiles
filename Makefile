# images to be build to $PREFIX-<image>
#	we don't build tinytex to avoid arm64 fail
IMAGE ?= minimal latex
IMAGE_PREFIX ?= quarto
#	use this line instead to build all by default
# IMAGE ?= $(patsubst Dockerfile.%,%,$(wildcard Dockerfile.*))

# binaries
DIFF ?= diff
QUARTO ?= docker run --rm --volume $$(pwd):/data $(IMAGE_PREFIX)-minimal
QUARTO_LATEX ?= docker run --rm --volume $$(pwd):/data $(IMAGE_PREFIX)-latex

# test configuration
# source file, output formats, expected outputs dir
SOURCE ?= README.md
FORMAT ?= native
EXP_DIR ?= _test

# create list of expected files
EXPECTED_FILES = $(FORMAT:%=$(EXP_DIR)/expected.%)
IMAGE_FILES = $(IMAGE:%=Dockerfile.%)

# default target
all: help

.PHONY: build
## build: Build Dockerfile.$(IMAGE) as $(IMAGE_PREFIX)-$(IMAGE)
## :     make build IMAGE="minimal latex" IMAGE_PREFIX="myquarto"
## : Image prefix defaults to `quarto`


build: $(IMAGE_FILES)
	@for image in $(IMAGE) ; do \
		docker build 	-f Dockerfile.$$image \
						-t $(IMAGE_PREFIX)-$$image . ; \
	done

.PHONY: test
## test: run all tests (expected and latex)
test: match latex

## match: Check whether Quarto's $(FORMAT) output is as expected.
## :     make match FORMAT="html native latex"
match: $(SOURCE) $(EXPECTED_FILES)
	@for fmt in $(FORMAT) ; do \
		$(QUARTO) render $(SOURCE) -t $$fmt -o - | \
		$(DIFF) $(EXP_DIR)/expected.$$fmt - ; \
	done

.PHONY: latex
## latex: Check that Dockerfile.latex can generate a simple PDF
## :     make latex
latex: $(SOURCE)
	$(QUARTO_LATEX) render -t pdf

.PHONY: generate
## generate: Regenerate expected output in $(FORMAT)
## :     make generate FORMAT="html native latex"
generate: $(SOURCE)
	@for fmt in $(FORMAT) ; do \
		$(QUARTO) render $(SOURCE) -t $$fmt \
			--output-dir $(EXP_DIR) -o expected.$$fmt ; \
	done

# H/T https://www.owenrumney.co.uk/help-in-make-file/
.PHONY: help
help:
## help: This helpful list of commands
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':'
	@echo