{ lib
, fetchurl
, buildPythonPackage
, autoPatchelfHook
}:

buildPythonPackage {
  pname = "cuda-python";
  version = "12.5.0";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/fb/ab/9094c236c5310f5b00c911d1ac64a22ce183bc7ca4ef698bcb19a364285a/cuda_python-12.5.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    sha256 = "sha256-TC8/ybgUn/y0AW2OXtSuHXKKVfoC3ps9LCwUzafk7o4=";
  };

  propagatedBuildInputs = [];

  nativeBuildInputs = [ autoPatchelfHook ];

  pythonImportsCheck = [ "cuda" ];
}
