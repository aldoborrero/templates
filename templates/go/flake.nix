{
  description = "Project / A Nix Flake template for a generic project";

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
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # go
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # utilities
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lib-extras = {
      url = "github:aldoborrero/lib-extras";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib.extend (l: _: (inputs.lib-extras.lib l));
  in
    flake-parts.lib.mkFlake
    {
      inherit inputs;
      specialArgs = {inherit lib;};
    }
    {
      imports = [
        inputs.devshell.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.treefmt-nix.flakeModule
      ];

      debug = false;

      systems = import inputs.systems;

      perSystem = {
        pkgs,
        lib,
        system,
        self',
        ...
      }: {
        # nixpkgs
        _module.args = {
          pkgs = lib.nix.mkNixpkgs {
            inherit system;
            inherit (inputs) nixpkgs;
            overlays = [
              inputs.gomod2nix.overlays.default
            ];
          };
        };

        # packages
        packages = {
          mdformat = with pkgs.python312Packages;
            mdformat.withPlugins [
              mdformat-footnote
              mdformat-frontmatter
              mdformat-gfm
              mdformat-simple-breaks
            ];

          go-project = pkgs.callPackage ./package.nix {};
        };

        # devshells
        devshells.default = {
          name = "go-project";
          packages = with pkgs; [
            go
            gotools
            delve
            golangci-lint
          ];
          commands = [
            {
              name = "fmt";
              category = "nix";
              help = "format the source tree";
              command = ''nix fmt'';
            }
            {
              name = "check";
              category = "nix";
              help = "check the source tree";
              command = ''nix flake check'';
            }
          ];
        };

        # treefmt
        treefmt.config = {
          flakeCheck = true;
          flakeFormatter = true;
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            deno.enable = true;
            mdformat.enable = true;
            shfmt.enable = true;
            rustfmt.enable = true;
          };
          settings.formatter = {
            deno.excludes = ["*.md"];
            mdformat.command = lib.mkDefault self'.packages.mdformat;
          };
        };
      };
    };
}
