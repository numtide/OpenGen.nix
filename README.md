# OpenGen.nix

This repo holds Nix flake, modules, packages, and reusable utility Nix language code for use across the OpenGen ecosystem. Either directly, or indirectly.

## Features

### Packages

The repository comes packed with packages used day-to-day by developers.
* sppl
* loom
* bayes3d
* ...

Those can be executed directly, without complicated installation steps:

```bash
nix run github.com:numtide/OpenGen.nix#loom
```

### Load OCI/Docker images

Docker images are useful to create developer environment for users not running
on Linux.

On Linux, build and load them with:
```console
$ nix build github.com:numtide/OpenGen.nix#oci-gensql-loom
$ docker load -i ./result
```

The resulting image can then be published to a Docker registry.

### Import utility code

Use the libraries in your own project. For example here we create a small
developer shell with python, Bayes3D and GenJax.

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
          p.bayes3d
          p.genjax
        ]);
      ];
    };
  };
};
```

### Other advantages

* CUDA support on Linux.
* Shareable build results (with binary cache).

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

## Packages

### `.#jupyter-bayes3d`

A Jupyter environment with Bayes3D libraries available.

Example:
```console
$ nix run .#jupyter-bayes3d notebook ./notebooks/demo.ipynb
```

## OCI Images

This project also generates Docker / OCI images for common scenarios. This is
useful for users that don't have access to a Linux or Nix machine.

Those images can be loaded into your local Docker registry with the following
command:

Example:
```console
$ docker load -i $(nix build '.#oci-gensql-loom' --no-link --print-out-paths)
```

### `.#oci-base`

A barebone image with common tools in it.

### `.#oci-gensql-loom`

Docker image including the loom utility.

### `.#oci-gensql-query`

Docker image for gensql.query

## Python Packages

Here are all the python packages this flake provides, on top of all the ones
available in nixpkgs.

All the packages are compiled against Python 3.11.

### `.#bayes3d`

Bayes3D is a 3D scene perception system based on probabilistic inverse graphics.

* [GitHub](https://github.com/probcomp/bayes3d)

### `.#loom`

Implementation of [CrossCat in Python](https://github.com/posterior/loom). NOTE: this ONLY builds for `x86_64` architectures and only runs on linux, because it depends on
platform-dependent `distributions`.

Your options are:

```console
$ nix build '.#packages.x86_64-linux.loom'        # same as `.#loom` if that is your OS/arch
$ nix build '.#packages.x86_64-darwin.oci-gensql-loom'
```

If you are running on Mac silicon (`aarch64-darwin`), that OCI image will run but behavior is not defined or supported.

### `.#distinctipy`

distinctipy is a lightweight python package providing functions to generate colours that are visually distinct from one another.

* [GitHub](https://github.com/alan-turing-institute/distinctipy)
* [PyPi](https://pypi.org/project/distinctipy)

### `.#distributions`

Native library for probability distributions in python used by Loom. NOTE: this ONLY builds for `x86_64` architectures and only runs on linux.

* [GitHub](https://github.com/posterior/distributions)

### `.#dm-tree`

Tree is a library for working with nested data structures. In a way, tree generalizes the builtin map function which only supports flat sequences, and allows to apply a function to each "leaf" preserving the overall structure.

* [GitHub](https://github.com/deepmind/tree)
* [PyPi](https://pypi.org/project/dm-tree)

### `.#genjax`

GenJAX is an implementation of Gen on top of JAX - exposing the ability to programmatically construct and manipulate generative functions, as well as JIT compile + auto-batch inference computations using generative functions onto GPU devices.

* [GitHub](https://github.com/probcomp/genjax)

### `.#goftests`

Goftests is intended for unit testing random samplers that generate arbitrary plain-old-data, and focuses on robustness rather than statistical efficiency. In contrast to scipy.stats and statsmodels, goftests does not make assumptions on the distribution being tested, and requires only a simple (sample, prob) interface provided by MCMC samplers.

* [GitHub](https://github.com/posterior/goftests)

### `.#open3d`

Open3D is an open-source library that supports rapid development of software that deals with 3D data.

* [GitHub](https://github.com/isl-org/Open3D)
* [PyPi](https://pypi.org/project/open3d)

### `.#opencv-python`

Wrapper package for OpenCV python bindings.

* [GitHub](https://github.com/opencv/opencv-python)
* [PyPi](https://pypi.org/project/opencv-python)

### `.#oryx`

Oryx is a library for probabilistic programming and deep learning built on top of Jax.

* [GitHub](https://github.com/jax-ml/oryx)
* [PyPi](https://pypi.org/project/oryx)

### `.#parsable`

Parsable is a lightweight decorator-based command line parser library. Parsable was written to be simpler than argparse, optparse, and argh.

### `.#plum-dispatch`

Multiple dispatch in Python.

* [GitHub](https://github.com/beartype/plum)
* [PyPi](https://pypi.org/project/plum-dispatch)

### `.#pymetis`

PyMetis is a Python wrapper for the Metis graph partititioning software.

* [GitHub](https://github.com/inducer/pymetis)
* [PyPi](https://pypi.org/project/PyMetis)

### `.#pyransac3d`

pyRANSAC-3D is an open source implementation of Random sample consensus (RANSAC) method. It fits primitive shapes such as planes, cuboids and cylinder in a point cloud to many aplications: 3D slam, 3D reconstruction, object tracking and many others.

* [GitHub](https://github.com/leomariga/pyRANSAC-3D)
* [PyPi](https://pypi.org/project/pyransac3d)

### `.#sppl`

Probabilistic programming system for fast and exact symbolic inference.

* [GitHub](https://github.com/probsys/sppl)
* [PyPi](https://pypi.org/project/sppl)

### `.#tensorflow-probability`

TensorFlow Probability is a library for probabilistic reasoning and statistical analysis in TensorFlow.

* [GitHub](https://github.com/tensorflow/probability)
* [PyPi](https://pypi.org/project/tensorflow-probability)
