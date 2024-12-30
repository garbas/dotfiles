{ user, ... }:
{

  imports = [
    (import ./profiles/darwin.nix)
  ];

  home.sessionVariables = {
    HOMEBREW_NO_ANALYTICS = "1"; # https://docs.brew.sh/Analytics
  };

  programs.zsh.initExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  programs.kitty.settings.open_url_with = "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome";

  xdg.configFile."git/config-bitstamp".text = ''
    [user]
      name = ${user.fullname}
      email = rok.garbas@bitstamp.net
  '';
  programs.git.includes = [
    {
      path = "~/.config/git/config-bitstamp";
      condition = "hasconfig:remote.*.url:ssh://git@bitbts.bitstamp.net:7999/**";
    }
  ];

}
