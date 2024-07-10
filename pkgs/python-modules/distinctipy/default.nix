{
  fetchPypi,
  buildPythonPackage,
  setuptools,
  numpy,
}:
buildPythonPackage rec {
  pname = "distinctipy";
  version = "1.3.4";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/tl6//Gvtz7KqHyFRhAh8LqJ+uYwZ8ASW5ZzUmUQqsQ=";
  };

  doCheck = false;

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [ numpy ];
}
