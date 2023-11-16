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
    flake-root.url = "github:srid/flake-root";

    # utilities
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lib-extras = {
      url = "github:aldoborrero/lib-extras";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    haumea,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib.extend (l: _: (inputs.lib-extras.lib l));
    localInputs = haumea.lib.load {
      src = ./.;
      loader = haumea.lib.loaders.path;
    };
  in
    flake-parts.lib.mkFlake
    {
      inherit inputs;
      specialArgs = {inherit lib localInputs;};
    }
    {
      imports = [
        inputs.devshell.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      debug = false;

      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        lib,
        config,
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
              (final: _: {
                devour-flake = final.callPackage inputs.devour-flake {};
              })
            ];
          };
        };

        # packages
        packages = {
          mdformat-custom = with pkgs.python311Packages;
            mdformat.withPlugins [
              mdformat-footnote
              mdformat-frontmatter
              mdformat-gfm
              mdformat-simple-breaks
            ];
        };

        # devshells
        devshells.default = {
          name = "python-project";
          packages = with pkgs; [
            python311
            poetry
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
          inherit (config.flake-root) projectRootFile;
          flakeFormatter = true;
          flakeCheck = true;
          programs = {
            alejandra.enable = true;
            black.enable = true;
            deadnix.enable = true;
            deno.enable = true;
            mdformat.enable = true;
            ruff.enable = true;
            shfmt.enable = true;
            terraform.enable = true;
          };
          settings.formatter = {
            deno.excludes = ["*.md"];
            mdformat.command = lib.mkDefault self'.packages.mdformat-custom;
          };
        };

        # checks
        checks = {
          nix-build-all = pkgs.writeShellApplication {
            name = "nix-build-all";
            runtimeInputs = [
              pkgs.nix
              pkgs.devour-flake
            ];
            text = ''
              # Make sure that flake.lock is sync
              nix flake lock --no-update-lock-file

              # Do a full nix build (all outputs)
              devour-flake . "$@"
            '';
          };
        };
      };
    };
}
