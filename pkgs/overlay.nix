{ neovim-flake, nightfox-src }:

final: prev:

let
  myConfig = {
    # https://github.com/EdenEast/nightfox.nvim
    theme = "nordfox"; # One of nightfox, nordfox, dayfox, dawnfox and duskfox.
    fontFamily = "Fira Code Light";  # use fc-list
    fontSize = 10;
    terminal = "${final.kitty}/bin/kitty";
    browser = "${final.chromium}/bin/chromium";
  };
in rec {

  obs-studio-with-plugins = final.wrapOBS {
    plugins = with final.obs-studio-plugins; [
      wlrobs
      obs-source-record
    ];
  };

  neovim = final.callPackage ./neovim { inherit myConfig nightfox-src; };

  neovim-nightly = final.callPackage ./neovim {
    inherit myConfig nightfox-src;
    neovim-unwrapped = neovim-flake.packages.${prev.system}.neovim;
  };

  neofetch = prev.neofetch.overrideAttrs (old: {
    patches = (final.lib.optionals (builtins.hasAttr "patches" old) old.patches) ++ [
      (final.fetchurl { 
        url = "https://github.com/dylanaraps/neofetch/pull/1134.patch";
        sha256 = "sha256-XzYhKdwLO5ANf/ndLBomrQbi8p4fu1zlqimiZYhuItA=";
      })
    ];
  });

  kitty = final.callPackage ./kitty.nix {
    inherit myConfig;
    inherit (prev) kitty;
  };

  i3 = final.callPackage ./i3.nix {
    inherit myConfig;
    inherit (prev) i3;
  };

  i3status-rust = final.callPackage ./i3status-rust.nix {
    inherit (prev) i3status-rust;
  };

  uhk-agent = final.callPackage ./uhk-agent.nix { };

  rofi = final.callPackage ./rofi.nix {
    inherit myConfig;
    inherit (prev) rofi-unwrapped;
  };

  # TODO:
  # home-manager
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
