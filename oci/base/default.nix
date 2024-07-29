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

  baseImg = pkgs.dockerTools.buildLayeredImage {
    name = "probcomp/nix-base";
    tag = systemWithLinux;
    contents =
      (opengen.lib.basicTools crossPkgsLinux)
      ++ (with crossPkgsLinux; [
        bashInteractive
        busybox # NOTE: might be unnecessary
      ]);
    config = {
      Cmd = [ "${crossPkgsLinux.bashInteractive}/bin/bash" ];
    };
  };
in
baseImg
