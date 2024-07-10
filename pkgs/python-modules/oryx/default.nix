{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  jax,
  jaxlib-bin,
  tensorflow-probability,
}:

buildPythonPackage rec {
  pname = "oryx";
  version = "0.2.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8spdSJN9e9jDdc6KxSmh7Z+NoxJjNNLgz91rfxuepI8=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    jax
    jaxlib-bin
    tensorflow-probability
  ];

  pythonImportsCheck = [ "oryx" ];

  meta = with lib; {
    description = "Probabilistic programming and deep learning in JAX";
    homepage = "https://pypi.org/project/oryx";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
