{ config, pkgs, lib, ... }:

{
  networking.hostName = "fullzer4labs";

  monitoring.datadog = {
    enable = true;
    hostname = "fullzer4labs";
    environment = "dev";
  };

  networking.firewall.enable = false;
}
