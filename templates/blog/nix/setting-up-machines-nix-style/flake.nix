{
  description = "How to flash a Nixos USB image the Nix way!";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # packages
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    ethereum-nix = {
      url = github:nix-community/ethereum.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-parts
    flake-parts = {
      url = github:hercules-ci/flake-parts;
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root.url = github:srid/flake-root;
    mission-control.url = github:Platonic-Systems/mission-control;

    # utilities
    nixos-generators = {
      url = github:nix-community/nixos-generators;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = github:numtide/treefmt-nix;
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    disko = {
      url = github:nix-community/disko;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs @ {
    flake-parts,
    flake-root,
    mission-control,
    nixpkgs,
    treefmt-nix,
    ...
  }: let
    # Use our custom lib enhanced with nixpkgs and hm one
    lib = import ./nix/lib {lib = nixpkgs.lib;} // nixpkgs.lib;
  in
    (flake-parts.lib.evalFlakeModule
      {
        inherit inputs;
        specialArgs = {inherit lib;};
      }
      {
        debug = true;
        imports = [
          treefmt-nix.flakeModule
          flake-root.flakeModule
          mission-control.flakeModule
          ./nix
          ./nixos
        ];
        systems = ["x86_64-linux"];
        perSystem = {inputs', ...}: {
          # make pkgs available to all `perSystem` functions
          _module.args.pkgs = inputs'.nixpkgs.legacyPackages;
          # make custom lib available to all `perSystem` functions
          _module.args.lib = lib;
        };
      })
    .config
    .flake;
}
