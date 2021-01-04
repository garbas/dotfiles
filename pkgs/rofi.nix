{ default
, theme

, rofi-unwrapped

# plugins
, rofi-calc
, rofi-emoji
#, rofi-file-browser

, makeWrapper
, symlinkJoin
, hicolor-icon-theme
, lib

}:

let
  config = {
    font = "Fira Code 20";
    show-match = true;
    theme = theme.rofi;
    padding = 100;
    lines = 10;
    terminal = default.terminal;
    sidebar-mode = true;
    show-icons = true;
    cycle = true;
    hide-scrollbar = true;
    disable-history = false;
    sort = true;
    #modi = "drun,file-browser,combi,calc,emoji";
    modi = "drun,combi,calc,emoji";
    display-drun = "🧭";
    display-combi = "🪟";
    display-emoji = "😆";
    display-calc = "🧮";
    #display-file-browser = "📁";
  };

  plugins =
    [ rofi-calc
      rofi-emoji
      #rofi-file-browser
    ];

  configArgs =
    lib.concatStringsSep " "
      (builtins.attrValues
        (builtins.mapAttrs
          (name: value:
            if builtins.isBool value
            then
              (if value == true
               then ''--add-flags "-${name}"''
               else ''--add-flags "-no-${name}"''
              )
            else
              ''--add-flags "-${name} \"${builtins.toString value}\""''
          )
          config
        )
      );

  pluginsArgs = 
    lib.optionalString
      (plugins != [])
      (
        ''--add-flags "-plugin-path $out/lib/rofi" '' +
        ''--prefix XDG_DATA_DIRS : ${lib.concatStringsSep ":" (lib.forEach plugins (p: "${p.out}/share"))}''
      );

in symlinkJoin {
  name = "rofi-with-config-${rofi-unwrapped.version}";

  paths = [
    rofi-unwrapped.out
  ] ++ (lib.forEach plugins (p: p.out));

  buildInputs = [ makeWrapper ];
  preferLocalBuild = true;
  allowSubstitutes = false;
  passthru.unwrapped = rofi-unwrapped;

  postBuild = ''
    rm -rf $out/bin
    mkdir $out/bin
    ln -s ${rofi-unwrapped}/bin/* $out/bin

    rm $out/bin/rofi
    makeWrapper ${rofi-unwrapped}/bin/rofi $out/bin/rofi \
      --prefix XDG_DATA_DIRS : ${hicolor-icon-theme}/share \
      ${configArgs} ${pluginsArgs}

    rm $out/bin/rofi-theme-selector
    makeWrapper ${rofi-unwrapped}/bin/rofi-theme-selector $out/bin/rofi-theme-selector \
      --prefix XDG_DATA_DIRS : $out/share
  '';

  meta = rofi-unwrapped.meta // {
    priority = (rofi-unwrapped.meta.priority or 0) - 1;
  };
}
