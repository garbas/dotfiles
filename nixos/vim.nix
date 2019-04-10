{ pkgs ? import <nixpkgs> {}
}:

pkgs.neovim.override {
  vimAlias = true;
  configure = import ./vim_config.nix { inherit pkgs; };
}
