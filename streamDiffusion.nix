{
  buildPythonPackage,
  diffusers,
  fire,
  lib,
  omegaconf,
  onnxruntime,
  peft,
  setuptools,
  torch,
  torchvision,
  transformers,
  wheel,
  xformers,
  # Mandatory argument
  src,
}:

buildPythonPackage {
  pname = "stream-diffusion";
  version = "0.1.1-unstable";
  pyproject = true;

  inherit src;

  postPatch = ''
    nixLog "patching $PWD/setup.py"
    substituteInPlace setup.py \
      --replace-fail \
        "diffusers==0.24.0" \
        "diffusers" \
      --replace-fail \
        "onnx==1.15.0" \
        "onnx" \
      --replace-fail \
        "onnxruntime==1.16.3" \
        "onnxruntime" \
      --replace-fail \
        "protobuf==3.20.2" \
        "protobuf"
  '';

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    diffusers
    fire
    omegaconf
    onnxruntime
    peft
    torch
    torchvision
    transformers
    xformers
  ]
  ++ diffusers.optional-dependencies.torch;

  pythonImportsCheck = [ "streamdiffusion" ];

  meta = {
    description = "Pipeline-Level Solution for Real-Time Interactive Generation";
    homepage = "https://github.com/cumulo-autumn/StreamDiffusion";
    license = lib.licenses.asl20;
  };
}
