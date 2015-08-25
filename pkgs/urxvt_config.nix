{ pkgs }:
''

! XDVI
xdvi.highlight: orange
xdvi.Hush: true
xdvi.hushStdout: true
xdvi.LinkStyle: 2
xdvi.noInitFile: true
xdvi.expertMode: 0
xdvi.shrinkFactor: 5
xdvi.sideMargin: 2.5cm
xdvi.topMargin: 3cm

!! XFT
Xft.autohint: 0
Xft.lcdfilter: lcddefault
Xft.hintstyle: hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.dpi: 96
Xft.rgba: rgb

!! General
URxvt*loginShell: false
URxvt*internalBorder: 2
URxvt*saveLines: 100000
URxvt*shading: 15
URxvt*transparent: false
URxvt*geometry: 80x25
URxvt*urgentOnBell: true
URxvt.buffered: true
URxvt.xftAntialias: true

!! Scrolling
URxvt*scrollBar: false
URxvt*scrollstyle: plain
URxvt*scrollTtyOutput: false
URxvt*scrollTtyKeypress: true

!! Fonts
URxvt*font: xft:Bitstream Vera Sans Mono:autohint=true:pixelsize=12
URxvt*boldFont: xft:Bitstream Vera Sans Mono:autohint=true:pixelsize=12
URxvt*italicFont: xft:Bitstream Vera Sans Mono:italic:autohint=true:pixelsize=12
URxvt*bolditalicFont: xft:Bitstream Vera Sans Mono:bold:italic:autohint=true:pixelsize=12
!! Plugins
URxvt.perl-ext-common: default,newterm,url-select,clipboard,font-size

!!!! newterm
!!!! Open a new terminal in your current working directory, a la 
!!!! Ctrl-Shift-N in gnome-terminal
URxvt.keysym.M-n: perl:newterm

!!!! url-select
!!!! Use keyboard shortcuts to select URLs.
URxvt.keysym.M-u: perl:url-select:select_next
URxvt.url-select.underline: true
URxvt.url-select.launcher: firefox

!!!! clipoard
URxvt.keysym.M-c: perl:clipboard:copy
URxvt.keysym.M-v: perl:clipboard:paste
URxvt.keysym.M-C-v: perl:clipboard:paste_escaped
URxvt.copyCommand: ${pkgs.xsel}/bin/xsel -ib
URxvt.pasteCommand: ${pkgs.xsel}/bin/xsel -ob

!!!! font-size
!!!! Allows changing the font size on the fly with keyboard shortcuts
URxvt.keysym.M-Page_Up: perl:font-size:increase
URxvt.keysym.M-Page_Down: perl:font-size:decrease
URxvt.keysym.M-S-Page_Up: perl:font-size:incglobal
URxvt.keysym.M-S-Page_Down: perl:font-size:decglobal
URxvt.keysym.M-0: perl:font-size:reset
URxvt.font-size.step: 2

''
