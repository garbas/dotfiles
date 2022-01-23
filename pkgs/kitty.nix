{ myConfig
, kitty
, symlinkJoin
, makeWrapper
, writeTextFile
, vimPlugins
, chromium
}:

let

  configFile = writeTextFile {
    name = "kitty-config";
    text = ''
      font_family        ${myConfig.fontFamily}
      italic_font        ${myConfig.fontFamily}
      bold_font          ${myConfig.fontFamily}
      bold_italic_font   ${myConfig.fontFamily}

      font_size          ${builtins.toString myConfig.fontSize}.0

      open_url_with      ${chromium}/bin/chromium
      copy_on_select     clipboard
      tab_bar_edge       top

      enable_audio_bell  no

      include ${vimPlugins."nightfox-nvim"}/extra/${myConfig.theme}/nightfox_kitty.conf
    '';
  };

in symlinkJoin {
  name = "kitty-with-config-${kitty.version}";

  paths = [ kitty ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/kitty \
      --add-flags "--config ${configFile}"
  '';

  passthru.terminfo = kitty.terminfo;
}
