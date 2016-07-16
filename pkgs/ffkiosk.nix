{ pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/fd4cdf183a98b0b7086e7fb140a04854805f2b47.tar.gz") {}
}:

let
  kiosk = pkgs.fetchFromGitHub {
    owner = "un1xoid";
    repo = "r-kiosk";
    rev = "74db102c2720268cd6029e6937a39b37ff3d78a8";
    sha256 = "0dqgbdnywhrgwndbx7rsghcblvry2pr35wsqnaim84slinrbdgmm";
  };
  kiosk2 = pkgs.fetchurl {
    url = "https://github.com/un1xoid/r-kiosk/raw/master/build/r_kiosk.xpi";
    sha256 = "052bidxhc7adm2fg2p0gfllmr8m1v0087y4wsgdm4nih4jc5466z";
  };


  ffkiosk = pkgs.firefox-bin-unwrapped.override {
    postInstall = ''
      mkdir -p         "$out/usr/lib/firefox-bin-${(builtins.parseDrvName pkgs.firefox-bin-unwrapped.name).version}/extensions/{4D498D0A-05AD-4fdb-97B5-8A0AABC1FC5B}"
      cd "$out/usr/lib/firefox-bin-${(builtins.parseDrvName pkgs.firefox-bin-unwrapped.name).version}/extensions/{4D498D0A-05AD-4fdb-97B5-8A0AABC1FC5B}"
      ${pkgs.unzip}/bin/unzip ${kiosk2}
    '';
  };

in pkgs.wrapFirefox ffkiosk {
  browserName = "firefox";
  name = "firefox-bin-" +
    (builtins.parseDrvName ffkiosk.name).version;
  desktopName = "Firefox Beta";
}
