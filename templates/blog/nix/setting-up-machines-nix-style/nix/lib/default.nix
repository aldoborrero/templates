{lib, ...} @ args: let
  mkLib = self: let
    importLib = file: import file ({inherit self;} // args);
  in {
    attrs = importLib ./attrs.nix;
    importers = importLib ./importers.nix;

    inherit (self.attrs) mergeAny;
    inherit (self.importers) rakeLeaves flattenTree;
  };
in
  lib.makeExtensible mkLib
