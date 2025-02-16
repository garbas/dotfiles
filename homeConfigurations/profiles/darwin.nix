{ user, ... }:
{

  imports = [
    (import ./common.nix)
  ];

  home.homeDirectory = "/Users/${user.username}";

  # darwin specific packages
  home.packages = [ ];

  programs.zsh.initExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    eval "$(flox activate -d ~ -m run)"
  '';
}
