{ config, pkgs, lib, ... }:

{
  options = {
    networking.wireguard = {
      enable = lib.mkEnableOption "WireGuard VPN server";

      serverPrivateKeyFile = lib.mkOption {
        type = lib.types.str;
        default = "/etc/wireguard/private.key";
        description = "Path to the server's private key file";
      };

      interface = lib.mkOption {
        type = lib.types.str;
        default = "wg0";
        description = "WireGuard interface name";
      };

      serverAddress = lib.mkOption {
        type = lib.types.str;
        default = "10.100.0.1/24";
        description = "Server VPN IP address with CIDR";
      };

      listenPort = lib.mkOption {
        type = lib.types.int;
        default = 51820;
        description = "UDP port for WireGuard";
      };

      peers = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            publicKey = lib.mkOption {
              type = lib.types.str;
              description = "Client's public key";
            };
            allowedIPs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "List of IPs allowed for this peer";
            };
            persistentKeepalive = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = 25;
              description = "Keepalive interval in seconds";
            };
          };
        });
        default = [];
        description = "List of WireGuard peers";
      };
    };
  };

  config = lib.mkIf config.networking.wireguard.enable {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    networking.wireguard.interfaces.${config.networking.wireguard.interface} = {
      ips = [ config.networking.wireguard.serverAddress ];
      listenPort = config.networking.wireguard.listenPort;
      
      privateKeyFile = config.networking.wireguard.serverPrivateKeyFile;
      
      peers = config.networking.wireguard.peers;
      
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE
      '';
      
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE || true
      '';
    };

    networking.firewall = {
      allowedUDPPorts = [ config.networking.wireguard.listenPort ];
    };

    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
  };
}
