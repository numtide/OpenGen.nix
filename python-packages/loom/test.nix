{
  runCommand,
  python3,
  loom,
  src,
  which,
}:
runCommand "loom-test"
  {
    nativeBuildInputs = [
      python3
      loom
      which
    ];
  }
  ''
    cp -r ${src} source
    mkdir $out

    cd source/examples/taxi
    LOOM_STORE=$out python -m loom.tasks ingest quickstart schema.json example.csv
  ''
