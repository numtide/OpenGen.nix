{
  fetchFromGitHub,
  buildBazelPackage,
  bazel,
}:
let
  src = fetchFromGitHub {
    owner = "google";
    repo = "tcmalloc";
    rev = "6722fbb0dd5dc735989ea0a1b5a4549c8cb062ad";
    hash = "sha256-TH3oVxJMd1kQ3yGsPXNJxIYIebMn0cjKAfLkKsTn2ZI=";
  };
in
buildBazelPackage {
  inherit src;
  pname = "tcmalloc";
  # No tags published for this repo
  version = builtins.substring 0 8 src.rev;

  bazel = bazel;

  preConfigure = ''
    mkdir -p /build/output/external
  '';

  fetchAttrs = {
    sha256 = "sha256-CJBwjdCqzAkD0atktPslyPF4Ez6reWYJEeyb+/UQIB0=";
  };

  buildAttrs = {
    dontUseCmakeConfigure = true;

    installPhase = ''
      echo "installing..."
      ls -alspH bazel-bin/*

      mkdir -p $out/lib/tcmalloc
      install -v -Dm0755 bazel-bin/tcmalloc/*.lo $out/lib/tcmalloc/
    '';
    #ls -alspH bazel-bin/tcmalloc
  };

  removeRulesCC = false;
  #removeLocalConfigCc = false;
  #removeLocal = false;

  bazelTargets = [ "//tcmalloc:tcmalloc" ];

  dontAddBazelOpts = true;
  dontAddPrefix = true;
}
