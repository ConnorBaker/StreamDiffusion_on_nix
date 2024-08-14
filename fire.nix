{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
, six
, termcolor
}:

buildPythonPackage rec {
  pname = "fire";
  version = "0.6.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VOxbmW7N08AwnIADJKBwPW2lEiQbxztVPblZ2Y3gqmY=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    six
    termcolor
  ];

  pythonImportsCheck = [ "fire" ];

  meta = with lib; {
    description = "A library for automatically generating command line interfaces";
    homepage = "https://pypi.org/project/fire/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
