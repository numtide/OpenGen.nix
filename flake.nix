{
  description = "Nix utilities and cross-repo build artifacts for OpenGen";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs?ref=d8724afca4565614164dd81345f6137c4c6eab21";
    nixpkgs-llvm-10.url = "github:NixOS/nixpkgs?rev=222c1940fafeda4dea161858ffe6ebfc853d3db5";

    genjax.url = "github:probcomp/genjax?ref=v0.1.1";
    genjax.flake = false;

    poetry2nix.url = "github:nix-community/poetry2nix";
    poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig.extra-substituters = [ "https://numtide.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [ "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=" ];
  nixConfig.sandbox = "relaxed";

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
        ./lib
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];


      # NOTE: This property is consumed by flake-parts.mkFlake to specify outputs of
      # the flake that are replicated for each supported system. Typically packages,
      # apps, and devshells are per system.
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        sppl = pkgs.callPackage ./pkgs/sppl {};

        ociImgBase = pkgs.callPackage ./pkgs/ociBase {
          inherit nixpkgs;
          basicTools = self.lib.basicTools;
        };
        
        poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };

        scopes = (self.lib.mkScopes {
          inherit pkgs internalPackages inputs poetry2nix;
          basicTools = self.lib.basicTools;
        });
        loom = scopes.callPy3Package ./pkgs/loom { };

        # TODO: make this cleaner
        bayes3d = self'.legacyPackages.python3Packages.bayes3d;
        open3d = scopes.callPy3Package ./pkgs/python-modules/open3d { };

        internalPackages = {
          #jaxlib = scopes.callPy3Package ./pkgs/jaxlib { };
          #jax = scopes.callPy3Package ./pkgs/jax { };
          jaxtyping = scopes.callPy3Package ./pkgs/jaxtyping { };
          tinygltf = scopes.callPackage ./pkgs/tinygltf { };
          PoissonRecon = scopes.callPackage ./pkgs/PoissonRecon { };
          goftests = scopes.callPackage ./pkgs/goftests { };
          parsable = scopes.callPackage ./pkgs/parsable { };
          pymetis = scopes.callPackage ./pkgs/pymetis { };
          distributions = scopes.callPackage ./pkgs/distributions { };
          genjax = scopes.callPy3Package ./pkgs/genjax { };
          distinctipy = scopes.callPy3Package ./pkgs/distinctipy { };
          pyransac3d = scopes.callPy3Package ./pkgs/pyransac3d { };
          opencv-python = scopes.callPy3Package ./pkgs/opencv-python { };
          oryx = scopes.callPy3Package ./pkgs/oryx { };
          plum-dispatch = scopes.callPy3Package ./pkgs/plum-dispatch { };
        } // packages;

        packages = {
          inherit
            loom
            sppl

            ociImgBase

            bayes3d
            open3d
            ;
        };

        loadPackages = callPackage: path:
          let
            entries = builtins.readDir path;
          in
            pkgs.lib.mapAttrs (name: type: 
            if type != "directory" then (throw "${toString path}/${name} is not a directory")
            else
              callPackage "${toString path}/${name}" { }
            )
            entries;

        # For fixing existing packages that live in nixpkgs
        # TODO: put in separate file
        pythonOverrides = super: pythonSuper: {
          # so we can pull from flake inputs
          inherit inputs;

          # FIXME: I don't think this is working as expected. Better to change nixpkgs wthfor now.

          # Use the pre-built version of tensorflow
          tensorflow = pythonSuper.tensorflow-bin;

          # Use the pre-built version of jaxlib
          jaxlib = super.jaxlib-bin;

          # Use the pre-built version of libjax
          libjax = super.libjax-bin;
        };
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            # FIXME: commenting these out to see if they fix the duplicate dependency issue when building bayes3d
            allowUnfree = true;
            # Only enable CUDA on Linux
            cudaSupport = (system == "x86_64-linux" || system == "aarch64-linux");
          };
          overlays = [
            (final: prev: {
              # FIXME: say why this was added.
              inherit (inputs.nixpkgs-llvm-10.legacyPackages.${system}) llvmPackages_10;
            })
          ];
        };

        inherit packages;

        checks = packages;

        legacyPackages.python3Packages = 
        (pkgs.python311Packages.overrideScope pythonOverrides).overrideScope (super: superPython:
          loadPackages super.callPackage ./pkgs/python-modules
        );

        devShells.default = pkgs.mkShell {
          packages = [
            self'.legacyPackages.python3Packages.python-lsp-server
            (self'.legacyPackages.python3Packages.python.withPackages (p: [
              self'.legacyPackages.python3Packages.bayes3d
              self'.legacyPackages.python3Packages.jax
              p.jupyter
              p.scipy
            ]))
          ];

          shellHook = ''
            export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
            export EXTRA_CCFLAGS="-I/usr/include"
            export CUDA_PATH=${pkgs.cudatoolkit_11}
            export B3D_ASSET_PATH="${bayes3d.src}/assets"

            jupyter notebook
          '';
        };
      };

      # NOTE: this property is consumed by flake-parts.mkFlake to define fields
      # of the flake that are NOT per system, such as generic `lib` code or other
      # universal exports. Note that in our case, the lib is equivalently declared
      # by modules that are imported (see ./lib/devtools/default.nix)
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
