{
  abseil-cpp,
  absl-py,
  attrs,
  autoPatchelfHook,
  buildPythonPackage,
  cmake,
  fetchFromGitHub,
  fetchurl,
  lib,
  numpy,
  pybind11,
  six,
  stdenv,
  wrapt,
}:
let
  srcs = {
    "aarch64-linux" = fetchurl {
      url = "https://files.pythonhosted.org/packages/fe/89/386332bbd7567c4ccc13aa2e58f733237503fc75fb389955d3b06b9fb967/dm_tree-0.1.8-cp311-cp311-manylinux_2_17_aarch64.manylinux2014_aarch64.whl";
      hash = "sha256-FgfOSapC8BDR5eYW2SzomdZoNdTYvqSWeVgkNShVFd4=";
    };

    "x86_64-linux" = fetchurl {
      url = "https://files.pythonhosted.org/packages/4a/27/c5e3580a952a07e5a1428ae952874796870dc8db789f3d774e886160a9f4/dm_tree-0.1.8-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
      hash = "sha256-g7d2TeDYVTOKvvxuPun+QNMBZoMQqjuuo/d4/wUfQ5M=";
    };

    "aarch64-darwin" = fetchurl {
      url = "https://files.pythonhosted.org/packages/e2/64/901b324804793743f0fdc9e47db893bf0ded9e074850fab2440af330fe83/dm_tree-0.1.8-cp311-cp311-macosx_10_9_universal2.whl";
      hash = "sha256-rRbOupClbsR89FshhW0UlirDFHh5de94bvtebpynXsc=";
    };

    "x86_64-darwin" = fetchurl {
      url = "https://files.pythonhosted.org/packages/e2/64/901b324804793743f0fdc9e47db893bf0ded9e074850fab2440af330fe83/dm_tree-0.1.8-cp311-cp311-macosx_10_9_universal2.whl";
      hash = "sha256-rRbOupClbsR89FshhW0UlirDFHh5de94bvtebpynXsc=";
    };
  };
in

buildPythonPackage rec {
  pname = "dm-tree";
  version = "0.1.8";
  format = "wheel";

  src = srcs.${stdenv.system} or (throw "system ${stdenv.system} not supported");

  nativeBuildInputs = [
    autoPatchelfHook
    # pybind11
  ];

  buildInputs = [
    # abseil-cpp
    # pybind11
    stdenv.cc.cc
  ];

  propagatedBuildInputs = [ six ];

  # nativeCheckInputs = [
  #   absl-py
  #   attrs
  #   numpy
  #   wrapt
  # ];

  pythonImportsCheck = [ "tree" ];

  passthru.srcs = srcs;

  meta = with lib; {
    broken = stdenv.isDarwin;
    description = "Tree is a library for working with nested data structures";
    homepage = "https://github.com/deepmind/tree";
    license = licenses.asl20;
    maintainers = with maintainers; [
      samuela
      ndl
    ];
  };
}
