{ pkgs ? import <nixpkgs> {} }:

rec { 
  # TODO:
  #  - i3 themed
  #  - py3status configured
  #  - replace offlineimap with isync and add to systemd
  #  - add afew to systemd
  #  - create alot theme

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

  firefox = pkgs.wrapFirefox { browser = pkgs.firefox; };

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
      theme = builtins.readFile "${base16}/st/base16-default.light.c";
    };
  };

  zsh_prezto = pkgs.stdenv.mkDerivation rec {
    name = "zsh-prezto-2015";
    configFile = pkgs.writeText "zpreztorc" (import ./zsh_config.nix { inherit pkgs; });
    srcs = [
      (pkgs.fetchgit {
         rev = "f2a826e963f06a204dc0e09c05fc3e5419799f52";
         url = "https://github.com/sorin-ionescu/prezto";
         sha256 = "92eabf5247a878c57e045988a2475021f9a345de8c9a3bcc05f2b42dc4711c6d";
         })
      (pkgs.fetchgit {
         rev = "9b7d216ec095ccee541ebfa5f04249aa2964d054";
         url = "https://github.com/garbas/nix-zsh-completions";
         sha256 = "00r3mapc6hyj34pglwvf84iz5k7nlv84vl3in8grdp11vrwgs3ga";
         })
    ];
    sourceRoot = "prezto-f2a826e";
    installPhase = ''
      mkdir -p $out/modules/nix

      sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zpreztorc|${configFile}|g" init.zsh
      sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zprezto/|$out/|g" init.zsh
      for i in runcoms/*; do
        sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zprezto/|$out/|g" $i
      done
      sed -i -e "s|\''${0:h}/cache.zsh|\''${ZDOTDIR:\-\$HOME}/.zfasd_cache|g" modules/fasd/init.zsh

      cp ../nix-zsh-completions-9b7d216/* $out/modules/nix -R
      cp ./* $out/ -R
    '';
  };

  neovim = pkgs.neovim.override {
    vimAlias = true;
    configure = import ./vim_config.nix { inherit pkgs base16; };
  };
}
