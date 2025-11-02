# NixOS Server Setup

NixOS server configurations using Flakes with automatic updates from GitHub.

## Features

- Declarative server configurations
- Auto-update from GitHub main branch (every 30 minutes)
- Datadog monitoring integration
- Network Performance Monitoring (NPM)
- Process monitoring
- K3s Kubernetes cluster (single-node)
- Modular and reusable setup

## Hosts

- `fullzer4labs` - Development server

## Quick Setup for New Host

### 1. Create Datadog API Key File

```bash
echo "YOUR_API_KEY" | sudo tee /etc/datadog-agent-api-key
sudo chown datadog:datadog /etc/datadog-agent-api-key
sudo chmod 400 /etc/datadog-agent-api-key
```

### 2. Apply Configuration from GitHub

```bash
sudo nixos-rebuild switch --flake github:fullzer4/nixos-server-setup#HOSTNAME --no-write-lock-file --refresh
```

Replace `HOSTNAME` with your server name (e.g., `fullzer4labs`).

## Adding a New Server

1. **Copy hardware configuration:**

```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/
```

2. **Create host directory:**

```bash
mkdir -p hosts/NEW_SERVER_NAME
mv ~/hardware-configuration.nix hosts/NEW_SERVER_NAME/
```

3. **Create configuration file** `hosts/NEW_SERVER_NAME/configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  networking.hostName = "NEW_SERVER_NAME";

  monitoring.datadog = {
    enable = true;
    hostname = "NEW_SERVER_NAME";
    environment = "production";  # or "dev", "staging"
    logLevel = "INFO";
    enableLiveProcessCollection = true;
    enableProcessAgent = true;
    enableNetworkMonitoring = true;
  };

  networking.firewall.enable = true;
}
```

4. **Add to** `flake.nix`:

```nix
nixosConfigurations = {
  NEW_SERVER_NAME = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./modules/common.nix
      ./modules/monitoring.nix
      ./modules/auto-update.nix
      ./hosts/NEW_SERVER_NAME/configuration.nix
      ./hosts/NEW_SERVER_NAME/hardware-configuration.nix
    ];
  };
};
```

5. **Commit and push:**

```bash
git add .
git commit -m "feat: add NEW_SERVER_NAME configuration"
git push
```

6. **Apply on the server:**

```bash
sudo nixos-rebuild switch --flake github:fullzer4/nixos-server-setup#NEW_SERVER_NAME --no-write-lock-file --refresh
```

## Useful Commands

### Force Update Now

```bash
sudo systemctl start nixos-upgrade.service
```

### Check Auto-Update Schedule

```bash
sudo systemctl list-timers nixos-upgrade
```

### View Update Logs

```bash
sudo journalctl -u nixos-upgrade.service -f
```

### Check Datadog Agent Status

```bash
sudo systemctl status datadog-agent
sudo datadog-agent status
```

### View Datadog Logs

```bash
sudo journalctl -u datadog-agent -f
```

### K3s Kubernetes Commands

```bash
# Check K3s status
sudo systemctl status k3s

# View K3s logs
sudo journalctl -u k3s -f

# Access cluster with kubectl
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes
kubectl get pods -A

# Or use k3s kubectl directly
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A
```
