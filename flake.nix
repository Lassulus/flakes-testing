{
  inputs.nixpkgs.url = github:NixOS/nixpkgs;
  inputs.disko.url = github:nix-community/disko;

  outputs = { self, nixpkgs, disko, ... }@attrs: {
    nixosConfigurations.fnord = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix
        disko.nixosModules.disko
        {
          disko.devices = import ./disk-config.nix {};
        }
      ];
    };
    diskoConfigurations.fnord = import ./disk-config.nix;
  };
}
