# image to be build
IMAGE ?= minimal
NAME ?= quarto-minimal
# binaries
DIFF ?= diff
QUARTO ?= docker run --rm --volume $$(pwd):/data $(NAME)
# test source, formats, expected outputs dir
SOURCE ?= README.md
FORMATS ?= native
EXP_DIR ?= _test

# create list of expected files
EXPECTED_FILES = $(FORMATS:%=$(EXP_DIR)/expected.%)

# default target
all: help

.PHONY: build
## build: Build $(IMAGE).dockerfile as quarto-$(IMAGE)
build: $(IMAGE).dockerfile
	docker build -f $(IMAGE).dockerfile -t $(NAME) .

.PHONY: test
## test: Check whether Quarto's output is as expected
test: $(SOURCE) $(EXPECTED_FILES)
	@for fmt in $(FORMATS) ; do \
		$(QUARTO) render $(SOURCE) -t $$fmt -o - | \
		$(DIFF) $(EXP_DIR)/expected.$$fmt - ; \
	done


.PHONY: generate
## generate: Regenerate expected output
generate: $(SOURCE)
	@for fmt in $(FORMATS) ; do \
		$(QUARTO) render $(SOURCE) -t $$fmt \
			--output-dir $(EXP_DIR) -o expected.$$fmt ; \
	done

# H/T https://www.owenrumney.co.uk/help-in-make-file/
.PHONY: help
help:
## help: This helpful list of commands
	@echo "usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':'
	@echo