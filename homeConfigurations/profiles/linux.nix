{ pkgs, lib, config, user, ... }: {

  imports = [
    (import ./common.nix)
  ];

  home.homeDirectory = "/home/${user.username}";

  home.packages = with pkgs; [
    _1password
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-15.5.2"
  ];

}
