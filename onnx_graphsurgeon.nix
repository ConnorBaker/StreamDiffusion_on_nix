{ fetchurl
, buildPythonPackage
, autoPatchelfHook
, numpy
, onnx
}:

buildPythonPackage {
  pname = "onnx_graphsurgeon";
  version = "0.5.2";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/0d/20/93e7143af3a0b3b3d9f3306bfc46e55d0d307242b4c1bf36ff108460e5a3/onnx_graphsurgeon-0.5.2-py2.py3-none-any.whl";
    sha256 = "sha256-EMEw1hKf3u4ClF+BA7WxEub9TZs1bi3T6A9T4Ovue1w=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  propagatedBuildInputs = [ numpy onnx ];

  pythonImportsCheck = [ "onnx_graphsurgeon" ];
}
