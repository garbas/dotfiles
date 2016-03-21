{ pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/fd4cdf183a98b0b7086e7fb140a04854805f2b47.tar.gz") {}
}:

let
  kiosk = pkgs.fetchFromGitHub {
    owner = "un1xoid";
    repo = "r-kiosk";
    rev = "74db102c2720268cd6029e6937a39b37ff3d78a8";
    sha256 = "0dqgbdnywhrgwndbx7rsghcblvry2pr35wsqnaim84slinrbdgmm";
  };
  ffkiosk = pkgs.lib.overrideDerivation pkgs.firefox-unwrapped (old: {
    preConfigure = ''
      mkdir browser/extensions/r-kiosk
      cp -R ${kiosk}/src/* browser/extensions/r-kiosk
    '' + old.preConfigure;
  });
in pkgs.wrapFirefox ffkiosk {}
