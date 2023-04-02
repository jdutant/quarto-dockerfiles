# Quarto dockerfiles

[![GitHub build status][CI badge]][CI workflow]

Multi-platform docker images and GitHub actions for
[Quarto](https://quarto.org).

[CI badge]: https://img.shields.io/github/actions/workflow/status/dialoa/quarto-dockerfiles/ci.yaml?branch=main
[CI workflow]: https://github.com/tarleb/lua-filter-template/dialoa/quarto-dockerfiles/ci.yaml

# Overview

Docker images built from `ubuntu`, supporting both `amd64` and
`arm64` (Apple Silicon), with instructions for use locally and in
GitHub Actions.

Quarto contains [Pandoc](https://pandoc.org) (run `quarto pandoc`),
Pandoc's Lua interpreter (`quarto run script.lua`), and Deno's
typescript interpreter (`quarto run script.ts`), so these images 
can run those too.

One image so far:

- `minimal`: Quarto alone. No Python, R, or LaTeX.

## Requirements

[Docker](https://docker.com). If using the Makefile, 
you'll need Xcode command line tools on MacOS and the
Windows Subsystem for Linux on Windows.

## Usage

### Build and test using the Makefile

Clone the repository. Build a docker image `make build`, 
and run the default test with `make test`. If you do 
not get an error message, the docker image has
correctly reproduced the expected output.

The default image is named `quarto-minimal`. Once built
you can run it following the instructions in the next
section (replacing `myquarto` with `quarto-minimal`).

### Build and run with docker only

Clone the repository. Build the image with

``` bash
docker build -t myquarto -f <image>.dockerfile .
```

Where `<image>` is the desired image, e.g. `minimal`,
and `myquarto` your chosen name for the image. 
If you use another name, or if you've built the image
with `make build` (which names the image `quarto-minimal`
by default), adapt the commands below accordingly.

Once your image is built, go to any folder where you 
want to run Quarto and execute:

```bash
docker run -rm --volume $(pwd):/data myquarto <quarto_command>
```

Substituting a Quarto command for `<quarto-command>`, e.g.
`render README.md -o out.html`. 

For repeated use set an environment variable, e.g.:

```bash
QUARTO="docker run -rm --volume $(pwd):/data myquarto"

$(QUARTO) render file1.qmd --output-dir results -t html
$(QUARTO) create
```

### Use in GitHub

See the [workflows folder](.github/workflows/) for 
examples of how to build and run the image as a GitHub 
action. 

### Explore the image

To explore the image, create a container with empty entrypoint:

```bash
docker run -rm -it --entrypoint='' myquarto bash
```

`-rm` deletes the container after your session; `-it` opens
the container in interactive, i.e. terminal mode, and `bash` 
uses the container's bash shell. `myquarto` is the image's
name, change as needed.

You can create a lasting container and give it a name
to modify it (e.g. try installing LaTeX package).

```bash
docker container create --entrypoint='' --name dockto myquarto
```

Substitute `dockto` with your desired name for the container.