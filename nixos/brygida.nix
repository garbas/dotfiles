{ config, pkgs, ... }:
{

  i18n.defaultLocale = "pl_PL.UTF-8";

  environment.systemPackages = with pkgs; [
    firefox-bin
    skype
    libreoffice
  ];

  services.xserver.layout = "pl";
  services.xserver.xkbOptions = "eurosign:e";

  users.mutableUsers = false;
  users.users."brygida" = {
    hashedPassword = "$6$/2ZfmyYr$QM/jdxYxzv4/JbQ4XoGw2RARUeJwhrGMIgYT4Jww0zOlbyXmalu21RQeu5XuTtsWjBkYtgse5OXt/OPnhe5He/";
    isNormalUser = true;
    uid = 1000;
    description = "Brygida Rychlewski";
    extraGroups = [ "wheel" "networkmanager" "vboxusers" ];
    group = "users";
    home = "/home/brygida";
  };

  time.timeZone = "Europe/Warsaw";
}
