{
  description = "Nix utilities and cross-repo build artifacts for OpenGen";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs?ref=d8724afca4565614164dd81345f6137c4c6eab21";
    nixpkgs-llvm-10.url = "github:NixOS/nixpkgs?rev=222c1940fafeda4dea161858ffe6ebfc853d3db5";

    # This is a private dependency and requires Nix's ~/.config/nix/nix.conf
    # to include something like:
    #
    #   access-tokens = github.com=gh_<your-token>
    #
    genjax.url = "github:probcomp/genjax?ref=v0.1.1";
    genjax.flake = false;
  };

  nixConfig = {
    # Currently configured with numtide's binary cache.
    extra-substituters = [ "https://numtide.cachix.org" ];
    extra-trusted-public-keys = [ "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=" ];

    # Needed for __noChroot impure builds.
    sandbox = "relaxed";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # List of architectures we support
      systems = [
        "x86_64-linux" # fully supported
        "aarch64-darwin" # partially supported
        "x86_64-darwin" # partially supported
        # "aarch64-linux" # not supported yet
      ];

      # This flake is composed with the following files:
      imports = [
        ./parts/devshell.nix
        ./parts/formatter.nix
        ./parts/lib.nix
        ./parts/packages.nix
        ./parts/python.nix
      ];

      perSystem =
        { pkgs, system, ... }:
        {
          # Configure our instance of nixpkgs.
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              # Build with unfree packages.
              allowUnfree = true;
              # Only enable CUDA on Linux.
              cudaSupport = (system == "x86_64-linux" || system == "aarch64-linux");
            };
            # Patches for nixpkgs (see below)
            overlays = [ inputs.self.overlays.default ];
          };
        };

      # This function describe changes to apply to nixpkgs that we need.
      flake.overlays.default = _final: prev: {
        # This was added due to llvmPackages_10 requirement by Open3d
        # and it having been removed from Nixpkgs.
        inherit (inputs.nixpkgs-llvm-10.legacyPackages.${prev.system}) llvmPackages_10;

        # Patches to the python declaration.
        pythonPackagesExtensions = [
          # Changes to python that we need.
          (import ./python-overrides.nix { inherit inputs; })
          # Add our own python packages.
          (import ./python-packages.nix)
        ];
      };
    };
}
