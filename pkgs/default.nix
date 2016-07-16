{ pkgs, base16Theme ? "default" }:

rec { 
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

  #firefox = pkgs.firefox-beta-bin;
  firefox = pkgs.firefox-developer-bin;

  weechat = pkgs.weechat.override {
    extraBuildInputs = [ pkgs.pythonPackages.websocket_client ];
  };

  ttf_bitstream_vera = pkgs.callPackage ./ttf_bitstream_vera {
    inherit (pkgs) stdenv fetchgit;
  };

  st = pkgs.st.override {
    conf = import ./st_config.nix {
      theme = builtins.readFile "${pkgs.base16}/st/base16-${base16Theme}.light.c";
    };
  };

  neovim = pkgs.neovim.override {
    vimAlias = true;
    configure = import ./nvim_config.nix { inherit pkgs base16Theme; };
  };

  rofi = pkgs.rofi.override { i3Support = true; };

  VidyoDesktop = import ./VidyoDesktop {
    inherit (pkgs) stdenv fetchurl buildFHSUserEnv makeWrapper dpkg alsaLib
      alsaUtils alsaOss alsaTools alsaPlugins libidn utillinux mesa_glu
      zlib patchelf gnome2 libpng12 fontconfig freetype libffi qt4 file;
    inherit (pkgs.xorg) libXext libXv libX11 libXfixes libXrandr libXScrnSaver;
  };

}
