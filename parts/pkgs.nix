{ self, inputs, ... }:
{
  perSystem =
    {
      self',
      pkgs,
      ...
    }:
    {
      packages = rec {
        baseOCI = pkgs.callPackage ../pkgs/ociBase {
          inherit (inputs) nixpkgs;
          basicTools = self.lib.basicTools;
        };

        loomOCI = pkgs.dockerTools.buildLayeredImage {
          name = "probcomp/loom";
          contents = [
            self'.packages.python.pkgs.loom
            pkgs.bashInteractive
          ] ++ (self.lib.basicTools pkgs);
        };
      };

      checks = pkgs.lib.mapAttrs' (name: value: {
        name = "pkg-${name}";
        inherit value;
      }) self'.packages;
    };
}
