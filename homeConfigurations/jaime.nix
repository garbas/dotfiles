{ user, ... }:
{

  imports = [
    (import ./profiles/darwin.nix)
  ];

  home.sessionVariables = {
    HOMEBREW_NO_ANALYTICS = "1";  # https://docs.brew.sh/Analytics
  };

  programs.zsh.initExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  programs.ssh.matchBlocks."cercei" = {
    hostname = "192.168.64.3";
    user = user.username;
    port = 22;
  };

}
