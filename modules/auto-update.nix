{ config, pkgs, lib, ... }:

{
  system.autoUpgrade = {
    enable = true;
    flake = "github:fullzer4/nixos-server-setup#${config.networking.hostName}";
    flags = [
      "--no-write-lock-file"
    ];
    dates = "minutely";
    allowReboot = false;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
