{ lib
, fetchurl
, buildPythonPackage
, protobuf
, numpy
, opencv4
, attrs
, matplotlib
, autoPatchelfHook
}:

buildPythonPackage rec {
  pname = "polygraphy";
  format = "wheel";

  #version = "0.49.9";
  #src = fetchurl {
  #  url = "https://files.pythonhosted.org/packages/4a/f5/a2b20c677c1a856cc9e08cd0b5a5105450ed5253e369e938ddd31d91c547/polygraphy-0.49.9-py2.py3-none-any.whl";
  #  sha256 = "sha256-Yq4igl790yiCIuWx0teR/ljoeET82Ei80SUfvOArqVY=";
  #};
  #version = "0.48.1";
  #src = fetchurl {
  #  url = "https://files.pythonhosted.org/packages/1b/2e/5699a18439fe281e42b7abe335a6ffb25ff2de23903cd020865b58f5861a/polygraphy-0.48.1-py2.py3-none-any.whl";
  #  sha256 = "sha256-6I/cCF8oYvcgA8Szvx1Cdy64RyxKSccLQg2wXvfWlak=";
  #};
  version = "0.47.1";
  src = fetchurl {
    url = "https://developer.download.nvidia.com/compute/redist/polygraphy/polygraphy-0.47.1-py2.py3-none-any.whl";
    sha256 = "sha256-bgGDlobeaFKmVE8UfoK+jzf2eOySnzHrC/Z0f/5KJkY=";
  };


  propagatedBuildInputs = [ ];

  nativeBuildInputs = [ autoPatchelfHook ];

  pythonImportsCheck = [ "polygraphy" ];
}
