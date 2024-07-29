{ ... }:
{
  perSystem =
    { self', pkgs, lib, ... }:
    {
      packages = {
        jupyter-bayes3d =
          let
            devshellPython = self'.packages.python.withPackages (p: [
              p.bayes3d
              p.jax
              p.jupyter
              p.scipy
            ]);

            cudaShellHook = ''
              export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
              export CUDA_PATH=${pkgs.cudatoolkit_11}
            '';
          in
          pkgs.writeShellApplication {
            name = "jupyter-bayes3d";
            runtimeInputs = [
              devshellPython
              self'.packages.python.pkgs.python-lsp-server
            ];
            text = ''
              set -euo pipefail

              ${lib.optionalString pkgs.config.cudaSupport cudaShellHook}
              export EXTRA_CCFLAGS="-I/usr/include"
              export B3D_ASSET_PATH="${self'.packages.python.pkgs.bayes3d.src}/assets"

              exec jupyter "$@"
            '';
          };
      };

      # Map all the packages to flake checks
      checks = pkgs.lib.mapAttrs' (name: value: {
        name = "pkg-${name}";
        inherit value;
      }) self'.packages;
    };
}
