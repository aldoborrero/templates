{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = {
    pkgs,
    config,
    inputs',
    lib,
    ...
  }:
    with lib; let
      inherit (pkgs) writeShellScriptBin;

      inherit (inputs'.ethereum-nix.packages) geth prysm;

      flash-iso-image = name: image: let
        pv = getExe pkgs.pv;
        fzf = getExe pkgs.fzf;
      in
        writeShellScriptBin name ''
          set -euo pipefail

          # Build image
          nix build .#${image}

          # Display fzf disk selector
          iso="./result/iso/"
          iso="$iso$(ls "$iso" | ${pv})"
          dev="/dev/$(lsblk -d -n --output RM,NAME,FSTYPE,SIZE,LABEL,TYPE,VENDOR,UUID | awk '{ if ($1 == 1) { print } }' | ${fzf} | awk '{print $2}')"

          # Format
          ${pv} -tpreb "$iso" | sudo dd bs=4M of="$dev" iflag=fullblock conv=notrunc,noerror oflag=sync
        '';
    in {
      devshells.default = {
        name = "setting-up-machines-nix-style";
        packages = [
          # Add your custom packages
        ];
        commands = [
          # Nix
          # {
          #   category = "Nix";
          #   name = "nix-build-nuc";
          #   help = "Builds toplevel NixOS image for NUC-1 host";
          #   command = writeShellScriptBin "nix-build-nuc" ''
          #     set -euo pipefail
          #     nix build .#nixosConfigurations.nuc-1.config.system.build.toplevel
          #   '';
          # }

          # ISOs
          # {
          #   category = "Images";
          #   name = "flash-nuc-1-iso";
          #   help = "Flash installer-iso image for NUC-1";
          #   command = flash-iso-image "flash-nuc-iso" "nuc-1-iso-image";
          # }

          # Utils
          {
            category = "Utils";
            name = "fmt";
            help = "Format the source tree";
            command = "${lib.getExe config.treefmt.build.wrapper}";
          }

          # {
          #   category = "Utils";
          #   name = "clean";
          #   help = "Cleans any result produced by Nix or associated tools";
          #   command = writeShellScriptBin "clean" "rm -rf result* *.qcow2";
          # }

          {
            category = "Utils";
            name = "run-vm";
            help = "Executes a VM if output derivation contains one";
            command = "exec ./result/bin/run-*-vm";
          }
        ];
      };
    };
}
