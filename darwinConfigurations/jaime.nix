{
  pkgs,
  user,
  hostname,
  inputs,
  customVimPlugins,
  ...
}:
{

  imports = [
    ./profiles/common.nix
  ];

  homebrew.brewPrefix = "/opt/workbrew/bin";

  #homebrew.brews = [
  #  "create-dmg"
  #];
}
