{ pkgs, basicTools, self }:
let
  callPackage = pkgs.newScope (
    pkgs
    // {
      inherit callPackage;
      basicTools = basicTools pkgs;
    }
    // self.packages
  );

  callPy3Package = pkgs.newScope (
    pkgs
    // pkgs.python3Packages
    // {
      inherit callPackage;
      basicTools = basicTools pkgs;
    }
    // self.packages
  );
in
{
  inherit
    callPackage
    callPy3Package
    ;
}
