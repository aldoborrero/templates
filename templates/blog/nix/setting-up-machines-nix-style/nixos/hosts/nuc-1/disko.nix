{...}: {
  disko.devices = {
    disk.nvme = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            type = "partition";
            start = "1MiB";
            end = "512MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "root";
            type = "partition";
            start = "512MiB";
            end = "100%";
            bootable = true;
            part-type = "primary";
            content = {
              type = "btrfs";
              extraArgs = "-f";
              mountpoint = "/";
              mountOptions = ["discard" "noatime"];
              subvolumes = {
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd"];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
              };
            };
          }
        ];
      };
    };
    disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "data";
            type = "partition";
            start = "1MiB";
            end = "100%";
            content = {
              type = "btrfs";
              extraArgs = "-f";
              mountpoint = "/data";
              mountOptions = ["discard" "noatime"];
              subvolumes = {
                "/ethereum" = {
                  mountpoint = "/ethereum";
                  mountOptions = ["discard" "noatime" "nodatacow"];
                };
              };
            };
          }
        ];
      };
    };
  };
}
