{ fetchPypi, buildPythonPackage }:
buildPythonPackage rec {
  pname = "parsable";
  version = "0.3.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wy+SIMRfLTGro0ngh7UfKZPe6j8GOFo+0T6Cy1+LMJ8=";
  };

  patchPhase = ''
    mkdir -p dist
  '';
}
