{ stdenv
, lib
, pkgs
, fetchPypi
, unzip
, zip

, autoPatchelfHook
, python
, tensorflow-bin
, libusb
, cudaPackages_11
, buildPythonPackage
, ipywidgets
, matplotlib
, numpy
, pandas
, plyfile
, torch
, pytorchWithCuda
, pyyaml
, scikitlearn
, scipy
, tqdm
, plotly
, dash
, addict

, libGL
, libglvnd
, libdrm
, expat
, xorg
, llvmPackages_10
, buildEnv
, runCommand
}:
let
  libllvm-wrapped =
    let
      libllvm = llvmPackages_10.libllvm.lib;
      name = libllvm.name;
    in
    buildEnv {
      inherit name;
      paths = [
        llvmPackages_10.libllvm.lib
        (runCommand "${name}.1" { }
          "mkdir -p $out/lib && ln -sf ${libllvm}/lib/libLLVM-10.so $out/lib/libLLVM-10.so.1"
        )
      ];
    };

  version = "0.18.0";
  pname = "open3d";

  prebuiltSrcs = {
    "3.8-x86_64-linux" = {
      platform = "manylinux_2_27_x86_64";
      dist = "cp38";
      hash = "";
    };
    "3.8-aarch64-linux" = {
      platform = "manylinux_2_27_aarch64";
      dist = "cp38";
      hash = "";
    };
    "3.8-x86_64-darwin" = {
      platform = "macosx_11_0_x86_64";
      dist = "cp38";
      hash = "";
    };
    "3.8-aarch64-darwin" = {
      platform = "macosx_13_0_aarch64";
      dist = "cp38";
      hash = "";
    };

    "3.9-x86_64-linux" = {
      platform = "manylinux_2_27_x86_64";
      dist = "cp39";
      hash = "";
    };
    "3.9-aarch64-linux" = {
      platform = "manylinux_2_27_aarch64";
      dist = "cp39";
      hash = "";
    };
    "3.9-x86_64-darwin" = {
      platform = "macosx_11_0_x86_64";
      dist = "cp39";
      hash = "";
    };
    "3.9-aarch64-darwin" = {
      platform = "macosx_13_0_arm64";
      dist = "cp39";
      hash = "";
    };

    "3.10-x86_64-linux" = {
      platform = "manylinux_2_27_x86_64";
      dist = "cp310";
      hash = "";
    };
    "3.10-aarch64-linux" = {
      platform = "manylinux_2_27_aarch64";
      dist = "cp310";
      hash = "";
    };
    "3.10-x86_64-darwin" = {
      platform = "macosx_11_0_x86_64";
      dist = "cp310";
      hash = "";
    };
    "3.10-aarch64-darwin" = {
      platform = "macosx_13_0_arm64";
      dist = "cp310";
      hash = "";
    };

    "3.11-x86_64-linux" = {
      platform = "manylinux_2_27_x86_64";
      dist = "cp311";
      hash = "sha256-jj0dGQCo9NlW9oGcJGx4CBclubCIj4VJ0qeknI2qEwM=";
    };
    "3.11-aarch64-linux" = {
      platform = "manylinux_2_27_aarch64";
      dist = "cp311";
      hash = "";
    };
    "3.11-x86_64-darwin" = {
      platform = "macosx_11_0_x86_64";
      dist = "cp311";
      hash = "";
    };
    "3.11-aarch64-darwin" = {
      platform = "macosx_13_0_arm64";
      dist = "cp311";
      hash = "sha256-IYK4GNzTKQ3S3bACGtBFO/2pkJjJMdWy/GNqNByzynA=";
    };
  };

  pyVersion = lib.versions.majorMinor python.version;
  srcInputs =
    prebuiltSrcs."${pyVersion}-${stdenv.system}"
      or (throw "open3d-bin for Python version '${pyVersion}' is not supported on '${stdenv.system}'");

  src = fetchPypi rec {
    inherit pname version;
    inherit (srcInputs) platform dist hash;

    python = dist;
    abi = dist;

    format = "wheel";
  };
in
buildPythonPackage {
  inherit pname version;
  format = "wheel";

  inherit src;

  patchPhase = ''
    ${unzip}/bin/unzip ./dist/open3d-${version}-${srcInputs.dist}-${srcInputs.dist}-${srcInputs.platform}.whl -d tmp
    rm ./dist/open3d-${version}-${srcInputs.dist}-${srcInputs.dist}-${srcInputs.platform}.whl
    #sed -i 's/sklearn/scikit-learn/g' tmp/open3d-${version}.dist-info/METADATA
    cd tmp
    ${zip}/bin/zip -0 -r ../dist/open3d-${version}-${srcInputs.dist}-${srcInputs.dist}-${srcInputs.platform}.whl ./*
    cd ../
  '';

  nativeBuildInputs = [ ]
  ++ (lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ]);

  buildInputs = [
    # so deps
    stdenv.cc.cc.lib
    libusb.out
    tensorflow-bin
    libGL
    libglvnd
    expat
    xorg.libXxf86vm
    xorg.libXfixes
    libllvm-wrapped
    pkgs.mesa
    pkgs.zstd
  ]
  ++ (lib.optionals stdenv.isLinux [
    libdrm
    pytorchWithCuda
    cudaPackages_11.cudatoolkit.lib
  ])
  ++ (lib.optionals stdenv.isDarwin [
    torch
  ]);

  propagatedBuildInputs = [
    # py deps
    ipywidgets
    tqdm
    pyyaml
    pandas
    plyfile
    scipy
    scikitlearn
    numpy
    matplotlib
    plotly
    dash
    addict
  ];

  pythonImportsCheck = [
    "open3d"
  ];

  preFixup = ''
    echo "OUTPUT TO: $out"
    cd $out/lib/python3.*/site-packages/open3d

    ${lib.optionalString stdenv.isLinux "rm libGL.so.1 libEGL.so.1"}

    ln -s ${libGL}/lib/libGL.so.1 libGL.so.1
    ln -s ${libGL}/lib/libEGL.so.1 libEGL.so.1
  '';
}
