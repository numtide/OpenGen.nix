{ lib
, stdenv
, fetchFromGitHub
, callPackage
, fetchPypi
, protobuf3_20
, buildPythonPackage

, eigen
, enum34
, goftests
, numpy
, parsable
, pillow
, protobuf
, pyflakes
, pytest
, cython_0
, scipy
, simplejson
, nose
}:
let
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "posterior";
    repo = "distributions";
    rev = "43c11618b0f229682fb916612ba2437c5f22a753"; # there is no tag
    sha256 = "sha256-DiJ6Ljwc5K1CrzzexAQ53g86sKqaroYRhmXuxAHAOq4=";
  };

  distributions-shared = callPackage ./distributions-shared.nix { inherit version src; };

  # TODO: move into own package
  imageio_2_6_1 = buildPythonPackage rec {
    pname = "imageio";
    version = "2.6.1";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-9E6yMbnfSFh08v/SLf0MPHEefeB2UWuTdO3qXGW8Z64=";
    };

    doCheck = false;

    nativeBuildInputs = [
      pytest
    ];

    propagatedBuildInputs = [
      pillow
    ];

    buildInputs = [
      enum34
      numpy
    ];
  };
in
buildPythonPackage {
  pname = "distributions";

  inherit version src;

  nativeBuildInputs = [
    protobuf3_20
    pyflakes
  ];

  buildInputs = [
    eigen
    # TODO: we're not sure if this is even needed
    distributions-shared
    protobuf3_20
  ];

  propagatedBuildInputs = [
    protobuf3_20
    protobuf
    cython_0
    numpy
    parsable
    scipy
    simplejson
  ];

  # TODO: be more precise. Some tests seem to be still in Python 2.
  doCheck = false;
  nativeCheckInputs = [
    imageio_2_6_1
    nose
    goftests
    pytest
  ];

  preBuild = ''
    make protobuf
  '';

  patches = [
    ./use-imread-instead-of-scipy.patch
  ] ++ (lib.optionals stdenv.isDarwin [
    ./gnu-sed-on-darwin.patch
  ]);

  env.DISTRIBUTIONS_USE_PROTOBUF = 1;

  # https://github.com/numba/numba/issues/8698#issuecomment-1584888063
  env.NUMPY_EXPERIMENTAL_DTYPE_API = 1;

  pythonImportsCheck = [
    "distributions"
    "distributions.io"
    "distributions.io.stream"
  ];

  passthru = {
    # TODO: we're not sure if this is even needed
    inherit distributions-shared;
  };
}
