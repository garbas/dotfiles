{ config, pkgs, lib, user, ... }:
{

  environment.systemPackages = with pkgs; [
    kitty.terminfo
    termite.terminfo
    foot.terminfo
  ];

  documentation.info.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  networking.extraHosts = ''
    116.203.16.150 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';

  nix.package = pkgs.nixVersions.stable;
  nix.settings.sandbox = true;
  nix.settings.trusted-users = ["@wheel" "${user.username}"];
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
  users.users."root".hashedPassword = user.hashedPassword;
  users.users.${user.username} = {
    hashedPassword = user.hashedPassword;
    isNormalUser = true;
    uid = 1000;
    description = user.fullname;
    extraGroups = [ "audio" "wheel" "vboxusers" "networkmanager" "docker" "libvirtd" ] ;
    group = "users";
    createHome = true;
    home = "/home/${user.username}";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys =
      builtins.map
        (machine: user.machines.${machine}.sshKey + " ${user.username}@${machine}")
        (builtins.attrNames user.machines);
  };
}
