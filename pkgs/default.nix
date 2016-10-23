{ pkgs
, garbas_config ? null
}:

let

  self = { 

    inherit garbas_config;

    # ERRORS:
    # Jul 17 00:34:05 nemo kernel: zswap: default zpool zbud not available
    # Jul 17 00:34:05 nemo kernel: zswap: pool creation failed
    # Jul 17 00:34:05 nemo systemd-modules-load[2041]: Failed to find module 'fbcon'
    # Jul 17 00:34:08 nemo bluetoothd[2335]: Failed to obtain handles for "Service Changed" characteristic
    # Jul 17 00:34:13 nemo rtkit-daemon[3050]: Failed to make ourselves RT: Operation not permitted
    # Jul 17 00:34:13 nemo systemd[3020]: Failed to start Lightweight and customizable notification daemon.
    # Jul 17 11:43:35 nemo py3status[12340]: py3status: Instance `battery_level 0`, user method `battery_level` failed (Attri
    # 


    # TODO:
    #  - py3status configured
    #  - replace offlineimap with isync and add to systemd
    #  - add afew to systemd
    #  - create alot theme

    # TODO: need to finish this
    ffkiosk = import ./ffkiosk.nix { inherit pkgs; };

    nixos_slim_theme = pkgs.fetchurl {
      url = "https://github.com/jagajaga/nixos-slim-theme/archive/master.tar.gz";
      sha256 = "0nflmgwdwc7qy0qb3kwg96w0hw7mvxwfx77yrahv8cqbq78k0gl9";
    };

    # TODO: for some reason brother printer does not print correctly
    # need to test the driver on ubuntu
    brother-hl2030 = import ./brother-hl2030.nix {
      inherit (pkgs) stdenv fetchurl cups dpkg patchelf bash file coreutils;
      ghostscript = pkgs.ghostscript.override { x11Support = false; cupsSupport = true; };
    };

    firefox = pkgs.firefox-beta-bin;
    #firefox = pkgs.firefox-developer-bin;

    weechat = pkgs.weechat.override {
      extraBuildInputs = [ pkgs.pythonPackages.websocket_client ];
    };

    ttf_bitstream_vera = pkgs.callPackage ./ttf_bitstream_vera {
      inherit (pkgs) stdenv fetchgit;
    };

    VidyoDesktop = import ./VidyoDesktop {
      inherit (pkgs) stdenv fetchurl buildFHSUserEnv makeWrapper dpkg alsaLib
        alsaUtils alsaOss alsaTools alsaPlugins libidn utillinux mesa_glu
        zlib patchelf gnome2 libpng12 fontconfig freetype libffi qt4 file;
      inherit (pkgs.xorg) libXext libXv libX11 libXfixes libXrandr libXScrnSaver;
    };


    # should be part of config really

    termite = pkgs.termite.override { configFile = "/tmp/config/termite"; };

    neovim = pkgs.neovim.override {
      vimAlias = true;
      configure = import ./nvim_config.nix {
        inherit pkgs;
        theme = if garbas_config == null then null else garbas_config.theme;
      };
    };

  };

in self
