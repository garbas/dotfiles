{ user, pkgs, ... }:
{

  imports = [
    (import ./common.nix)
  ];

  home.homeDirectory = "/Users/${user.username}";

  # darwin specific packages
  home.packages = with pkgs; [
    tart
    ghostty-bin
    pngpaste

  ];

  programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    eval "$(flox activate -d ~ -m run)"
  '';
}
