{ stdenv, fetchgit, fetchurl, ruby, which }:

stdenv.mkDerivation rec {
  rev = "9b24598c08a27780f87c318e6145c1468b9880ba";
  name = "base16-2015-09-29_${rev}";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/chriskempson/base16-builder";
    sha256 = "05wyf0qz5z3n3g8lz2rd1b6gv6v7qjaazwjm0w4ib4anj4v026sd";
  };

  patches = [
    (fetchurl {
        url = "https://patch-diff.githubusercontent.com/raw/chriskempson/base16-builder/pull/336.patch";
        sha256 = "1gbz5nw6m7dgwx5jdq1mydg5afsgdq9q96284q4zpkna5rm491yj";
      })
  ];

  buildInputs = [ ruby which ];

  buildPhase = ''
    patchShebangs base16
    ./base16
  '';

  installPhase = ''
    mkdir -p $out
    cp output/* $out -R
  '';

}
