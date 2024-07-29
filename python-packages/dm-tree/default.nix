{
  autoPatchelfHook,
  buildPythonPackage,
  fetchPypi,
  python,
  isPy311,
  lib,
  stdenv,
}:
let
  prebuiltWheels = {
    "3.11-x86_64-linux" = {
      platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
      dist = "cp311";
      hash = "sha256-g7d2TeDYVTOKvvxuPun+QNMBZoMQqjuuo/d4/wUfQ5M=";
    };
    "3.11-aarch64-linux" = {
      platform = "manylinux_2_17_aarch64.manylinux2014_aarch64";
      dist = "cp311";
      hash = "sha256-FgfOSapC8BDR5eYW2SzomdZoNdTYvqSWeVgkNShVFd4=";
    };
    "3.11-x86_64-darwin" = {
      platform = "macosx_10_9_x86_64";
      dist = "cp311";
      hash = "sha256-gDv8U7Rln0R6xpTb0EI1+Upz73wf0eDffISsQeC8ljs=";
    };
    "3.11-aarch64-darwin" = {
      platform = "macosx_11_0_arm64";
      dist = "cp311";
      hash = "sha256-N4zIrZPF/jWQ9AWjCZgHIfAhx5DKG9+bFbsdWdrsV/U=";
    };
  };

  pyVersion = lib.versions.majorMinor python.version;
  srcInputs =
    prebuiltWheels."${pyVersion}-${stdenv.system}"
      or (throw "dm-tree for Python version '${pyVersion}' is not supported on '${stdenv.system}'");
in
buildPythonPackage rec {
  pname = "dm-tree";
  version = "0.1.8";
  format = "wheel";

  disabled = !isPy311;

  src = fetchPypi {
    inherit version;
    inherit (srcInputs) platform dist hash;

    pname = (builtins.replaceStrings [ "-" ] [ "_" ] pname);

    python = srcInputs.dist;
    abi = srcInputs.dist;

    format = "wheel";
  };

  nativeBuildInputs = (lib.optionals stdenv.isLinux [ autoPatchelfHook ]);

  # Dynamic link dependencies
  buildInputs = [ stdenv.cc.cc ];

  pythonImportsCheck = [ "tree" ];

  meta = with lib; {
    description = "Tree is a library for working with nested data structures.";
    homepage = "https://github.com/deepmind/tree";
    license = licenses.asl20;
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
