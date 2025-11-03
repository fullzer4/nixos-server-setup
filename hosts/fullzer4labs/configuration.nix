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
      "--tls-san=10.100.0.1"
      "--tls-san=38.224.145.102"
    ];
  };

  services.wireguard-server = {
    enable = true;
    serverAddress = "10.100.0.1/24";
    listenPort = 51820;
    serverPrivateKeyFile = "/etc/wireguard/private.key";
    
    peers = [
      {
        # fullzer4's desktop
        publicKey = "Gh8Av+Iy4QyBW1O//YKUxdZLeQnyA7DP6o6LvbZtbSU=";
        allowedIPs = [ "10.100.0.2/32" ];
        persistentKeepalive = 25;
      }
    ];
  };

  networking.firewall.enable = false;
}

