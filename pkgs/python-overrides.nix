{ inputs }: final: _prev: {
  # so we can pull from flake inputs
  inherit inputs;

  # Use the pre-built version of tensorflow
  tensorflow =
    if final.tensorflow-bin.meta.broken then final.tensorflow-build else final.tensorflow-bin;

  # Use the pre-built version of jaxlib
  jaxlib = if final.jaxlib-bin.meta.broken then final.jaxlib-build else final.jaxlib-bin;
}
