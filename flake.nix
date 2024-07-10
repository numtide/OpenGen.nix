{
  description = "Nix utilities and cross-repo build artifacts for OpenGen";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs?ref=d8724afca4565614164dd81345f6137c4c6eab21";
    nixpkgs-llvm-10.url = "github:NixOS/nixpkgs?rev=222c1940fafeda4dea161858ffe6ebfc853d3db5";

    genjax.url = "github:probcomp/genjax?ref=v0.1.1";
    genjax.flake = false;
  };

  nixConfig.extra-substituters = [ "https://numtide.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
  ];
  nixConfig.sandbox = "relaxed";

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
        ./lib
        ./devshell.nix
        ./pkgs/python-packages.nix
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [
        "aarch64-darwin"
        # "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      # NOTE: This property is consumed by flake-parts.mkFlake to specify outputs of
      # the flake that are replicated for each supported system. Typically packages,
      # apps, and devshells are per system.
      perSystem =
        {
          config,
          self',
          pkgs,
          system,
          ...
        }:
        let
          ociImgBase = pkgs.callPackage ./pkgs/ociBase {
            inherit nixpkgs;
            basicTools = self.lib.basicTools;
          };

          packages = rec {
            inherit ociImgBase;

            inherit (self'.legacyPackages.python3Packages) loom sppl bayes3d;

            loomOCI = pkgs.dockerTools.buildLayeredImage {
              name = "probcomp/loom";
              contents =
                [ loom pkgs.bashInteractive ] ++
                (self.lib.basicTools pkgs)
              ;
            };
          };

          loadPackages =
            callPackage: path:
            let
              entries = builtins.readDir path;
            in
            pkgs.lib.mapAttrs (
              name: type:
              if type != "directory" then
                (throw "${toString path}/${name} is not a directory")
              else
                callPackage "${toString path}/${name}" { }
            ) entries;
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              # FIXME: commenting these out to see if they fix the duplicate dependency issue when building bayes3d
              allowUnfree = true;
              # Only enable CUDA on Linux
              cudaSupport = (system == "x86_64-linux" || system == "aarch64-linux");
            };
            overlays = [
              (_final: _prev: {
                # FIXME: say why this was added.
                inherit (inputs.nixpkgs-llvm-10.legacyPackages.${system}) llvmPackages_10;
              })
            ];
          };

          inherit packages;

          checks = packages // {
            devshellPython = self'.devShells.default;
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
