{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.disko.url = "github:nix-community/disko/make-disk-image";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-anywhere.url = "github:numtide/nixos-anywhere";
  inputs.nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, disko, nixos-anywhere, ... }@attrs: {
    packages."x86_64-linux".makeDiskImageTest = disko.lib.lib.makeDiskImage {
      nixosConfig = self.nixosConfigurations.reliablesite;
    };
    packages."x86_64-linux".makeDiskScriptTest = disko.lib.lib.makeDiskImageScript {
      nixosConfig = self.nixosConfigurations.reliablesite;
    };
    nixosConfigurations.fnord = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configs/universal_dhcp.nix
        disko.nixosModules.disko
        ./disk-config.nix
        {
          _module.args.disks = [ "/dev/sda" ];
          boot.loader.grub = {
            efiSupport = true;
            efiInstallAsRemovable = true;
          };

          environment.systemPackages = [
            nixos-anywhere.packages.x86_64-linux.nixos-anywhere
          ];
        }
      ];
    };
    diskoConfigurations.fnord = import ./disk-config.nix;
    nixosConfigurations.hetzner-cloud-aarch64 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = attrs;
      modules = [
        ./configs/universal_dhcp.nix
        disko.nixosModules.disko
        ./disk-config.nix
        {
          _module.args.disks = [ "/dev/sda" ];
          boot.loader.efi.canTouchEfiVariables = true;
          boot.loader.systemd-boot.enable = true;
          # boot.loader.grub = {
          #   devices = [ "/dev/sda" ];
          #   efiSupport = true;
          #   # efiInstallAsRemovable = true;
          # };
        }
      ];
    };
    nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configs/universal_dhcp.nix
        disko.nixosModules.disko
        ./disk-config.nix
        {
          _module.args.disks = [ "/dev/sda" ];
          boot.loader.grub = {
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
        ./disk-config.nix
        {
          _module.args.disks = [
            "/dev/nvme0n1"
            "/dev/nvme1n1"
          ];
          boot.loader.grub = {
            enable = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
          };
        }
      ];
    };
  };
}
