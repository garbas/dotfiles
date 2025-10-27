{ user, ... }:
{

  imports = [
    ./common.nix
  ];

  home.homeDirectory = "/home/${user.username}";

  #home.packages = [
  #  # For now Ghostty only works on Linux
  #  # See https://github.com/ghostty-org/ghostty/discussions/2824
  #  inputs.ghostty.packages.${pkgs.system}.default
  #];
}
