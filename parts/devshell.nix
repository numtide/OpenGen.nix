{ ... }:
{
  perSystem =
    { self', pkgs, ... }:
    let
      inherit (pkgs) lib config;

      devshellPython = self'.packages.python.withPackages (p: [
        p.bayes3d
        p.jax
        p.jupyter
        p.pip
        p.scipy
      ]);

      cudaShellHook = ''
        export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
        export CUDA_PATH=${pkgs.cudatoolkit_11}
      '';
    in
    {
      # This developer shell is loaded with `nix develop`.
      devShells.default = pkgs.mkShell {
        packages = [
          self'.packages.python.pkgs.python-lsp-server
          devshellPython
        ];

        shellHook = ''
          ${lib.optionalString config.cudaSupport cudaShellHook}
          export EXTRA_CCFLAGS="-I/usr/include"
          export B3D_ASSET_PATH="${self'.packages.python.pkgs.bayes3d.src}/assets"

          # Create a virtualenv for pip escape hatches.
          python -m venv .venv
          source .venv/bin/activate
        '';
      };

      checks.devShell = self'.devShells.default;
    };
}
