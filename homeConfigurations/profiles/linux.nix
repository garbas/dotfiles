{ pkgs, lib, config, user, ... }: {

  imports = [
    (import ./common.nix)
  ];

  home.packages = [
    # For now Ghostty only works on Linux
    # See https://github.com/ghostty-org/ghostty/discussions/2824
    inputs.ghostty.packages.${pkgs.system}.default;
  ];
}
