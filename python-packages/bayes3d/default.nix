{
  lib,
  config,
  fetchFromGitHub,
  buildPythonPackage,
  cudaSupport ? config.cudaSupport,
  cudaPackages_11,
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
  opencv4,
  plyfile,
  liblzfse,
  tensorflow-probability,
  timm,
  trimesh,
}:
let
  rev = "8113f643a7ba084e0ca2288cf06f95a23e39d1c7";

  cuda-common-redist = with cudaPackages_11; [
    cuda_cccl # <thrust/*>
    libcublas # cublas_v2.h
    libcurand
    libcusolver # cusolverDn.h
    libcusparse # cusparse.h
  ];

  cuda-native-redist = symlinkJoin {
    name = "cuda-native-redist-${cudaPackages_11.cudaVersion}";
    paths =
      with cudaPackages_11;
      [
        cuda_cudart # cuda_runtime.h cuda_runtime_api.h
        cuda_nvcc
      ]
      ++ cuda-common-redist;
  };
in
buildPythonPackage rec {
  pname = "bayes3d";
  version = "0.1.0+${builtins.substring 0 8 rev}";

  src = fetchFromGitHub {
    repo = pname;
    owner = "srounce";
    inherit rev;
    hash = "sha256-6AtxR8ZsByliDTQE/hEJs5+LKwdfS/sRGYXf+mgFHxw=";
  };

  patches = [ ./optional-cuda.patch ];

  pyproject = true;

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    which
  ];

  buildInputs = [
    libglvnd
    libGLU
  ] ++ (lib.optionals cudaSupport [ cudaPackages_11.cudatoolkit.lib ]);

  propagatedBuildInputs = [
    distinctipy
    genjax
    graphviz
    imageio
    liblzfse
    matplotlib
    meshcat
    natsort
    open3d
    opencv-python
    opencv4
    plyfile
    pyransac3d
    tensorflow-probability
    trimesh
    torch
    timm
  ];

  preBuild =
    ""
    + (lib.optionalString cudaSupport ''
      export CUDA_HOME=${cuda-native-redist}
    '');

  env.WITH_CUDA = if cudaSupport then "1" else "0";

  pythonImportsCheck = [ "bayes3d" ];
}
