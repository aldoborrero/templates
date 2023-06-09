{self, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    checks = let
      inherit (inputs'.nixpkgs-unstable.legacyPackages) statix;
    in {
      statix =
        pkgs.runCommand "statix" {
          nativeBuildInputs = [statix];
        } ''
          cp --no-preserve=mode -r ${self} source
          cd source
          HOME=$TMPDIR statix check
          touch $out
        '';
    };
  };
}
