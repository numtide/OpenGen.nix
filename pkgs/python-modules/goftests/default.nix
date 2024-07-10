{
  fetchPypi,
  buildPythonPackage,
  numpy,
  scipy,
}:
# TODO: upstream
buildPythonPackage rec {
  pname = "goftests";
  version = "0.2.7";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5s0NugSus2TuZIInesCNJNAtxEHnZLQIjn0pxGgwL/o=";
  };

  buildInputs = [
    numpy
    scipy
  ];

  doCheck = false;

  # https://github.com/numba/numba/issues/8698#issuecomment-1584888063 
  env.NUMPY_EXPERIMENTAL_DTYPE_API = 1;

  patchPhase = ''
    mkdir -p dist
  '';
}
