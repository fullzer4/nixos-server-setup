{ config, pkgs, lib, ... }:

{
  networking.hostName = "fullzer4labs";

  monitoring.datadog = {
    enable = true;
    hostname = "fullzer4labs";
    environment = "dev";
    logLevel = "INFO";
    enableLiveProcessCollection = true;
    enableProcessAgent = true;
    enableNetworkMonitoring = true;
  };

  networking.firewall.enable = false;
}
