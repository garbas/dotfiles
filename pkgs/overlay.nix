self: super:

rec {

  default = {
    theme = "onedark";
    #theme = "one-light";
    font = "Fira Code Light";
    fontSize = "12";
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

  # dunst
  # zathura
  # fzf
}
