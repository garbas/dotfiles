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

  #homebrew.brews = [
  #  "create-dmg"
  #];
}
