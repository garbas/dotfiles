{ stdenv, fetchurl, cups, dpkg, ghostscript, patchelf, bash, file, coreutils }:

stdenv.mkDerivation rec {
  name = "brother-hl2030-${version}";
  version = "2.0.1";

  srcs =
    [ (fetchurl {
        url = "http://www.brother.com/pub/bsc/linux/dlf/brhl2030lpr-${version}-1.i386.deb";
        sha256 = "047yla3df8vb839qfrai2wpcjv1zh0nwg6y3gl72bsa2prwlizip";
      })
      (fetchurl {
        url = "http://www.brother.com/pub/bsc/linux/dlf/cupswrapperHL2030-${version}-2.i386.deb";
        sha256 = "0566akl344wql6fgdjnvclijflnf0g0mmplqyiz9jksx000rm32l";
      })
    ];

  buildInputs = [ dpkg cups patchelf bash ];

  unpackPhase = ''
    mkdir ${name}
    cd ${name}
    for s in $srcs; do dpkg-deb -x $s .; done
  '';

  patches = [ ./brother-hl2030.patch ];

  postPatch = ''
    sed -i -e "s|/usr/bin/brprintconflsr2|$out/usr/bin/brprintconflsr2|" usr/bin/brprintconfiglpr2
    sed -i -e "s|/bin/sh|${bash}/bin/sh|" usr/bin/brprintconfiglpr2
    sed -i -e "s|/usr/sbin/pstops|${cups}/lib/cups/filter/pstops|" usr/local/Brother/lpd/psconvert2
    sed -i -e "s|/bin/sh|${bash}/bin/sh|" usr/local/Brother/lpd/psconvert2
    sed -i -e "s|GHOST_SCRIPT=\`which gs\`|GHOST_SCRIPT=${ghostscript}/bin/gs|" usr/local/Brother/lpd/psconvert2
    sed -i -e "s|/usr/share|$out/usr/share|" usr/local/Brother/lpd/filterHL2030
    sed -i -e "s|pdf2ps|${ghostscript}/bin/pdf2ps|" usr/local/Brother/lpd/filterHL2030
    #sed -i -e "s|a2ps|bin/a2ps|" usr/local/Brother/lpd/filterHL2030
    sed -i -e "s|/bin/sh|${bash}/bin/sh|" usr/local/Brother/lpd/filterHL2030
    sed -i -e "s|file|${file}/bin/file|" usr/local/Brother/lpd/filterHL2030
    sed -i -e "s|/usr/lib/cups/filter/pstops|${cups}/lib/cups/filter/pstops|" usr/local/Brother/lpd/filterHL2030
    sed -i -e "s|/usr/local/Brother|$out/usr/share/brother|" usr/local/Brother/inf/setupPrintcap
    sed -i -e "s|/bin/sh|${bash}/bin/sh|" usr/local/Brother/inf/setupPrintcap
    sed -i -e "s|/usr/lib/cups/filter/pstops|${cups}/lib/cups/filter/pstops|" usr/local/Brother/inf/brHL2030func
    sed -i -e "s|/usr/share/cups/model/HL2030.ppd|$out/share/cups/model/HL2030.ppd|" usr/local/Brother/cupswrapper/cupswrapperHL2030-2.0.1
    sed -i -e "s|/usr/share/brother|$out/usr/share/brother|" usr/local/Brother/cupswrapper/cupswrapperHL2030-2.0.1
    sed -i -e "s|/bin/sh|${bash}/bin/sh|" usr/local/Brother/cupswrapper/cupswrapperHL2030-2.0.1
    sed -i -e "s|/bin/false|${coreutils}/bin/false|" usr/local/Brother/cupswrapper/cupswrapperHL2030-2.0.1
  '';

  buildPhase = ''
    patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux.so.2 usr/local/Brother/lpd/rawtobr2
    patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux.so.2 usr/local/Brother/inf/braddprinter
    patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux.so.2 usr/local/Brother/cupswrapper/brcupsconfig3
    patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux.so.2 usr/bin/brprintconflsr2
    usr/local/Brother/cupswrapper/cupswrapperHL2030-2.0.1
  '';

  installPhase = ''
    mkdir -p $out/usr/share
    cp -R usr/bin $out/usr
    cp -R usr/lib $out/usr
    cp -R usr/local/Brother $out/usr/share/brother

    rm $out/usr/share/brother/cupswrapper/cupswrapperHL2030-2.0.1
    rm $out/usr/share/brother/inf/setupPrintcap

    install -m 644 -D ppd_file $out/share/cups/model/HL2030.ppd
    install -m 755 -D wrapper $out/lib/cups/filter/brlpdwrapperHL2030
  '';

  meta = {
    homepage = http://www.brother.com/;
    description = "A driver for brother brhl2030lpr printers to print over WiFi and USB";
    license = stdenv.lib.licenses.unfree;
    platforms = stdenv.lib.platforms.linux;
    downloadPage = http://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&prod=mfcj470dw_us_eu_as&os=128;
  };
}
