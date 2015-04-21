{}:

let

  pkgs = import <nixpkgs> {};

in pkgs.buildEnv {
  name = "dotfiles";
  paths = with pkgs; [
    (weechat.override {
        extraBuildInputs = [ pythonPackages.websocket_client ];
        })
    (vim_configurable.customize {
      name = "vim-garbas";
      vimrcConfig = {
        customRC = ''
          set hidden
        '';
        vam.knownPlugins = pkgs.vimPlugins;
        vam.pluginDictionaries = [
          { names = [
              "youcompleteme"
              "ctrlp"
            ];
          }
        ];
      };
    })
  ];
}
