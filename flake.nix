{
  nixConfig = {
    bash-prompt = "[devshell] ";
    extra-trusted-substituters = [
      "https://ai.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://nix.cache.vapor.systems"
      "https://numtide.cachix.org"
    ];
    extra-substituters = [
      "https://ai.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://nix.cache.vapor.systems"
      "https://numtide.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix.cache.vapor.systems-1:OjV+eZuOK+im1n8tuwHdT+9hkQVoJORdX96FvWcMABk="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
#  inputs.nixpkgs.url = "github:nixos/nixpkgs/2726f127c15a4cc9810843b96cad73c7eb39e443";
#  inputs.nixpkgs.url = "github:nixos/nixpkgs/c708923";
  outputs = { self, nixpkgs, ... }:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; config.cudaSupport = true; config.allowUnfree = true; config.allowBroken = true;
      overlays = [ (final: prev: {
#        cudaPackages = final.cudaPackages_11;
#        onnxruntime = (prev.onnxruntime.overrideAttrs (old: { cmakeFlags = old.cmakeFlags ++ [ (pkgs.lib.cmakeFeature "onnxruntime_NVCC_THREADS" "1") ]; }));
#        python3Packages = final.python3.pkgs;
        cudaPackages = prev.cudaPackages.overrideScope (cfinal: cprev: {
          tensorrt = cprev.tensorrt.override { cudaMajorMinorVersion = "12.0"; };
        });
        python3 = prev.python3.override {
          packageOverrides = pfinal: pprev: {
#            torch = pprev.torch-bin;
#            torchvision = pprev.torchvision-bin;
            diffusers = final.python3.pkgs.callPackage ./diffusers.nix {};
          };
        };
      }) ];
    };
  in
  rec {
    packages.x86_64-linux.stream-diffusion = pkgs.python3.pkgs.callPackage ./streamDiffusion.nix {};
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; [ 
        (python3.withPackages (p: [ packages.x86_64-linux.stream-diffusion p.av p.gradio (p.opencv4.override {enableGtk3=true;}) ]))
      ];
      shellHook = ''
        export LD_LIBRARY_PATH=/run/opengl-driver/lib:${pkgs.cudaPackages.cudatoolkit}/lib
      '';
    };
  };
}
