{ pkgs ? import <nixpkgs> {},

}:

let
  inherit (pkgs.callPackage ./nvim_config.nix { plugins = pkgs.vimPlugins; })
    preConfig
    postConfig
    pluginsWithConfig;

in pkgs.neovim.override {
  vimAlias = true;
  configure = {
    customRC = preConfig + (builtins.concatStringsSep "\n\n" (builtins.map (x: x.config) pluginsWithConfig)) + postConfig;
    packages.myVimPackages = {
      start = pkgs.lib.flatten (builtins.map (x: x.plugins) pluginsWithConfig);
    };
  };
}
