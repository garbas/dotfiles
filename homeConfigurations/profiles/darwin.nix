{ user, ... }: {

  imports = [
    (import ./common.nix)
  ];

  home.homeDirectory = "/Users/${user.username}";

  # darwin specific packages
  home.packages = [];
 
  # XXX: enable once flox is stable
  #programs.zsh.initExtra = ''
  #  export FLOX_AUTOUPDATE=2
  #  eval "$(flox activate -e flox/prerelease)"
  #  export FLOX_AUTOUPDATE=0
  #'';

  programs.kitty.enable = true;
  programs.kitty.font.name = "Fira Code Light";
  programs.kitty.font.size = 12;
  programs.kitty.keybindings = {
    #"cmd+c" = "copy_to_clipboard";
    "cmd+c" = "copy_and_clear_or_interrupt";
    "cmd+v" = "paste_from_clipboard";
  };
  programs.kitty.settings.copy_on_select = "yes";
  programs.kitty.settings.enable_audio_bell = "no";
  programs.kitty.settings.tab_bar_edge = "top";
  programs.kitty.shellIntegration.enableZshIntegration = true;
  programs.kitty.themeFile = "Nord";
}
