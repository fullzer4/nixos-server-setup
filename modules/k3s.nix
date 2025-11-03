{ config, pkgs, lib, ... }:

{
  options = {
    kubernetes.k3s = {
      enable = lib.mkEnableOption "K3s Kubernetes cluster";

      clusterInit = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Initialize cluster with embedded etcd (HA mode)";
      };

      disableComponents = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "traefik" ];
        example = [ "traefik" "servicelb" "local-storage" ];
        description = "List of K3s components to disable";
      };

      extraFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "--cluster-cidr=10.42.0.0/16" "--service-cidr=10.43.0.0/16" ];
        description = "Additional flags to pass to K3s";
      };
    };
  };

  config = lib.mkIf config.kubernetes.k3s.enable {
    services.k3s = {
      enable = true;
      role = "server";
      
      clusterInit = config.kubernetes.k3s.clusterInit;

      extraFlags = lib.concatStringsSep " " (
        (map (component: "--disable ${component}") config.kubernetes.k3s.disableComponents)
        ++ config.kubernetes.k3s.extraFlags
      );
    };

    environment.systemPackages = with pkgs; [
      k3s
      kubectl
      kubernetes-helm
    ];

    networking.firewall = {
      allowedTCPPorts = [
        6443
        10250
      ];
      allowedUDPPorts = [
        8472
      ];
    };

    systemd.tmpfiles.rules = [
      "z /etc/rancher/k3s/k3s.yaml 0640 root wheel -"
    ];

    systemd.services.k3s = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
