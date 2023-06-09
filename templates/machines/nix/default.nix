{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.flake-root.flakeModule

    ./checks.nix
    ./formatter.nix
    ./shell.nix
  ];
}
