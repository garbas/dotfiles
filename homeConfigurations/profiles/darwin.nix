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
  # to activate default flox environment by default
  #  . <(flox activate)
  '';
}
