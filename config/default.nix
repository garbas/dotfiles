{ pkgs
, i3_tray_output
, defaultBrightness ? "light"
, scheme ? "default"
, templates ?
    [ "i3"
      "i3status"
      "st"
      "termite"
      "vim"
      "shell"
    ]
}:

let

  base16-builder = (import ./base16-builder {
    inherit pkgs;
    src = pkgs.fetchFromGitHub {
      owner = "base16-builder";
      repo = "base16-builder";
      rev = "fa72b56be3a44e79467303a19adbe0ca62ba198a";
      sha256 = "1c5d1a9k0j0qw41bf6xckki3z5g14k7zwwwbp9g2p2yzccxzjy1s";
    };
  }).package;

  apps = {

    xmodmap = import ./xmodmap.nix {
      inherit (pkgs) writeText;
    };

    git = import ./git.nix {
      inherit (pkgs) writeText neovim gnupg;
    };

    zsh = import ./zsh.nix {
      inherit (pkgs) writeText fzf xdg_utils neovim less zsh-prezto;
    };
   
    i3 = import ./i3.nix {
      inherit i3_tray_output;
      inherit (pkgs) i3 i3status feh termite rofi-menugen networkmanagerapplet
        redshift rofi rofi-pass i3lock-fancy pa_applet
        lib writeText writeScript;
      inherit (self) theme theme_switch;
      inherit (pkgs.xorg) xrandr xbacklight;
      inherit (pkgs.pythonPackages) ipython alot py3status;
      inherit (pkgs.gnome3) gnome_keyring;
    };

    i3status = import ./i3status.nix {
      inherit (pkgs) writeText;
      inherit (self) theme;
    };

    termite = import ./termite.nix {
      inherit (pkgs) writeText firefox;
      inherit (self) theme;
    };

    # TODO: st vim (zsh/shell)
  };

  self = {

    # -- THEME --

    theme = import ./theme.nix {
      inherit (pkgs) runCommand writeScript;
      inherit base16-builder;
      inherit (pkgs.stdenv) lib;
      inherit  scheme templates;
    };

    # TODO: should be also a systemd unit (one off) after ???
    update_xkbmap = import ./update_xkbmap.nix {
      inherit (pkgs) writeScriptBin;
      inherit (pkgs.xorg) xinput xset setxkbmap xmodmap;
    };

    theme_switch = pkgs.writeScriptBin "switch-theme"
      ''
        # set default brightness if not yet set
        if [ ! -e /tmp/theme-brightness ]; then
          echo -n "${defaultBrightness}" > /tmp/theme-brightness
        fi

        brightness=`cat /tmp/theme-brightness`

        if [ $# -eq 1 ]; then
          if [ "$1" = "toggle" ]; then
            echo "Toggling brightness ($brightness)"
            if [ "$brightness" = "light" ]; then
              brightness="dark"
            fi
            if [ "$brightness" = "dark" ]; then
              brightness="light"
            fi
          else
            brightness=$1
          fi
          echo "setting brightness: $brightness"
          rm -r /tmp/theme-brightness
          echo -n "$brightness" > /tmp/theme-brightness
        fi

        # rebuild configuration 
        rm -rf /tmp/config
        mkdir /tmp/config
        for app in ${builtins.concatStringsSep " " (builtins.attrNames apps)}; do
          source=/etc/config/$app.$brightness
          if [ -e $source ]; then
            cp -f $source /tmp/config/$app
          fi
        done

        source ${self.update_xkbmap}/bin/update-xkbmap
        mkdir -p $HOME/.vim/backup
      '';

    # -- NIXOS --

    environment_etc =
      (pkgs.lib.flatten (map
        (appName:
          let
            app = builtins.getAttr appName apps;
          in
            if builtins.hasAttr "environment_etc" app
            then app.environment_etc
            else [ { source = app.light;
                     target = "config/${appName}.light";
                   }
                   { source = app.dark;
                     target = "config/${appName}.dark";
                   }
                 ]
        ) (builtins.attrNames apps)));

    # TODO: loop over apps
    system_packages = builtins.attrValues (
      self.xmodmap.packages //
      self.git.packages //
      self.zsh.packages //
      self.i3.packages //
      self.i3status.packages //
      self.termite.packages //
      {});

  } // apps;

in self
