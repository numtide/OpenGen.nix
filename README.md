# OpenGen.nix

This repo holds Nix flake, modules, packages, and reusable utility Nix
language code for use across the OpenGen ecosystem. Either directly, or
indirectly.

## Features

* Packages: comes packed with python packages used day-to-day by the team at OpenGen.
* Executables: can execute loom and other packages without complicated installation instructions.
* Docker/OCI image: builds and publishes common images to use in the cloud or for demos.
* Developer shell: run `nix develop` and start coding.
* Shared cache: don't spend hours rebuilding the same packages.
* CUDA support.

Build and tested on Linux.

## Setup

1. [Install Nix](https://nixos.org/nix)

2. Because genjax is closed source, Nix needs to be configured to access the
   repository.

To do so, run:
```console
$ gh auth login
$ mkdir -p ~/.config/nix
$ echo "access-tokens = github.com=$(gh auth token)" >> ~/.config/nix/nix.conf
```

## Usage

### Developer shell

To start coding, run:

```console
$ nix develop
```

This creates a shell environment that includes Bayes3d, Jax, SciPy and Jupyter:

```console
$ jupyter notebook notebooks/demo.ipynb
```

#### Adding dependencies

On top of the packages from this repository, you also have access to the ~8k
[packages from nixpkgs](https://search.nixos.org/packages?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=python311Packages)
.

To add a dependency, edit the `parts/devshell.nix` file and add the package to
the "Add your dependencies here" part.

Then exit and re-launch the shell with `nix develop`.

If the package doesn't exist in nixpkgs, it's always possible to `pip install`
it as well. In which case it will be installed in the repo's `.venv`.

### Executables

Some of the packages are also directly executable, allowing to use then
without installing anything.

```console
$ nix run github:numtide/OpenGen.nix#loom
Usage: loom COMMAND [ARG ARG ... KEY=VAL KEY=VAL ...]
```

Or inside of the checked out repo:
```console
$ nix run .#loom
Usage: loom COMMAND [ARG ARG ... KEY=VAL KEY=VAL ...]
```

### OCI/Docker images

This project also proposes Docker / OCI images for common scenarios. This is
useful to distribute the code to users for demos, or to the Cloud.

On Linux, build and load them with:
```console
$ nix build github.com:numtide/OpenGen.nix#oci-gensql-loom
$ docker load -i ./result
```

The resulting image can then be published to a Docker registry.

### Import utility code

The code in this project can also be re-used in other repositories. The
use-case is to develop experiments independently from the main repository.

For this you would add a bare bone `flake.nix` in your repository:
```nix
{
  inputs = {
    opengen.url = "github:numtide/OpenGen.nix";
    nixpkgs.follows = "opengen/nixpkgs";
  };
  outputs = { self, nixpkgs, opengen }: let
    eachSys = nixpkgs.lib.genAttrs ["x86_64-linux"];
  in {
  devShells = eachSys (system: {
    default = nixpkgs.legacyPackages.${system}.mkShell {
      packages = [
        opengen.packages.${system}.python.withPackages (p: [
          # Add your packages here
          p.bayes3d
          p.genjax
        ]);
      ];
    };
  };
};
```

Then invoke `nix develop` to create your own developer environment.

## Packages

### `jupyter-bayes3d`

A Jupyter environment with Bayes3D libraries available.

Example:
```console
$ nix run github:numtide/OpenGen.nix#jupyter-bayes3d notebook ./notebooks/demo.ipynb
```

## OCI Images

The `./oci` folder defines all the images for the project.

### `oci-base`

A barebone image with common tools in it.

### `oci-gensql-loom`

Docker image including the loom utility.

### `oci-gensql-query`

Docker image for gensql.query

## Python Packages

Here are all the python packages this flake provides, on top of all the ones
available in nixpkgs.

All the packages are compiled against Python 3.11.

### `bayes3d`

Bayes3D is a 3D scene perception system based on probabilistic inverse graphics.

* [GitHub](https://github.com/probcomp/bayes3d)

### `loom`

Implementation of [CrossCat in Python](https://github.com/posterior/loom). NOTE: this ONLY builds for `x86_64` architectures and only runs on linux, because it depends on
platform-dependent `distributions`.

Your options are:

```console
$ nix build '.#packages.x86_64-linux.loom'        # same as `.#loom` if that is your OS/arch
$ nix build '.#packages.x86_64-darwin.oci-gensql-loom'
```

If you are running on Mac silicon (`aarch64-darwin`), that OCI image will run but behavior is not defined or supported.

### `distinctipy`

distinctipy is a lightweight python package providing functions to generate colours that are visually distinct from one another.

* [GitHub](https://github.com/alan-turing-institute/distinctipy)
* [PyPi](https://pypi.org/project/distinctipy)

### `distributions`

Native library for probability distributions in python used by Loom. NOTE: this ONLY builds for `x86_64` architectures and only runs on linux.

* [GitHub](https://github.com/posterior/distributions)

### `dm-tree`

Tree is a library for working with nested data structures. In a way, tree generalizes the builtin map function which only supports flat sequences, and allows to apply a function to each "leaf" preserving the overall structure.

* [GitHub](https://github.com/deepmind/tree)
* [PyPi](https://pypi.org/project/dm-tree)

### `genjax`

GenJAX is an implementation of Gen on top of JAX - exposing the ability to programmatically construct and manipulate generative functions, as well as JIT compile + auto-batch inference computations using generative functions onto GPU devices.

* [GitHub](https://github.com/probcomp/genjax)

### `goftests`

Goftests is intended for unit testing random samplers that generate arbitrary plain-old-data, and focuses on robustness rather than statistical efficiency. In contrast to scipy.stats and statsmodels, goftests does not make assumptions on the distribution being tested, and requires only a simple (sample, prob) interface provided by MCMC samplers.

* [GitHub](https://github.com/posterior/goftests)

### `open3d`

Open3D is an open-source library that supports rapid development of software that deals with 3D data.

* [GitHub](https://github.com/isl-org/Open3D)
* [PyPi](https://pypi.org/project/open3d)

### `opencv-python`

Wrapper package for OpenCV python bindings.

* [GitHub](https://github.com/opencv/opencv-python)
* [PyPi](https://pypi.org/project/opencv-python)

### `oryx`

Oryx is a library for probabilistic programming and deep learning built on top of Jax.

* [GitHub](https://github.com/jax-ml/oryx)
* [PyPi](https://pypi.org/project/oryx)

### `parsable`

Parsable is a lightweight decorator-based command line parser library. Parsable was written to be simpler than argparse, optparse, and argh.

### `plum-dispatch`

Multiple dispatch in Python.

* [GitHub](https://github.com/beartype/plum)
* [PyPi](https://pypi.org/project/plum-dispatch)

### `pymetis`

PyMetis is a Python wrapper for the Metis graph partititioning software.

* [GitHub](https://github.com/inducer/pymetis)
* [PyPi](https://pypi.org/project/PyMetis)

### `pyransac3d`

pyRANSAC-3D is an open source implementation of Random sample consensus (RANSAC) method. It fits primitive shapes such as planes, cuboids and cylinder in a point cloud to many aplications: 3D slam, 3D reconstruction, object tracking and many others.

* [GitHub](https://github.com/leomariga/pyRANSAC-3D)
* [PyPi](https://pypi.org/project/pyransac3d)

### `sppl`

Probabilistic programming system for fast and exact symbolic inference.

* [GitHub](https://github.com/probsys/sppl)
* [PyPi](https://pypi.org/project/sppl)

### `tensorflow-probability`

TensorFlow Probability is a library for probabilistic reasoning and statistical analysis in TensorFlow.

* [GitHub](https://github.com/tensorflow/probability)
* [PyPi](https://pypi.org/project/tensorflow-probability)

## Future

* Docker image for Bayes3D.
* Publish GCP images as well.
* Reduce Bayes3D closure size (20GB on my machine).
* Poetry2nix and jupyenv integrations.
* macOS and aarch64-linux compatibility.

