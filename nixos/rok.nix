{ i3_tray_output }:

{ pkgs, config, ... }:

let

  base16Theme = "default";

  themeUpdateScript = theme: ''
    rm -f /tmp/theme-config
    echo -n "${theme}" > /tmp/theme-config
    cp -f /etc/termite-config-${theme} /tmp/termite-config
    source /etc/setxkbmap-config
    mkdir -p ~/.vim/backup
  '';

  themeDark = pkgs.writeScript "theme-dark" (themeUpdateScript "dark");
  themeLigth = pkgs.writeScript "theme-light" (themeUpdateScript "light");

  i3Packages = with pkgs; {
    inherit i3 i3status feh termite rofi-menugen networkmanagerapplet
      redshift base16 rofi rofi-pass i3lock-fancy;
    inherit (xorg) xrandr xbacklight;
    inherit (pythonPackages) ipython alot py3status;
    inherit (gnome3) gnome_keyring;
  };
  setxkbmapPackages = with pkgs.xorg; { inherit xinput xset setxkbmap xmodmap; };
  zshPackages = with pkgs; { inherit fasd xdg_utils neovim less zsh-prezto; };

in {

  imports = [ ./common.nix ];

  environment.etc."Xmodmap".text = import ./../pkgs/xmodmap_config.nix { };

  environment.etc."gitconfig".text = import ./../pkgs/git_config.nix {
    inherit (pkgs) neovim;
  };

  environment.etc."i3-config".text = import ./../pkgs/i3_config.nix (i3Packages // {
    inherit base16Theme i3_tray_output themeDark themeLigth;
    inherit (pkgs) lib writeScript;
  });

  environment.etc."i3status-config".text = import ./../pkgs/i3status_config.nix {
    inherit base16Theme;
    inherit (pkgs) lib base16;
  };

  environment.etc."setxkbmap-config".text = import ./../pkgs/setxkbmap_config.nix setxkbmapPackages;

  environment.etc."zlogin".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zlogin";
  environment.etc."zlogout".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zlogout";
  environment.etc."zpreztorc".text = import ./../pkgs/zsh_config.nix (zshPackages);
  environment.etc."zprofile.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zprofile";
  environment.etc."zshenv.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zshenv";
  environment.etc."zshrc.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zshrc";

  environment.etc."termite-config-dark".text = import ./../pkgs/termite_config.nix { inherit pkgs base16Theme; dark = true; };
  environment.etc."termite-config-light".text = import ./../pkgs/termite_config.nix { inherit pkgs base16Theme; dark = false; };

  environment.systemPackages = with pkgs;
    (builtins.attrValues (
      i3Packages //
      setxkbmapPackages //
      zshPackages //
      {})) ++
    [

      termite.terminfo

      # email (TODO: we need to reconfigure mail system)
      pythonPackages.alot
      pythonPackages.afew  # set with timer
      msmtp
      notmuch
      isync
      w3m

      # TODO: needed for vim's syntastic
      csslint
      ctags
      htmlTidy
      phantomjs
      pythonPackages.docutils
      pythonPackages.flake8


      # console applications
      gitAndTools.gitflow
      gitAndTools.tig
      gitFull
      gnumake
      gnupg
      htop
      keybase
      mercurialFull
      mosh
      neovim
      ngrok
      pass
      scrot
      st  # backup terminal
      taskwarrior
      unrar
      unzip
      vifm
      wget
      which
      asciinema
      pavucontrol

      # gui applications
      #chromium
      firefox-beta-bin
      pavucontrol
      skype  # doesnt work for some time
      vlc
      mplayer
      zathura
      VidyoDesktop
      #tdesktop

      # gnome3 theme
      gnome3.dconf
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard

    ];

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    anonymousPro
    corefonts
    dejavu_fonts
    freefont_ttf
    liberation_ttf
    source-code-pro
    terminus_font
    ttf_bitstream_vera
    nerdfonts
  ];

  networking.extraHosts = ''
    81.4.127.29 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';

  programs.zsh.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var YES = polkit.Result.YES;
      // NOTE: there must be a comma at the end of each line except for the last:
      var permission = {
        // required for udisks1:
        "org.freedesktop.udisks.filesystem-mount": YES,
        "org.freedesktop.udisks.luks-unlock": YES,
        "org.freedesktop.udisks.drive-eject": YES,
        "org.freedesktop.udisks.drive-detach": YES,
        // required for udisks2:
        "org.freedesktop.udisks2.filesystem-mount": YES,
        "org.freedesktop.udisks2.encrypted-unlock": YES,
        "org.freedesktop.udisks2.eject-media": YES,
        "org.freedesktop.udisks2.power-off-drive": YES,
        // required for udisks2 if using udiskie from another seat (e.g. systemd):
        "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
        "org.freedesktop.udisks2.filesystem-unmount-others": YES,
        "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
        "org.freedesktop.udisks2.eject-media-other-seat": YES,
        "org.freedesktop.udisks2.power-off-drive-other-seat": YES
      };
      if (subject.isInGroup("wheel")) {
        return permission[action.id];
      }
    });
  '';

  services.xserver.displayManager.sessionCommands = ''
    ${themeDark}
  '';

  systemd.user.services.dunst = {
    enable = false;
    description = "Lightweight and customizable notification daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.dunst ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.dunst}/bin/dunst";
    };
  };

  systemd.user.services.udiskie = {
    enable = false;
    description = "Removable disk automounter";
    wantedBy = [ "default.target" ];
    path = with pkgs; [
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard
      pythonPackages.udiskie
    ];
    environment.XDG_DATA_DIRS="${pkgs.gnome3.defaultIconTheme}/share:${pkgs.gnome3.gnome_themes_standard}/share";
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.pythonPackages.udiskie}/bin/udiskie --automount --notify --tray --use-udisks2";
    };
  };

  systemd.user.services.i3lock-auto = {
    enable = false;
    description = "Automatically lock screen after 15 minutes";
    wantedBy = [ "default.target" ];
    path = with pkgs; [ xautolock i3lock-fancy ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.xautolock}/bin/xautolock -lockaftersleep -detectsleep -time 15 -locker ${pkgs.i3lock-fancy}/bin/i3lock-fancy";
    };
  };

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
  virtualisation.docker.socketActivation = true;

}
