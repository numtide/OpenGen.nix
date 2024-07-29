{
  nixpkgs,
  opengen,
  pkgs,
  system,
}:
let
  # in OCI context, whatever our host platform we want to build same arch but linux
  systemWithLinux = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
  crossPkgsLinux = nixpkgs.legacyPackages.${systemWithLinux};
  python = crossPkgsLinux.python311;

  base = opengen.packages.${system}.oci-base;

  loom = opengen.packages.${systemWithLinux}.loom;
in
pkgs.dockerTools.buildLayeredImage {
  name = "probcomp/gensql.loom";
  tag = systemWithLinux;
  fromImage = base;
  contents = [
    loom
    python
  ];
  config = {
    Cmd = [
      "${python}/bin/python"
      "-m"
      "loom.tasks"
    ];
    Env = [ "LOOM_STORE=/loom/store" ];
  };
}
