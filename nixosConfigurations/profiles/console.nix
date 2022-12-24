inputs:
{ config, pkgs, lib, ... }:
{

  documentation.info.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  networking.extraHosts = ''
    116.203.16.150 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';

  nix.package = pkgs.nixVersions.stable;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    "nixos-config=/etc/nixos/configuration.nix"
  ];
  nix.settings.sandbox = true;
  nix.settings.trusted-users = ["@wheel" "rok"];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    builders-use-substitutes = true
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-15.5.2"
  ];

  programs.command-not-found.enable = false;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableBrowserSocket = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.mosh.enable = true;
  programs.ssh.forwardX11 = false;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.locate.enable = true;
  services.openssh.enable = true;

  time.timeZone = "Europe/Ljubljana";

  users.defaultUserShell = pkgs.zsh;
}

