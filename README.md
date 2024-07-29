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

#### `.#loomOCI`

A Loom container image is also provided. It can be built and loaded into your local Docker registry with the following command:

```console
$ docker load -i $(nix build '.#loomOCI' --no-link --print-out-paths)
```

## Python Packages

Here are all the python packages this flake provides, on top of all the ones
available in nixpkgs.

All the packages are compiled against Python 3.11.

### `.#bayes3d`

<https://github.com/probcomp/bayes3d>.

### `.#distinctipy`

### `.#distributions`

Native library for probability distributions in python used by Loom. NOTE: this ONLY builds for `x86_64` architectures and only runs on linux.

### `.#dm-tree`

### `.#genjax`

### `.#goftests`

### `.#loom`

Implementation of [CrossCat in Python](https://github.com/posterior/loom). NOTE: this ONLY builds for `x86_64` architectures and only runs on linux, because it depends on
platform-dependent `distributions`.

Your options are:

```console
$ nix build '.#packages.x86_64-linux.loom'                      # same as `.#loom` if that is your OS/arch
$ nix build './envs-flake#packages.x86_64-darwin.ociImgLoom'
```

If you are running on Mac silicon (`aarch64-darwin`), that OCI image will run but behavior is not defined or supported.

### `.#open3d`

### `.#opencv-python`

### `.#orxy`

### `.#parsable`

### `.#plum-dispatch`

### `.#pymetis`

### `.#pyransac3d`

### `.#sppl`

Python [library by ProbSys](https://github.com/probsys/sppl) packaged for python3.9 .

### `.#tensorflow-probability`

### `.#loom`

