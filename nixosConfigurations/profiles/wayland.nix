inputs:
{ config, lib, pkgs, modulesPath, ... }:

let
  swayRun = pkgs.writeShellScript "sway-run" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=sway
    export XDG_CURRENT_DESKTOP=sway

    systemd-run --user --scope --collect --quiet --unit=sway systemd-cat --identifier=sway ${pkgs.sway}/bin/sway $@
  '';
in {
  imports =
    [ (import ./console.nix inputs)
    ];

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    kitty
    termite
    foot
  ];

  networking.hostName = "cercei";
  networking.hostId = "dae19db5";
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp2s0";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  networking.networkmanager.enable = true;

  services.greetd.enable = true;
  services.greetd.restart = false;
  services.greetd.settings.default_session.command = "${lib.makeBinPath [pkgs.greetd.tuigreet] }/tuigreet --time --cmd ${swayRun}";
  services.greetd.settings.default_session.user = "greeter";
  services.greetd.settings.initial_session.command = "${swayRun}";
  services.greetd.settings.initial_session.user = "rok";

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.wireplumber.enable = true;
  services.pipewire.media-session.enable = false;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

  programs.dconf.enable = true;
  programs.light.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      wofi
      ulauncher

      dmenu-wayland #sway dep
      obs-studio
      pavucontrol #i3status-rust dep
      playerctl #sway dep
      pulseaudio #i3status-rust dep
      sway-contrib.grimshot #sway dep
      swayidle #sway dep
      swaylock #sway dep
      wf-recorder #sway
      wl-clipboard #sway dep
    ];
  };

  fonts.enableGhostscriptFonts = true;
  fonts.fontDir.enable = true;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Fire Code Light" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Source Sans Pro" ];
  fonts.fontconfig.defaultFonts.serif = [ "Source Serif Pro" ];
  fonts.fontconfig.enable = true;
  fonts.fonts = with pkgs; [
    # used for terminal
    fira-code
    fira-code-symbols

    # GTK / other UI
    source-sans-pro
    source-serif-pro

    # Fonts use for icons in i3 and powerlevel10k
    nerdfonts

    # Fonts use for icons in i3status-rs
    font-awesome_5
  ];
}
