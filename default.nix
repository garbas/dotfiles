{}:

let

  pkgs = import <nixpkgs> {};

in pkgs.buildEnv {
  name = "dotfiles";
  paths = with pkgs; [
    (weechat.override {
        extraBuildInputs = [ pythonPackages.websocket_client ];
        })
  ];
}
