{
  self,
  inputs,
  lib,
  ...
}: let
  inherit
    (inputs)
    disko
    ethereum-nix
    flake-registry
    impermanence
    nixos-hardware
    nixpkgs
    ;

  nixosSystem = with lib;
    args:
      (makeOverridable lib.nixosSystem)
      (recursiveUpdate args {
        modules =
          args.modules
          ++ [
            {
              config.nixpkgs.pkgs = mkDefault args.pkgs;
              config.nixpkgs.localSystem = mkDefault args.pkgs.stdenv.hostPlatform;
            }
          ];
        specialArgs = {inherit lib;};
      });

  hosts = lib.rakeLeaves ./hosts;
  modules = lib.rakeLeaves ./modules;

  defaultModules = [
    # make flake inputs accessible in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = inputs;
    }

    # load common modules
    {
      imports = [
        impermanence.nixosModules.impermanence
        disko.nixosModules.disko
        ethereum-nix.nixosModules.default

        modules.i18n
        modules.minimal-docs
        modules.nix
        modules.openssh
        modules.server
        modules.tailscale
      ];
    }
  ];

  pkgs.x86_64-linux = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  imports = [
    ./images
  ];

  flake.nixosConfigurations = {
    nuc-1 = nixosSystem {
      pkgs = pkgs.x86_64-linux;
      modules =
        defaultModules
        ++ [nixos-hardware.nixosModules.intel-nuc-8i7beh]
        ++ [
          modules.serial-console
          modules.tcp-hardening
          modules.tcp-optimizations
          modules.tmpfs
          modules.fs-trim
        ]
        ++ [hosts.nuc-1];
    };
  };
}
