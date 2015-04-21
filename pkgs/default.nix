{ pkgs ? import <nixpkgs> {}
}:
{ 
  weechat = weechat.override {
    extraBuildInputs = [ pythonPackages.websocket_client ];
  };

  ttf_bitstream_vera = pkgs.callPackage ./ttf_bitstream_vera {
    inherit (pkgs) stdenv fetchgit;
  };
}

#pkgs.buildEnv {
#  name = "dotfiles";
#  paths = with pkgs; [
#    (vim_configurable.customize {
#      name = "vim-garbas";
#      vimrcConfig = {
#        customRC = ''
#          set hidden
#        '';
#        vam.knownPlugins = pkgs.vimPlugins;
#        vam.pluginDictionaries = [
#          { names = [
#              "youcompleteme"
#              "ctrlp"
#            ];
#          }
#        ];
#      };
#    })
#  ];
#}
