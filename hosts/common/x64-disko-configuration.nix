{
  disko.devices = {
    disk = {
      nixos = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "mbr"; # MS-DOS partition table
          partitions = {
            swap = {
              size = "512MiB";
              type = "82"; # Linux swap
              content = {
                type = "swap";
              };
            };
            root = {
              size = "100%";
              bootable = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
