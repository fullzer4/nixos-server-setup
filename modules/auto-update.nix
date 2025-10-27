{ config, pkgs, lib, ... }:

{
  system.autoUpgrade = {
    enable = true;
    flake = "github:fullzer4/nixos-server-setup#${config.networking.hostName}";
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
    ];
    dates = "daily";
    allowReboot = false;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
