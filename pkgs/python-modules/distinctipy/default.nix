{
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  numpy,
}:
buildPythonPackage rec {
  pname = "distinctipy";
  version = "1.3.4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alan-turing-institute";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-y+++w+YwIR+krSnFlZmkNNCkmquh+2T+T5UdusxTD+w=";
  };

  doCheck = false;

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [ numpy ];

  pythonImportsCheck = [ "distinctipy" ];
}
