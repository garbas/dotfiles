{ nightfox-src }:

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
    ];
  };

  neovim = final.callPackage ./neovim { inherit myConfig nightfox-src; };

  neofetch = prev.neofetch.overrideAttrs (old: {
    patches = (final.lib.optionals (builtins.hasAttr "patches" old) old.patches) ++ [
      (final.fetchurl { 
        url = "https://github.com/dylanaraps/neofetch/pull/1134.patch";
        sha256 = "sha256-XzYhKdwLO5ANf/ndLBomrQbi8p4fu1zlqimiZYhuItA=";
      })
    ];
  });

  # TODO:
  # neofetch (also submit upstream)
  # git (already a config in ../configurations/gitconfig)
  # nix
  # powerlevel10k
  # fzf
  # zathura
  # exa
  # bat
  # dunst
  # gh
}
