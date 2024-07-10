{ buildPythonPackage
, inputs
, poetry-core
, poetry-dynamic-versioning
, stdenv
, beartype
, deprecated
, dill
, jax
, jaxtyping
, equinox
, numpy
, optax
, oryx
, plum-dispatch
, pygments
, rich
, tensorflow-probability
, typing-extensions
}:
let
  src = stdenv.mkDerivation {
    name = "genjax-source";
    version = inputs.genjax.shortRev;
    src = inputs.genjax;
    
    patches = [
      ./set-pyproject-version.patch
      ./use-beartype-0.18.0-version.patch
    ];

    installPhase = ''
      mkdir $out
      ls -alsph $src
      cp -rfv ./. $out
    '';
  };
in
buildPythonPackage {
  __noChroot = true;

  pname = "genjax";
  version = "0.1.1";
  inherit src;
  format = "pyproject";

  nativeBuildInputs = [
    #poetry
    poetry-core
    poetry-dynamic-versioning
  ];

  propagatedBuildInputs = [
    beartype
    deprecated
    dill
    jax
    jaxtyping
    equinox
    numpy
    optax
    oryx
    plum-dispatch
    pygments
    rich
    tensorflow-probability
    typing-extensions
  ];

  pythonImportsCheck = [ "genjax" ];
}
