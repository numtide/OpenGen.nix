{
  perSystem =
    { pkgs, ... }:
    {
      # Run `nix fmt` to invoke the nix code formatter.
      formatter = pkgs.nixfmt-rfc-style;
    };
}
