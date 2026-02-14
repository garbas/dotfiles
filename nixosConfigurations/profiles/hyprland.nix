{
  config,
  lib,
  pkgs,
  user,
  ...
}:

let
  hyprlandRun = pkgs.writeShellScript "hyprland-run" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=Hyprland
    export XDG_CURRENT_DESKTOP=Hyprland

    systemd-run --user --scope --collect --quiet \
      --unit=hyprland \
      systemd-cat --identifier=hyprland \
      ${pkgs.hyprland}/bin/Hyprland "$@"
  '';
in
{
  imports = [
    ./console.nix
  ];

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    ghostty
    wofi
    wl-clipboard
  ];

  services.greetd = {
    enable = true;
    restart = false;
    settings = {
      default_session = {
        command = "${
          lib.makeBinPath [ pkgs.tuigreet ]
        }/tuigreet --time --cmd ${hyprlandRun}";
        user = "greeter";
      };
      initial_session = {
        command = "${hyprlandRun}";
        user = user.username;
      };
    };
  };

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.wireplumber.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  programs.light.enable = true;

  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.defaultFonts.monospace = [
    "Fira Code Light"
  ];
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    font-awesome
  ];
}
