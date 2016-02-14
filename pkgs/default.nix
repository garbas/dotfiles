{ pkgs, base16Theme ? "default" }:

rec { 
  # TODO:
  #  - py3status configured
  #  - replace offlineimap with isync and add to systemd
  #  - add afew to systemd
  #  - create alot theme

  nixos_slim_theme = pkgs.fetchurl {
    url = "https://github.com/jagajaga/nixos-slim-theme/archive/master.tar.gz";
    sha256 = "0nflmgwdwc7qy0qb3kwg96w0hw7mvxwfx77yrahv8cqbq78k0gl9";
  };

  brother-hl2030 = import ./brother-hl2030.nix {
    inherit (pkgs) stdenv fetchurl cups dpkg patchelf bash file coreutils;
    ghostscript = pkgs.ghostscript.override { x11Support = false; cupsSupport = true; };
  };

  chromium = pkgs.chromium.override {
    channel = "beta";
    enableHotwording = false;
    #gnomeSupport = true; 
    #gnomeKeyringSupport = true;
    proprietaryCodecs = true;
    enablePepperFlash = true;
    enableWideVine = true;
    cupsSupport = true;
    pulseSupport = true;
    #hiDPISupport = true;
  };

  inherit (pkgs.callPackages <nixpkgs/pkgs/applications/networking/browsers/firefox> {
    inherit (pkgs.gnome) libIDL;
    inherit (pkgs.pythonPackages) pysqlite;
    libpng = pkgs.libpng_apng;
    #enableGTK3 = true;
    #enableOfficialBranding = true;
  }) firefox-unwrapped firefox-esr-unwrapped;

  firefox = pkgs.wrapFirefox firefox-unwrapped { };
  firefox-esr = pkgs.wrapFirefox firefox-esr-unwrapped { };

  nerdfonts = pkgs.stdenv.mkDerivation rec {
    rev = "6158e08ce0367090e9383a2e795aa03d3550f2b4";
    name = "nerdfonts-2015-${rev}";
    src = pkgs.fetchgit {
      inherit rev;
      url = "https://github.com/ryanoasis/nerd-fonts";
      sha256 = "0d9ddc679e3f47849cd510e7beb6979b5c898118eb8e4127dcddd4682714ec84";
    };
    patchPhase = ''
      sed -i -e 's|/bin/bash|${pkgs.bash}/bin/bash|g' install.sh
      sed -i -e 's|font_dir="$HOME/.fonts"|font_dir="$out/share/fonts"|g' install.sh
      sed -i -e 's|font_dir="$HOME/Library/Fonts"|font_dir="$out/share/fonts"|g' install.sh
      sed -i -e 's|/bin/bash|${pkgs.bash}/bin/bash|g' gotta-patch-em-all-font-patcher!.sh
      sed -i -e 's|/usr/bin/env python2|${pkgs.python2}/bin/python|g' font-patcher
    '';
    buildPhase = ''
      export PYTHONPATH=$PYTHONPATH:${pkgs.fontforge.override { withPython = true; }}/lib/python2.7/site-packages
      #./gotta-patch-em-all-font-patcher!.sh
    '';
    installPhase = ''
      mkdir -p $out/share/fonts
      ./install.sh
    '';
  };

  base16 = pkgs.callPackage ./base16.nix { };

  weechat = pkgs.weechat.override {
    extraBuildInputs = [ pkgs.pythonPackages.websocket_client ];
  };

  ttf_bitstream_vera = pkgs.callPackage ./ttf_bitstream_vera {
    inherit (pkgs) stdenv fetchgit;
  };

  st = pkgs.st.override {
    conf = import ./st_config.nix {
      theme = builtins.readFile "${base16}/st/base16-${base16Theme}.light.c";
    };
  };

  zsh-prezto =
    let
      rev = "7227c4f0bef5f8ae787c65150d7a7403394fff48";
    in pkgs.stdenv.mkDerivation rec {
      name = "zsh-prezto-2015";
      srcs = [
        (pkgs.fetchgit {
          url = "https://github.com/sorin-ionescu/prezto";
          sha256 = "16hzcmbfqyksckx7ljv62abwmwny7jqrkll9lrhm3z4d5k6dd80d";
          inherit rev;
          })
        (pkgs.fetchFromGitHub {
          owner = "garbas";
          repo = "nix-zsh-completions";
          rev = "9b7d216ec095ccee541ebfa5f04249aa2964d054";
          sha256 = "1pvmfcqdvdi3nc1jm72f54mwf06yrmlq31pqw6b5fczawcz02jrz";
          })
      ];
      patches = [
        (pkgs.fetchurl {
          url = "https://github.com/sorin-ionescu/prezto/pull/1028.patch";
          sha256 = "0n2s7kfp9ljrq8lw5iibv0vyv66awrkzkqbyvy7hlcl06d8aykjv";
        })
      ];
      sourceRoot = "prezto-${builtins.substring 0 7 rev}";
      buildPhase = ''
        sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zpreztorc|/etc/zpreztorc|g" init.zsh
        sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zprezto/|$out/|g" init.zsh
        for i in runcoms/*; do
          sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zprezto/|$out/|g" $i
        done
        sed -i -e "s|\''${0:h}/cache.zsh|\''${ZDOTDIR:\-\$HOME}/.zfasd_cache|g" modules/fasd/init.zsh
      '';
      installPhase = ''
        mkdir -p $out/modules/nix
        cp ../nix-zsh-completions-*/* $out/modules/nix -R
        cp ./* $out/ -R
      '';
    };

  neovim = pkgs.neovim.override {
    vimAlias = true;
    configure = import ./vim_config.nix { inherit pkgs base16 base16Theme; };
  };

  urxvt-theme-switch = import ./urxvt_theme_switch.nix { inherit (pkgs) stdenv fetchFromGitHub; };

  rxvt_unicode-with-plugins = pkgs.rxvt_unicode-with-plugins.override {
    plugins = with pkgs; [
      urxvt_perl
      urxvt_perls
      urxvt_tabbedex
      urxvt_font_size
      urxvt-theme-switch
    ];
  };

  rofi = pkgs.rofi.override { i3Support = true; };

  dmenu = pkgs.dmenu.overrideDerivation (old: {
    patches = [

      # follow input focus
      #
      # With this patch dmenu will show up on the monitor which has input
      # focus.
      #
      # http://tools.suckless.org/dmenu/patches/follow-focus
      #
      # TODO: patch doesn't apply
      #(pkgs.fetchurl {
      #    url = "http://tools.suckless.org/dmenu/patches/dmenu-4.4-follow-focus.diff";
      #    sha256 = "0ha7d9z9dgsdnzc59977nnry0a4j247bv7ivz8fiks12wqdqlc46";
      #  })

      # fuzzymatch
      #
      # This patch adds support for fuzzy matching to dmenu, allowing users to
      # type non-consecutive portions of the string to be matched.
      #
      # http://tools.suckless.org/dmenu/patches/fuzzymatch
      #
      # TODO: patch doesn't apply
      #(pkgs.fetchurl {
      #    url = "http://tools.suckless.org/dmenu/patches/dmenu-git-20151020-fuzzymatch.diff";
      #    sha256 = "0swk4ggw6si9mhvpmaryxzm53cqd2wi4ijjccj4kgy9dk1q7r44h";
      #  })

      # Line height
      #
      # The patch adds a ‘-lh’ option, which sets the minimum height of a dmenu
      # line. This helps integrate dmenu with other UI elements that require
      # a particular vertical size.
      #
      # http://tools.suckless.org/dmenu/patches/line-height
      (pkgs.fetchurl {
          url = "http://tools.suckless.org/dmenu/patches/dmenu-4.6-line-height.diff";
          sha256 = "0zdf0clnpqqsa8nwsdldhnm8jj7cc3z83yc66pxzi5lvihk7m9c1";
        })
    ];
  });

  VidyoDesktop = import ./VidyoDesktop {
    inherit (pkgs) stdenv fetchurl buildFHSUserEnv makeWrapper dpkg  alsaLib
      alsaUtils alsaOss alsaTools alsaPlugins libidn utillinux mesa_glu qt4
      zlib patchelf;
    inherit (pkgs.xorg) libXext libXv libX11 libXfixes libXrandr libXScrnSaver;
  };

}
