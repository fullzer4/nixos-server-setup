{ config, pkgs, lib, ... }:

{
  options = {
    monitoring.datadog = {
      enable = lib.mkEnableOption "Datadog monitoring";
      
      apiKeyFile = lib.mkOption {
        type = lib.types.path;
        default = "/etc/datadog-agent-api-key";
        description = "Path to the Datadog API key file";
      };

      hostname = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
        description = "Hostname to report to Datadog";
      };

      site = lib.mkOption {
        type = lib.types.str;
        default = "us5.datadoghq.com";
        description = "Datadog site";
      };

      environment = lib.mkOption {
        type = lib.types.str;
        default = "production";
        description = "Environment tag (dev, staging, production)";
      };

      extraTags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional tags to add";
      };

      logLevel = lib.mkOption {
        type = lib.types.enum [ "DEBUG" "INFO" "WARN" "ERROR" ];
        default = "INFO";
        description = "Log level for Datadog agent";
      };

      enableLiveProcessCollection = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable live process collection";
      };

      enableProcessAgent = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable process agent to collect running processes";
      };
    };
  };

  config = lib.mkIf config.monitoring.datadog.enable {
    services.datadog-agent = {
      enable = true;
      
      apiKeyFile = config.monitoring.datadog.apiKeyFile;
      site = config.monitoring.datadog.site;
      hostname = config.monitoring.datadog.hostname;
      logLevel = config.monitoring.datadog.logLevel;
      
      tags = [
        "env:${config.monitoring.datadog.environment}"
        "host:${config.monitoring.datadog.hostname}"
        "so:nixos"
      ] ++ config.monitoring.datadog.extraTags;
      
      extraConfig = {
        logs_enabled = true;
        network_config = {
          enabled = true;
        };
      } // lib.optionalAttrs config.monitoring.datadog.enableProcessAgent {
        process_config = {
          enabled = "true";
          process_collection.enabled = "true";
        };
      };
      
      enableLiveProcessCollection = config.monitoring.datadog.enableLiveProcessCollection;
      
      # Enable network check with detailed metrics
      checks.network = {
        init_config = {};
        instances = [{
          collect_connection_state = true;
          collect_rate_metrics = true;
          collect_count_metrics = true;
          excluded_interfaces = [ "lo" "lo0" ];
        }];
      };
    };

    systemd.tmpfiles.rules = [
      "f ${config.monitoring.datadog.apiKeyFile} 0400 datadog datadog - -"
    ];
  };
}
