{
  fetchPypi,
  buildPythonPackage,
  pybind11,
}:
buildPythonPackage rec {
  pname = "PyMetis";
  version = "2023.1.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3AZdu3gu5bGBY0FIjmjtp0/+Mgrhye/TXuXl1toRmj8=";
  };

  doCheck = false;

  nativeBuildInputs = [ pybind11 ];
}
