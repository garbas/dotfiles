{ config, pkgs, ... }:
{

  boot.earlyVconsoleSetup = true;

  i18n.consoleFont = "Lat2-Terminus16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.package = pkgs.nixUnstable;
  nix.useSandbox = true;
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
    auto-optimise-store = true
  '';

  environment.systemPackages = with pkgs; [
    neovim
    gitAndTools.git
    gitAndTools.tig
    htop
  ];

}
