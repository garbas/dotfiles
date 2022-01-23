{ myConfig

, rofi-unwrapped

# plugins
, rofi-calc
, rofi-emoji
#, rofi-file-browser

, makeWrapper
, symlinkJoin
, hicolor-icon-theme
, lib
, writeTextFile
}:

let
  theme = writeTextFile {
    name = "rofi-nord-theme.rofi";
    text = ''
      /*******************************************************************************
       * ROFI VERTICAL THEME USING THE NORD COLOR PALETTE 
       * User                 : LR-Tech               
       * Theme Repo           : https://github.com/lr-tech/rofi-themes-collection
       * Nord Project Repo    : https://github.com/arcticicestudio/nord
       *******************************************************************************/

      * {
          font:   "${myConfig.fontFamily} ${builtins.toString myConfig.fontSize}";

          nord0:     #2e3440;
          nord1:     #3b4252;
          nord2:     #434c5e;
          nord3:     #4c566a;

          nord4:     #d8dee9;
          nord5:     #e5e9f0;
          nord6:     #eceff4;

          nord7:     #8fbcbb;
          nord8:     #88c0d0;
          nord9:     #81a1c1;
          nord10:    #5e81ac;
          nord11:    #bf616a;

          nord12:    #d08770;
          nord13:    #ebcb8b;
          nord14:    #a3be8c;
          nord15:    #b48ead;

          background-color:   transparent;
          text-color:         @nord4;
          accent-color:       @nord8;

          margin:     0px;
          padding:    0px;
          spacing:    0px;
      }

      window {
          background-color:   @nord0;
          border-color:       @accent-color;

          location:   center;
          width:      960px;
          y-offset:   -320px;
          border:     1px;
      }

      inputbar {
          padding:    8px 12px;
          spacing:    12px;
          children:   [ prompt, entry ];
      }

      prompt, entry, element-text, element-icon {
          vertical-align: 0.5;
      }

      prompt {
          text-color: @accent-color;
      }

      listview {
          lines:      8;
          columns:    1;

          fixed-height:   false;
      }

      element {
          padding:    8px;
          spacing:    8px;
      }

      element normal urgent {
          text-color: @nord13;
      }

      element normal active {
          text-color: @accent-color;
      }

      element selected {
          text-color: @nord0;
      }

      element selected normal {
          background-color:   @accent-color;
      }

      element selected urgent {
          background-color:   @nord13;
      }

      element selected active {
          background-color:   @nord8;
      }

      element-icon {
          size:   0.75em;
      }

      element-text {
          text-color: inherit;
      }
    '';
  };

  config = {
    font = "${myConfig.fontFamily} ${builtins.toString myConfig.fontSize}";
    show-match = true;
    theme = theme;
    padding = 100;
    lines = 10;
    terminal = myConfig.terminal;
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
