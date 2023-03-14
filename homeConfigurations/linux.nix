{ sshKey
, username
, email
, fullname
}:
{ pkgs, lib, config, ... }: {

  imports = [ (import ./common.nix {inherit sshKey username email fullname;}) ];

  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    _1password
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-15.5.2"
  ];

}
