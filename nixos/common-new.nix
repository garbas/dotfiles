{ config, pkgs, lib, ... }:
let
  nixosVersion = "17.03";
in {

  systemd.services."systemd-vconsole-setup".serviceConfig.ExecStart =
    lib.mkForce
      [ ""
        "${pkgs.systemd}/lib/systemd/systemd-vconsole-setup /dev/tty3"
      ];

  i18n.consoleFont = "Lat2-Terminus16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.package = pkgs.nixUnstable;
  nix.useSandbox = true;
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
    auto-optimise-store = true
  '';

  system.stateVersion = nixosVersion;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-${nixosVersion}";
  system.autoUpgrade.flags = lib.mkForce
    [ "--no-build-output"
      "-I" "nixpkgs=/etc/nixos/nixpkgs-channels"
    ];
  systemd.services.nixos-upgrade.path = [ pkgs.git ];
  systemd.services.nixos-upgrade.preStart = ''
    if [ ! -e /etc/nixos/nixpkgs-channels ]; then
      cd /etc/nixos
      git clone git://github.com/NixOS/nixpkgs-channels.git -b nixos-17.03
    fi
    cd /etc/nixos/nixpkgs-channels
    git pull
    if [ -e /etc/nixos/dotfiles ]; then
      cd /etc/nixos/dotfiles
      git pull
    fi
  '';

  environment.variables.NIX_PATH = lib.mkForce "nixpkgs=/etc/nixos/nixpkgs-channels:nixos-config=/etc/nixos/configuration.nix";
  environment.variables.GIT_EDITOR = lib.mkForce "nvim";
  environment.variables.EDITOR = lib.mkForce "nvim";

  environment.systemPackages = with pkgs; [
    neovim
    gitAndTools.git
    gitAndTools.tig
    htop
  ];

}
