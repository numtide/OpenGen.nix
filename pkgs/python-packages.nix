inputs: {
  perSystem = { pkgs, ... }:
  let
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

    # For fixing existing packages that live in nixpkgs
    pythonOverrides = import ./python-overrides.nix { inherit inputs; };
  in
  {
    legacyPackages.python3Packages =
      (pkgs.python311Packages.overrideScope pythonOverrides).overrideScope
      (final: _prev: loadPackages final.callPackage ./python-modules);
  };
}
