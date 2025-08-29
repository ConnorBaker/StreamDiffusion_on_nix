{
  inputs = {
    nixpkgs.url = "github:ConnorBaker/nixpkgs/feat/cuda-packaging-refactor";
    stream-diffusion = {
      url = "github:cumulo-autumn/StreamDiffusion/pull/188/merge";
      flake = false;
    };
  };
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      forSystems = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      legacyPackages = forSystems (
        system:
        let
          systemToCudaCapability = {
            x86_64-linux = "8.9";
            aarch64-linux = "8.7";
          };
        in
        import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ systemToCudaCapability.${system} ];
          };
          overlays = [
            (_: prev: {
              pythonPackagesExtensions = prev.pythonPackagesExtensions or [ ] ++ [
                (finalPython: _: {
                  stream-diffusion = finalPython.callPackage ./streamDiffusion.nix { src = inputs.stream-diffusion; };
                })
              ];
            })
          ];
        }
      );

      packages = forSystems (
        system:
        let
          pkgs = inputs.self.legacyPackages.${system};
        in
        {
          inherit (pkgs.python3Packages) stream-diffusion;
          morpheus = pkgs.writers.writePython3Bin "morpheus" {
            libraries = ps: [
              ps.stream-diffusion
              ps.av
              ps.gradio
              (ps.opencv4.override { enableGtk3 = true; })
            ];
            flakeIgnore = [ "E501" ];
          } ./demo_webcam_morph.py;
        }
      );

      devShells = forSystems (
        system:
        let
          pkgs = inputs.self.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell { packages = [ inputs.self.packages.${system}.morpheus ]; };
        }
      );
    };
}
