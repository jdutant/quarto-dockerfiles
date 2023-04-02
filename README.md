# Quarto dockerfiles

[![GitHub build status][CI badge]][CI workflow]

Multi-platform docker images and GitHub actions for
[Quarto](https://quarto.org).

[CI badge]: https://img.shields.io/github/actions/workflow/status/dialoa/quarto-dockerfiles/ci.yaml?branch=main
[CI workflow]: https://github.com/dialoa/quarto-dockerfiles/actions/workflows/ci.yaml

# Overview

Docker images built from `ubuntu`, supporting both `amd64` and
`arm64` (Apple Silicon), with instructions for use locally and in
GitHub Actions.

Quarto contains [Pandoc](https://pandoc.org) (run `quarto pandoc`),
Pandoc's Lua interpreter (`quarto run script.lua`), and Deno's
typescript interpreter (`quarto run script.ts`), so these images 
can run those too.

Images:

- `minimal`: Quarto alone. No Python, R, or LaTeX.
- `latex`: Quarto with small LaTeX (Tex Live) installation. Enough
    to render a simple document as PDF. Customize to add more packages.
- `tinytex` (`arm64` aka `x86_64` computers only): Quarto with 
    its recommended LaTeX installation (TinyTeX).

## Requirements

[Docker](https://docker.com). If using the Makefile, 
you'll need Xcode command line tools on MacOS and the
Windows Subsystem for Linux on Windows.

## Usage

### Using the Makefile

Run `make` or `make help` to see the Makefile instructions. 

Run `make build` to build default images (`minimal`, `latex`)
and `make test` to check that they work.

These are customizable, see Makefile instructions.

### with Docker

At the repository root, build images with:

```bash
docker build -t quarto-minimal -f Dockerfile.minimal .
```

Build other images by replacing `Dockerfile.minimal` as
appropriate. Choose another name for your 
image by replacing `quarto-minimal`.

Once your image is built, you can run Quarto in any folder
with: 

```bash
docker run -rm --volume $(pwd):/data quarto-minimal <quarto_command>
```

Substituting a Quarto command for `<quarto-command>`, e.g.
`render README.md -o out.html`. Replace `quarto-minimal` with
the name of your image if needed. `--rm` removes the container
after execution, `--volume $(pwd):/data` makes the present working directory accessible as `/data` within the container. 

For repeated use you may set an environment variable, e.g.:

```bash
QUARTO="docker run -rm --volume $(pwd):/data quarto-minimal"

$(QUARTO) render file1.qmd --output-dir results -t html
$(QUARTO) create
```

### Use in GitHub

See the [workflows folder](.github/workflows/) for 
examples of how to build and run the image as a GitHub 
action. 

### Explore the image contents

To explore an image, create a container with no entry point 
to run bash interactively:

```bash
docker run -rm -it --entrypoint='' quarto-minimal bash
```

`-rm` deletes the container after your session; `-it` opens
the container in interactive, i.e. terminal mode, and `bash` 
uses the container's bash shell. `myquarto` is the image's
name, change as needed.

You can create a lasting container and give it a name
to modify it (e.g. try installing LaTeX package).

```bash
docker run --name=dockto -it --entrypoint='' quarto-latex bash
```

Substitute `dockto` with your desired name for the container.
Once you've exited it, you can re-enter with:

```bash
docker start -ai dockto
```

Where `-ai` passes your command line input (`-i`) and returns 
the container's command-line output (`-a`).
