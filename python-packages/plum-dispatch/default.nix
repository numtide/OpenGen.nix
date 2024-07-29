{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  beartype,
  rich,
  typing-extensions,
  black,
  build,
  coveralls,
  ghp-import,
  ipython,
  jupyter-book,
  mypy,
  numpy,
  pre-commit,
  pyright,
  pytest,
  pytest-cov,
  ruff,
  tox,
  wheel,
}:

buildPythonPackage rec {
  pname = "plum-dispatch";
  version = "2.3.5";
  pyproject = true;

  src = fetchPypi {
    pname = "plum_dispatch";
    inherit version;
    hash = "sha256-eticwgKdh7Djusx8x3Pxlq4ynOEV8wi2Ly0GxosYo40=";
  };

  nativeBuildInputs = [
    hatch-vcs
    hatchling
  ];

  propagatedBuildInputs = [
    beartype
    rich
    typing-extensions
  ];

  passthru.optional-dependencies = {
    dev = [
      black
      build
      coveralls
      ghp-import
      ipython
      jupyter-book
      mypy
      numpy
      pre-commit
      pyright
      pytest
      pytest-cov
      ruff
      tox
      wheel
    ];
  };

  pythonImportsCheck = [ "plum" ];

  meta = with lib; {
    description = "Multiple dispatch in Python";
    homepage = "https://pypi.org/project/plum-dispatch";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
