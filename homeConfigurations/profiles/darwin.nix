{ sshKey
, username
, email
, fullname
}:
{ pkgs, lib, config, ... }: {

  imports = [ (import ./common.nix {inherit sshKey username email fullname;}) ];

  home.homeDirectory = "/Users/${username}";

  # darwin specific packages
  home.packages = with pkgs; [
  ];
 
  programs.zsh.initExtra = ''
    export FLOX_AUTOUPDATE=2
    eval "$(flox activate -e flox/prerelease)"
    export FLOX_AUTOUPDATE=0
  '';

  programs.kitty.enable = true;
  programs.kitty.font.name = "Fira Code Light";
  programs.kitty.font.size = 10;
  programs.kitty.settings.open_url_with = "chromium";
  programs.kitty.settings.copy_on_select = "clipboard";
  programs.kitty.settings.tab_bar_edge = "top";
  programs.kitty.settings.enable_audio_bell = "no";
  programs.kitty.theme = "Nord";
}
