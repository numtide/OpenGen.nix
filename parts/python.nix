{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      # We use python 3.11
      python = pkgs.python311;

      # Get the list of python packages from the folder structure
      pythonPackages = builtins.attrNames (builtins.readDir ../python-packages);
    in
    {
      packages =
        {
          inherit python;
        }
        # Expose all the python modules as packages directly
        // (pkgs.lib.genAttrs pythonPackages (name: python.pkgs.${name}));
    };
}
