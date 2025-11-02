{ config, pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = lib.mkDefault "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.fullzer4 = {
    isNormalUser = true;
    description = "fullzer4";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCavtjByfE8sq1QjSrWGDr3CXV5l+auae6MMqGu8/qlZHj+w5HxN8IOgQQZf1WB+lIfNCgjyY2vJKtlMxj5jKiiiAdhWZoKKuX2MwmUcWcGD3wqit0UdtkV/PvciMHWCgRzj1miGZ9bjda3hkKtNOC8c1wwHcUJChwxKelMDF9d0uv7SLc9/fK4Yo7ErcFH4dv0pWhyWP224lkczn9rCs+Sb+GdV2VCjTiK7MwniQgv5KI0qhQw41RT0qbfXP3tmZMMOD7iPRBnwN82oDkioLW81/E8z2z/uhw70K+4YV0anFIK73f1o5Jvn4jpwpH8DXzkGktSOEVVDTYsgipneDlk+J2/SvtvzP389zf9gTi6f9TCwBQjWi28hwPxMvXYAU6SHNSA69Z1SfKJ7deUxJwsirUkiGe14syJnWyItyYFP8ReTvqbcU7zMa2s4zcGwY/Viy7M4yxUWb/fLqNI5qzH46PGV9vLQLnO4nnkMHgn9gtyGUasE+tW4gx1HNbEmXHE= gabrielpelizzaro@gmail.com"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    curl
    wget
    tmux
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = lib.mkDefault false;
    };
  };

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  networking.networkmanager.enable = true;
  
  networking.firewall = {
    enable = lib.mkDefault true;
    allowedTCPPorts = [ 22 ];
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  system.stateVersion = "25.05";
}
