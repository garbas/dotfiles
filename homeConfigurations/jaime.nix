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

  xdg.configFile."git/config-flox".text = ''
    [user]
      name = ${user.fullname}
      email = rok@flox.dev
  '';
  programs.git.includes = [
    {
      path = "~/.config/git/config-flox";
      condition = "hasconfig:remote.*.url:git@github.com\:flox/**";
    }
    {
      path = "~/.config/git/config-flox";
      condition = "hasconfig:remote.*.url:git@github.com\:flox-examples/**";
    }
  ];

  programs.ssh.matchBlocks."cercei" = {
    hostname = "192.168.64.3";
    user = user.username;
    port = 22;
  };

  programs.kitty.settings.open_url_with = "/Applications/Firefox.app/Contents/MacOS/firefox";

}
