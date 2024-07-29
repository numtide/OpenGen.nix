# OpenGen/nix

This repo holds Nix flake, modules, packages, and reusable utility Nix language code for use across the OpenGen ecosystem.

## Usage

### Build an artifact

Currently, you can build a package directly like so:

```bash
nix build github.com:OpenGen/nix#sppl
```

### Build an OCI image with an environment

OCI images consume these libraries and ones from other OpenGen repos, and are specified in another flake (excepting the `base` oci image):

```bash
nix build github.com:OpenGen/nix#ociImgLoom
```

### Import utility code

To access the `lib` code exported by this flake, declare this repo as a flake input:

```nix
{
  inputs = {
    nixpkgs.url = ...
    opengen.url = "github:OpenGen/nix";
  };
  outputs = inputs@{ nixpkgs, opengen, ... }: let
    # call some function
    toolbox = opengen.lib.basicTools "aarch64-darwin";
  in {
    ...
  };
};
```

## Packages

List of Nix packages available in this repo.

### `.#baseOCI`

### `.#loomOCI`

A Loom container image is also provided. It can be built and loaded into your local Docker registry with the following command:

```console
$ docker load -i $(nix build '.#loomOCI' --no-link --print-out-paths)
```

### `.#jupyter-bayes3d`

A jupyter environment with bayes libraries available.

Example:
```console
$ nix run .#jupyter-bayes3d notebook ./notebooks/demo.ipynb
```

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
$ nix build '.#packages.x86_64-linux.loom'                      # same as `.#loom` if that is your OS/arch
$ nix build './envs-flake#packages.x86_64-darwin.ociImgLoom'
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
