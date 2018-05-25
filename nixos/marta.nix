{ config, pkgs, ... }:
{

  imports =
    [ ./family.nix
    ];

  environment.systemPackages = with pkgs; [
    chromium
    firefox
    skype
    libreoffice
    sublime
    shotwell
    neovim
    tdesktop
  ];

  users.mutableUsers = false;
  users.users."marta" = {
    hashedPassword = "$6$7dMLWxcLDtuSYeR$JtD.4LVc3SwB2JZzcjHFllyxtg2hZvoXZ.SJ7SHXaEzJAoFr2t8Sjpmbk3/VNmLNMcIxmOpx.icLy.y5lpSom/";
    isNormalUser = true;
    uid = 1001;
    description = "Marta Rychlewski";
    extraGroups = [ "wheel" "vboxusers" "networkmanager" ] ;
    group = "users";
    home = "/home/marta";
  };

  time.timeZone = "Europe/Berlin";

}
