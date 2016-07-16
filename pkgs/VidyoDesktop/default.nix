{ stdenv, fetchurl, buildFHSUserEnv, makeWrapper, dpkg, alsaLib, alsaUtils
, alsaOss, alsaTools, alsaPlugins, libidn, utillinux, mesa_glu, qt4, zlib
, patchelf, gnome2, libpng12, fontconfig, freetype, libffi, file
, libXext, libXv, libX11, libXfixes, libXrandr, libXScrnSaver
}:

let
  VidyoDesktopDeb = stdenv.mkDerivation {
    name = "VidyoDesktopDeb";
    builder = ./builder.sh;
    inherit dpkg;
    src = fetchurl {
      url = "https://demo.vidyo.com/upload/VidyoDesktopInstaller-ubuntu64-TAG_VD_3_6_3_017.deb";
      sha256 = "01spq6r49myv82fdimvq3ykwb1lc5bymylzcydfdp9xz57f5a94x";
    };
    buildInputs = [ makeWrapper ];
  };

in buildFHSUserEnv {
  name = "VidyoDesktop";
  targetPkgs = pkgs: [ VidyoDesktopDeb ];
  multiPkgs = pkgs: [
    patchelf dpkg alsaLib alsaUtils alsaOss alsaTools alsaPlugins
    libidn utillinux mesa_glu zlib libXext libXv libX11 libXfixes
    libXrandr libXScrnSaver libpng12 fontconfig freetype libffi
    gnome2.zenity
    qt4 file
  ];
  extraBuildCommands = ''
    ln -s ${VidyoDesktopDeb}/opt $out/opt
  '';
  runScript = "VidyoDesktop";
  # for debugging
  #runScript = "bash";
}
