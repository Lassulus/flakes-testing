{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = [
    pkgs.vim
  ];

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keyFiles = lib.singleton (builtins.fetchurl "http://lassul.us/ssh.pub");
}
