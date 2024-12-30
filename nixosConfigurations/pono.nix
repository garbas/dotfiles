inputs:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
    inputs.home-manager.nixosModules.home-manager
    (import ./profiles/console.nix inputs)
  ];

  ec2.hvm = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.rok = import ./../homeConfigurations/pono.nix;
}
