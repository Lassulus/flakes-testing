{
  inputs.nixpkgs.url = github:NixOS/nixpkgs;
  inputs.disko.url = github:nix-community/disko;

  outputs = { self, nixpkgs, disko, ... }@attrs: {
    nixosConfigurations.fnord = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configs/universal_dhcp.nix
        disko.nixosModules.disko
        {
          disko.devices = import ./disk-config.nix {
            lib = nixpkgs.lib;
          };
          boot.loader.grub = {
            devices = [ "/dev/sda" ];
            efiSupport = true;
            efiInstallAsRemovable = true;
          };
        }
      ];
    };
    nixosConfigurations.reliablesite = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configs/reliablesite.nix
        disko.nixosModules.disko
        {
          disko.devices = import ./disk-config.nix {
            lib = nixpkgs.lib;
            disks = [
              "/dev/nvme0n1"
              "/dev/nvme1n1"
            ];
          };
          boot.loader.grub = {
            devices = [
              "/dev/nvme0n1"
              "/dev/nvme1n1"
            ];
            efiSupport = true;
            efiInstallAsRemovable = true;
          };
        }
      ];
    };
  };
}
