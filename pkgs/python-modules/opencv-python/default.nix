{
  lib,
  stdenv,
  buildPythonPackage,
  fetchurl,
  autoPatchelfHook,

  numpy,
  libGL,
  xorg,
  libz,
  qt5,

  breakpointHook,
}:
let
  version = "4.10.0.84";
  pname = "opencv-python";

  wheelUrls = {
    "x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/3f/a4/d2537f47fd7fcfba966bd806e3ec18e7ee1681056d4b0a9c8d983983e4d5/opencv_python-4.10.0.84-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
      hash = "sha256-ms4UD8bWR/vhxpK8sqvOdolzSRIiwGfBMdgJV8WVtx8=";
    };

    "aarch64-linux" = {
      url = "https://files.pythonhosted.org/packages/81/e4/7a987ebecfe5ceaf32db413b67ff18eb3092c598408862fff4d7cc3fd19b/opencv_python-4.10.0.84-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl";
      hash = "";
    };

    "x86_64-darwin" = {
      url = "https://files.pythonhosted.org/packages/64/4a/016cda9ad7cf18c58ba074628a4eaae8aa55f3fd06a266398cef8831a5b9/opencv_python-4.10.0.84-cp37-abi3-macosx_12_0_x86_64.whl";
      hash = "";
    };

    "aarch64-darwin" = {
      url = "https://files.pythonhosted.org/packages/66/82/564168a349148298aca281e342551404ef5521f33fba17b388ead0a84dc5/opencv_python-4.10.0.84-cp37-abi3-macosx_11_0_arm64.whl";
      hash = "sha256-/Bgvj0zaUbRfAcZOTL7fwvAK/3md6+vDBdjQIQxD8lE=";
    };
  };

  src = fetchurl (
    if builtins.hasAttr stdenv.system wheelUrls then
      wheelUrls.${stdenv.system}
    else
      throw "Unsupported system"
  );
in
buildPythonPackage rec {
  inherit pname version;
  format = "wheel";

  inherit src;

  #patchPhase = ''
  #pwd

  #${unzip}/bin/unzip $src/${pname}-${version}-${pythonAbi}-${pythonAbi}-${pythonPlatform}.whl -d tmp
  #cd tmp
  #${zip}/bin/zip -0 -r ../dist/${pname}-${version}-${pythonAbi}-${pythonAbi}-${pythonPlatform}.whl ./*
  #cd ../
  #'';

  nativeBuildInputs = [ breakpointHook ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  dontWrapQtApps = true;

  buildInputs =
    [
      stdenv.cc.cc.lib
      libGL
      libz
      qt5.qtbase
    ]
    ++ lib.optionals stdenv.isLinux [
      xorg.libxcb
      xorg.libXext
      xorg.libX11
      xorg.libSM
      xorg.libICE
    ];

  propagatedBuildInputs = [ numpy ];

  pythonImportsCheck = [ "cv2" ];

  meta = with lib; {
    description = "Wrapper package for OpenCV python bindings";
    homepage = "https://pypi.org/project/opencv-python";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [ ];
  };
}
