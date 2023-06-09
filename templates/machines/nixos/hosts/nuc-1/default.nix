{pkgs, ...}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ./hardware.nix
    ./services
    ./system.nix
    ./users.nix
  ];
}
