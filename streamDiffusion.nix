{ lib
, fetchPypi
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, torch
, torchvision
, xformers
, tensorrt
, callPackage
, omegaconf 
, diffusers 
, transformers 
, accelerate
, peft
, onnxruntime
, cudaPackages_12
}:

buildPythonPackage rec {
  pname = "stream-diffusion";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cumulo-autumn";
    repo = "StreamDiffusion";
    rev = "v${version}";
    hash = "sha256-XmScuZ3XIVl9qoYVDo97ZzBaCt8//suFDvHhgTKNfAk=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];
  
  propagatedBuildInputs = [
    torch
    torchvision
    xformers

    (callPackage ./fire.nix {})
    (callPackage ./polygraphy.nix {})
    (callPackage ./onnx_graphsurgeon.nix {})
    (callPackage ./cuda-python.nix {})
    onnxruntime
    diffusers
    omegaconf 
    transformers 
    accelerate 

    peft # undeclared in requirements
    ((tensorrt.override { cudaPackages = cudaPackages_12; }).overrideAttrs {
      preUnpack = ''
        mkdir -p dist
        tar --strip-components=2 -xf "$src" --directory=dist \
          "TensorRT-8.6.1.6/python/tensorrt-8.6.1-cp311-none-linux_x86_64.whl"
    ''; })
#    ((tensorrt.override {}).overrideAttrs {
#      preUnpack = ''
#        mkdir -p dist
#        tar --strip-components=2 -xf "$src" --directory=dist \
#          "TensorRT-8.6.1.6/python/tensorrt-8.6.1-cp311-none-linux_x86_64.whl"
#    ''; })
  ];

  pythonImportsCheck = [ "streamdiffusion" ];

  meta = with lib; {
    description = "StreamDiffusion: A Pipeline-Level Solution for Real-Time Interactive Generation";
    homepage = "https://github.com/cumulo-autumn/StreamDiffusion";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
