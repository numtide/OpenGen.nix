{ self, inputs, ... }:
{
  perSystem =
    { self', pkgs, ... }:
    {
      packages = {
        oci-base = pkgs.callPackage ../oci/base {
          inherit (inputs) nixpkgs;
          opengen = self;
        };

        oci-gensql-loom = pkgs.callPackage ../oci/gensql.loom {
          inherit (inputs) nixpkgs;
          opengen = self;
        };

        oci-gensql-query = pkgs.callPackage ../oci/gensql.query {
          inherit (inputs) gensqlquery;
          opengen = self;
        };
      };
    };
}
