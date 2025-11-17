{
  config,
  pkgs,
  lib,
  user,
  hostname,
  inputs,
  customVimPlugins,
  ...
}:
{
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/virtualisation/amazon-image.nix"
    inputs.home-manager.nixosModules.home-manager
    ./profiles/console.nix
  ];

  ec2.hvm = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit
      user
      inputs
      hostname
      customVimPlugins
      ;
  };
  home-manager.users.${user.username} = import ./../homeConfigurations/profiles/linux.nix;
}
