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

  kubernetes.k3s = {
    enable = true;
    clusterInit = true;
    disableComponents = [ "traefik" ];
    extraFlags = [
      "--write-kubeconfig-mode=0644"
    ];
  };

  networking.firewall.enable = false;
}
