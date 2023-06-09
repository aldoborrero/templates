{
  description = "How to flash a Nixos USB image the Nix way!";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # packages
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ethereum-nix = {
      url = github:nix-community/ethereum.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-parts
    flake-parts = {
      url = github:hercules-ci/flake-parts;
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # flake-parts modules
    flake-root.url = github:srid/flake-root;

    # nix utilities
    nixos-generators = {
      url = github:nix-community/nixos-generators;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    disko = {
      url = github:nix-community/disko;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";

    # other utils
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    home-manager,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib.extend (final: _: import ./nix/lib final) // home-manager.lib;
  in
    (flake-parts.lib.evalFlakeModule
      {
        inherit inputs;
        specialArgs = {
          inherit lib; # make custom lib available to parent functions
        };
      }
      {
        debug = false;
        imports = [
          {
            perSystem = _: {
              _module.args.lib = lib; # make custom lib available to all `perSystem` functions
            };
          }
          ./nix
          ./nixos
        ];
        systems = ["x86_64-linux"];
      })
    .config
    .flake;
}
