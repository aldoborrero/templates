{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      package = pkgs.treefmt;

      programs = {
        alejandra.enable = true;
        prettier.enable = true;
        shfmt.enable = true;
      };
    };

    formatter = config.treefmt.build.wrapper;
  };
}
