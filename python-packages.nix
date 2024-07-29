final: _prev:
let
  dir = toString ./python-packages;
  dirEntries = builtins.readDir dir;
in
# Loads all the python packages
builtins.mapAttrs (name: _: final.callPackage "${dir}/${name}" { }) dirEntries
