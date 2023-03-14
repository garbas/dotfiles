{ sshKey
, username
, email
, fullname
}:
{ pkgs, lib, config, ... }: {

  imports = [ (import ./common.nix {inherit sshKey username email fullname;}) ];

  home.homeDirectory = "/Users/${username}";

  home.packages = with pkgs; [
  ];
 
  programs.ssh.matchBlocks."cercei" = {
    hostname = "192.168.64.3";
    user = "rok";
    port = 22;
  };

  programs.zsh.initExtra = ''
    source "$(dirname $(realpath $(which nix)))/../etc/profile.d/nix.sh"
    . <(flox activate)
  '';
}
