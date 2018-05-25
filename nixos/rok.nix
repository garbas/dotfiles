{ i3_tray_output }:

{ pkgs, config, ... }:

# TODO:
#
# email (need to reconfigure mail stuff)
#  pythonPackages.alot
#  pythonPackages.afew  # set with timer
#  msmtp
#  notmuch
#  isync
#  w3m
#
#xautolocakk
#  http://rabexc.org/posts/awesome-xautolock-battery
#  https://faq.i3wm.org/question/5102/i3lock-how-to-enable-auto-lock-after-wake-up-from-suspend-solved.1.html
#
# to setup
#  https://certbot.eff.org/#pip-nginx
#
# to package
#  https://pypi.python.org/pypi/weetwit
#  http://turses.readthedocs.io/en/latest/user/configuration.html#twitter
#  https://github.com/eliangcs/http-prompt

{

  imports =
    [ ( import ./common.nix { inherit i3_tray_output; }  )
    ];

  environment.etc = pkgs.garbas_config.environment_etc;


  environment.systemPackages = with pkgs;
    garbas_config.system_packages ++
    [

      garbas_config.update_xkbmap
      garbas_config.theme_switch

      termite.terminfo

      xsel # needed for neovim to support copy/paste

      # console applications
      gitAndTools.tig
      gitFull
      gnumake
      htop
      mosh
      neovim
      ngrok
      scrot
      unrar
      unzip
      wget
      which
      tree

      docker_compose
      obs-studio
      pgadmin
      sshuttle
    ];

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    anonymousPro
    #corefonts
    dejavu_fonts
    freefont_ttf
    liberation_ttf
    source-code-pro
    terminus_font
    #ttf_bitstream_vera
    nerdfonts
  ];

  networking.extraHosts = ''
    81.4.127.29 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';

  #programs.xonsh.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.syntaxHighlighting.highlighters = [ "main" "brackets" "cursor" "root" "line" ];
  programs.zsh.enableAutosuggestions = true;

  #security.polkit.extraConfig = ''
  #  polkit.addRule(function(action, subject) {
  #    var YES = polkit.Result.YES;
  #    // NOTE: there must be a comma at the end of each line except for the last:
  #    var permission = {
  #      // required for udisks1:
  #      "org.freedesktop.udisks.filesystem-mount": YES,
  #      "org.freedesktop.udisks.luks-unlock": YES,
  #      "org.freedesktop.udisks.drive-eject": YES,
  #      "org.freedesktop.udisks.drive-detach": YES,
  #      // required for udisks2:
  #      "org.freedesktop.udisks2.filesystem-mount": YES,
  #      "org.freedesktop.udisks2.encrypted-unlock": YES,
  #      "org.freedesktop.udisks2.eject-media": YES,
  #      "org.freedesktop.udisks2.power-off-drive": YES,
  #      // required for udisks2 if using udiskie from another seat (e.g. systemd):
  #      "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
  #      "org.freedesktop.udisks2.filesystem-unmount-others": YES,
  #      "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
  #      "org.freedesktop.udisks2.eject-media-other-seat": YES,
  #      "org.freedesktop.udisks2.power-off-drive-other-seat": YES
  #    };
  #    if (subject.isInGroup("wheel")) {
  #      return permission[action.id];
  #    }
  #  });
  #'';

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.garbas_config.theme_switch}/bin/switch-theme
  '';

  users.users."rok" = {
    hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [ "wheel" "vboxusers" "networkmanager" "docker" ] ;
    group = "users";
    home = "/home/rok";
    shell = "/run/current-system/sw/bin/zsh";
  };

  virtualisation.docker.enable = true;

}
