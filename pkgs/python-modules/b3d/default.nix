{
  lib,
  stdenv,
  config,
  fetchFromGitHub,
  buildPythonPackage,
  cudaSupport ? config.cudaSupport,
  cudaPackages_12,
  which,
  libglvnd,
  libGLU,
  open3d,
  symlinkJoin,
  genjax,
  distinctipy,
  pyransac3d,
  opencv-python,
  setuptools,
  setuptools-scm,
  torch,
  graphviz,
  imageio,
  matplotlib,
  meshcat,
  natsort,
  ninja,
  opencv4,
  plyfile,
  liblzfse,
  tensorflow-probability,
  timm,
  trimesh,
  jupyter,
  pdoc3,
  pytest,
  torchaudio,
  torchvision,
  rerun-sdk,
  fire,
}:
let
  rev = "8113f643a7ba084e0ca2288cf06f95a23e39d1c7";

  cuda-common-redist = with cudaPackages_12; [
    cuda_cccl # <thrust/*>
    libcublas # cublas_v2.h
    libcurand
    libcusolver # cusolverDn.h
    libcusparse # cusparse.h
    libnvjitlink
  ];

  cuda-native-redist = symlinkJoin {
    name = "cuda-native-redist-${cudaPackages_12.cudaVersion}";
    paths =
      with cudaPackages_12;
      [
        cuda_cudart # cuda_runtime.h cuda_runtime_api.h
        cuda_nvcc
      ]
      ++ cuda-common-redist;
  };
in
buildPythonPackage rec {
  pname = "b3d";
  version = "0.0.1+${builtins.substring 0 8 rev}";

  src = fetchFromGitHub {
    repo = pname;
    owner = "probcomp";
    inherit rev;
    hash = "sha256-El7toDeI0NEP0MBMVDcGONQUtkOyLYhzqKY+Gp8LRck=";
  };

  patches = [
    ./fudge-deps.patch
    #./optional-cuda.patch
  ];

  pyproject = true;

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    which
  ];

  buildInputs = [
    libglvnd
    libGLU
  ]
  ++ (lib.optionals cudaSupport [
    cudaPackages_12.cudatoolkit.lib
  ]);

  propagatedBuildInputs = [
    distinctipy
    genjax
    graphviz
    imageio
    jupyter
    liblzfse
    matplotlib
    meshcat
    natsort
    ninja
    open3d
    opencv-python
    opencv4
    pdoc3
    plyfile
    pyransac3d
    pytest
    tensorflow-probability
    trimesh
    torch
    timm
    torchaudio
    torchvision
    rerun-sdk
    fire
  ];

  preBuild = "" + (lib.optionalString cudaSupport ''
    export CUDA_HOME=${cuda-native-redist}
  '');

  env.WITH_CUDA = if cudaSupport then "1" else "0";

  pythonImportsCheck = [ "b3d" ];
}
