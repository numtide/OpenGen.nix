{ ... }: {
  perSystem =
    {
      config,
      self',
      pkgs,
      system,
      ...
    }:
    let
      devshellPython = (
        self'.legacyPackages.python3Packages.python.withPackages (p: [
          self'.legacyPackages.python3Packages.bayes3d
          self'.legacyPackages.python3Packages.jax
          p.jupyter
          p.scipy
        ])
      );
    in
    {
      devShells.default = pkgs.mkShell {
        packages = [
          self'.legacyPackages.python3Packages.python-lsp-server
          devshellPython
        ];

        shellHook = ''
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
          export CUDA_PATH=${pkgs.cudatoolkit_11}
          export B3D_ASSET_PATH="${self'.packages.bayes3d.src}/assets"

          jupyter notebook
        '';
      };
    };
  }
