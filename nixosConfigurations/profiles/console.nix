inputs:
{ config, pkgs, lib, ... }:
{

  documentation.info.enable = true;

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
  programs.zsh.enable = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.locate.enable = true;
  services.openssh.enable = true;

  time.timeZone = "Europe/Ljubljana";

  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = false;
  users.users."root" = {
    hashedPassword = "$6$sBFfflUBZtZMD$h.EWNsmmX8iwTM7jShIvYwvS2/h7dncGTNhG.yPN1dOte1Et0TTz7HSFmzkuWjQpnBAfANYdptF3EQoUNSYwx/";
  };
  users.users."rok" = {
    hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [ "audio" "wheel" "vboxusers" "networkmanager" "docker" "libvirtd" ] ;
    group = "users";
    createHome = true;
    home = "/home/rok";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZr0HtRTIngjPGi4yliL4vffUYxx1OMCcfHcecAhgO5 rok@cercei"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKex8HTaW5y1IrhxVKU4r9XfLNWl6kvzpBF74VXovfPu rok@jaime"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/UvlzfVRvsI8bvy/PE2CTGErPUSRzsCLebGb6Ytc78 rok@tyrion"
    ];
  };
}

