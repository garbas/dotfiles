self: super:

rec {

  default = {
    theme = "onedark";
    #theme = "one-light";
    font = "Fira Code Light";  # use fc-list
    fontSize = "10";
    terminal = "${termite}/bin/termite";
    statusBar = "${i3status-rust}/bin/i3status-rs";
  };

  theme = import ./theme.nix {
    inherit (default) theme;
    inherit (self) fetchurl
                   writeScriptBin
                   runCommand
                   nix
                   curl
                   coreutils
                   jq
                   lib;
  };

  termite = import ./termite.nix {
    inherit default theme;
    inherit (super) termite;
    inherit (self) writeTextFile;
  };

  rofi = import ./rofi.nix {
    inherit default theme;
    inherit (super) rofi-unwrapped;
    inherit (self) makeWrapper
                   symlinkJoin
                   lib
                   rofi-calc
                   rofi-emoji
                   hicolor-icon-theme;
  };

  i3 = import ./i3.nix {
    inherit default theme;
    inherit (super) i3;
    inherit (self) makeWrapper
                   symlinkJoin
                   writeTextFile;
  };

  i3status-rust = import ./i3status-rust.nix {
    inherit default theme;
    inherit (super) i3status-rust;
    inherit (self) makeWrapper
                   symlinkJoin
                   writeTextFile;
  };

  neovim = import ./neovim.nix {
    inherit default theme;
    inherit (super) neovim;
    inherit (self) vimPlugins
                   nodejs
                   lib;
  };

  weechat = super.weechat.override
    { configure = { ... }:
      { scripts = with self.weechatScripts;
          [ weechat-matrix-bridge
            wee-slack
          ];
      };
    };

  vscode-with-extensions = super.vscode-with-extensions.override
    { vscodeExtensions = with self.vscode-extensions;
        [ bbenoist.Nix
          ms-python.python
          ms-azuretools.vscode-docker
          ms-vscode.cpptools
        ];
    };

  uhk-agent = self.callPackage ./uhk-agent.nix { };

  # TODO:
  # neofetch (also submit upstream)
  # git (already a config in ../configurations/gitconfig)
  # uhk-agent
  # nix
  # powerlevel10k
  # fzf
  # zathura
  # exa
  # bat
  # dunst
  # cachix
  # gh
  # rofi-1pass
  # nvim -> coc-settings.json
}
