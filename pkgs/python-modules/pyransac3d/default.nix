{
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  wheel,
  numpy,
}:
# TODO: upstream me
buildPythonPackage rec {
  pname = "pyransac3d";
  version = "0.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "leomariga";
    repo = "pyRANSAC-3D";
    rev = "v${version}";
    hash = "sha256-QplIgH+zjkZgPWMvvpV2yM/HEEBRea4D+dG7G7h2jdQ=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [ numpy ];

  pythonImportsCheck = [ "pyransac3d" ];
}
