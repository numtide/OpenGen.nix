{
  stdenv,
  cmake,
  eigen,
  protobuf3_20,
  pyflakes,

  src,
  version,
}:
stdenv.mkDerivation {
  pname = "distributions-shared";

  inherit version src;

  nativeBuildInputs = [
    cmake
    pyflakes
  ];
  buildInputs = [
    eigen
    protobuf3_20
  ];

  env.DISTRIBUTIONS_USE_PROTOBUF = 1;

  preConfigure = ''
    make protobuf
  '';

  fixupPhase = ''
    ln -sv $out/lib/libdistributions_shared_release.so $out/lib/libdistributions_shared.so
    ln -sv $out/lib/libdistributions_shared_release.so $out/lib/libdistributions_shared_debug.so
  '';
}
