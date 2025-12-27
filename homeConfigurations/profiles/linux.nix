{ user, pkgs, ... }:
{

  imports = [
    ./common.nix
  ];

  home.homeDirectory = "/home/${user.username}";

  home.packages = with pkgs; [
    ghostty
  ];
}
