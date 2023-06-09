lib: let
  attrs = import ./attrs.nix lib;
  importers = import ./importers.nix lib;
in {
  inherit attrs importers;
}
