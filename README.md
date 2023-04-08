# Quarto dockerfiles

[![GitHub build status][CI badge]][CI workflow]

Multi-platform docker images and GitHub actions for
[Quarto](https://quarto.org).

[CI badge]: https://img.shields.io/github/actions/workflow/status/jdutant/quarto-dockerfiles/ci.yaml?branch=main
[CI workflow]: https://github.com/jdutant/quarto-dockerfiles/actions/workflows/ci.yaml

## Overview

Docker images built from `ubuntu`, supporting both `amd64` and
`arm64` (Apple Silicon), with instructions for use locally and in
GitHub Actions.

Quarto contains [Pandoc](https://pandoc.org) (run `quarto pandoc`),
Pandoc's Lua interpreter (`quarto run script.lua`), and Deno's
typescript interpreter (`quarto run script.ts`), so these images 
can run those too.

Images:

- `minimal`: Quarto alone. No Python, R, or LaTeX. ~400Mb
- `latex`: Quarto with small LaTeX (Tex Live) installation. Enough
    to render a simple document as PDF, and Quarto automatically
    downloads any extra packages needed. Customize to add more packages permanently. ~800Mb
- `tinytex` (`amd64` aka `x86_64` computers only): Quarto with 
    its recommended LaTeX installation (TinyTeX). ~800Mb

The `latex` image doesn't use TinyTeX because Quarto can't
install it on arm64 machines.

Requires [Docker](https://docker.com).

## Pull or build the images

### Pull from Docker hub

``` bash
docker pull jdutant/quarto-minimal
docker pull jdutant/quarto-latex
```

You can rename it for convenience:

```bash
docker tag jdutant/quarto-minimal myname
```

Substitute `quarto-minimal` for `myname` to run the example
commands below.

### Build with make

Clone this repository.

Run `make` or `make help` to see the Makefile instructions. 

Run `make build` to build default images (`minimal`, `latex`)
and `make test` to check that they work.

These are customizable, see Makefile instructions.

### Build with Docker

Clone this repository. At the root, build images with:

```bash
docker build -t quarto-minimal -f Dockerfile.minimal .
```

Build other images by replacing `Dockerfile.minimal` as
appropriate. Choose another name for your 
image by replacing `quarto-minimal`.

## Basic usage

### Run Quarto

Once your image is built or pulled, you can run Quarto in any folder
with: 

```bash
docker run --rm --volume $(pwd):/data quarto-minimal <quarto_command>
```

Substituting a Quarto command for `<quarto-command>`, e.g.
`render README.md -o out.html`. Replace `quarto-minimal` with
the name of your image if needed (e.g. `jdutant/quarto-minimal` if
you have pulled it but not renamed it). `--rm` removes the container
after execution, `--volume $(pwd):/data` makes the present working directory accessible as `/data` within the container. 

For repeated use you may set an environment variable, e.g.:

```bash
QUARTO="docker run --rm --volume $(pwd):/data quarto-minimal"

$(QUARTO) render file1.qmd --output-dir results -t html
$(QUARTO) create
```

### Run Pandoc, Lua, Typescript

Run Pandoc instead with:

```
docker run --rm --volume $(pwd):/data quarto-minimal pandoc <pandoc command>

$(QUARTO) pandoc source.md -o out.html
```

Or use the Quarto command `run` to run a script, as describe in 
[Quarto's documentation](https://quarto.org/docs/projects/scripts.html).

### in a GitHub action

See the [workflows folder](.github/workflows/) for 
examples of how to build and run the image as a GitHub 
action. 

## Advanced usage

### Set a specific Quarto release

Using `docker build` chose your Quarto version with:

```bash
docker build -t quarto-minimal -f Dockerfile.minimal --build-arg QUARTO_VERSION=1.3.313 .
```

Note that only recent versions of Quarto have a `linux/arm64` version 
needed to run the image on an arm64 machine.

Use the script `tools/latest.sh` to find out version numbers
for Quarto's official "latest" release and edge (actual
latest) release: 

```bash
sh tools/latest.sh edge
sh tools/latest.sh latest
sh tools/latest         (defaults to 'edge')
```

Or check out [Quarto's releases page](https://github.com/quarto-dev/quarto-cli/releases/tag/v1.2.475).

By the way the images run Ubuntu rather than Alpine because
Quarto relies on `glibc`. You can set which the Ubuntu image
tag with `--build-arg UBUNTU_VERSION`, (default `latest`).

### Explore an image

This is useful to explore where things are set and
try installing additional packages. 

Create a container with no entry point 
to run bash interactively:

```bash
docker run --rm -it --entrypoint='' quarto-minimal bash
```

`--rm` deletes the container after your session; `-it` opens
the container in interactiv (terminal) mode, and `bash` 
uses the container's bash terminal. `quarto-minimal` is the 
image's name (e.g. `jdutant/quarto-minimal` if you have
pulled it but nor renamed it). Type `exit` to exit the
container's terminal.

You can create a lasting container, give it a name, and
enter it to modify it, e.g. install a LaTeX package:

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

Any modifications to the container will be preserved by Docker
until it is deleted (with `docker rm dockto`).

If you want to both use the container as Quarto app and 
persist its installation, you should mount a working folder 
when you create it:

```bash
$ docker run --name=dockto --volume $(pwd):/data -it --entrypoint='' quarto-latex bash
root@d96174e63ea:/data# exit
$ docker -ai start dockto
root@d96174e63ea:/data# quarto render
...
root@d96174e63ea:/data# exit
$ open <rendered file>
```

### Persist a LaTeX installation

The `latex` image contains a basic TeX Live installation
with just enough packages for Quarto to convert a simple
document to PDF. What if more are needed?

* Quarto downloads and install them automatically in
  the *container* that runs the image. The downloaded
  packages are available as long as the container
  is alive. (Don't use the autoremove `--rm` option
  if you want this!)
* You can customize the Dockerfile.latex image to
  download extra packages. Uncomment the 
  "More LaTeX packages" section and add yours.

A third solution would be to use a 
[Docker volume](https://docs.docker.com/storage/volumes/)
to persist the folders where Tex Live packages
are installed. I think only a couple of folders
need to be preserved. If you're doing this, please
post a how-to here (as PR or issue)!

