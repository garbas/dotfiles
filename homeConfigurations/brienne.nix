{ user, ... }:
{

  imports = [
    (import ./profiles/darwin.nix)
  ];

  home.sessionVariables = {
    HOMEBREW_NO_ANALYTICS = "1"; # https://docs.brew.sh/Analytics
  };

  programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

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
