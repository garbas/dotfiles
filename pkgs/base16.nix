{ stdenv, fetchgit, ruby, which }:

stdenv.mkDerivation rec {
  rev = "a73bb13d5a3480c13fa92dab6b3f4065ae694a3f";
  name = "base16-2015-08-20_${rev}";

  src = fetchgit {
    inherit rev;
    url = "git://github.com/xHN35RQ/base16-builder.git";
    sha256 = "8036e5c472550deb2c0d247f8af67186c9b35018245cd2267c44e90d438efd58";
  };

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
