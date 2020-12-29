{ fetchurl
, writeScriptBin
, runCommand
, nix
, curl
, coreutils
, jq
, lib
, theme
}:

let
  appRepos = {
    termite = "khamer/base16-termite";
    rofi = "0xdec/base16-rofi";
    i3 = "khamer/base16-i3";
    i3status-rust = "mystfox/base16-i3status-rust";
    vim = "chriskempson/base16-vim";
    dunst = "khamer/base16-dunst";
    zathura = "HaoZeke/base16-zathura";
    fzf = "fnune/base16-fzf";
  };

  githubUrl = app:
    let
      folder =
        if app == "i3status-rust" then "colors"
        else if app == "vim" then "colors"
        else if app == "fzf" then "bash"
        else if app == "zathura" then "build_schemes"
        else "themes";
      suffix =
        if app == "rofi" then "rasi"
        else if app == "i3status-rust" then "toml"
        else if app == "vim" then "vim"
        else if app == "dunst" then "dunstrc"
        else "config";
    in
      lib.concatStringsSep "/" [
        "https://raw.githubusercontent.com"
        (appRepos."${app}")
        "master/${folder}/base16-${theme}.${suffix}"
      ];

  updateThemeScriptFor = app:
    writeScriptBin "update-${app}" ''
      >&2 echo "Fetching ${app}"
      sha256=$(${nix}/bin/nix-prefetch-url ${githubUrl app})
      rev=$(${curl}/bin/curl https://api.github.com/repos/${appRepos."${app}"}/git/ref/heads/master | ${jq}/bin/jq -r '.object.sha')
      echo "{ \"rev\": \"$rev\", \"sha256\": \"$sha256\" }"
      >&2 echo ""
    '';

  updateThemeScriptForAll =
    let
      apps = builtins.attrNames appRepos;
    in writeScriptBin "update-all"
      (builtins.concatStringsSep "\n"
        (
          [''echo "{"''] ++
          (builtins.map
            (app: 
              let
                comma = if app == lib.last apps then "" else ",";
              in ''
                echo "  \"${app}\": $(${updateThemeScriptFor app}/bin/update-${app})${comma}"
              ''
            )
            apps
          ) ++
          [''echo "}"'']
        )
      );

  configureApp = app:
    let
      getAttr = name: set: default:
        if builtins.hasAttr name set
        then builtins.getAttr name set
        else default;

      appData = if builtins.pathExists ./theme.json
        then getAttr app (builtins.fromJSON (builtins.readFile ./theme.json)) {}
        else {};

      src = fetchurl {
        url = githubUrl app;
        inherit sha256;
      };

      rev = getAttr "rev" appData "0000000000000000000000000000000000000000";
      sha256 = getAttr "sha256" appData "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    in {
      "update-${app}" = updateThemeScriptFor app;
      "${app}" = runCommand "${app}-theme-${theme}"
        {
          preferLocalBuild = true;
          allowSubstitutes = false;
        }
        ''
          # Remove all control characters
          ${coreutils}/bin/tr -dc '\007-\011\012-\015\040-\376' < ${src} >> $out
        '';
    };

in
  { name = theme;
    update-all = updateThemeScriptForAll;
  } //
  (configureApp "termite") //
  (configureApp "rofi") //
  (configureApp "i3") //
  (configureApp "i3status-rust") //
  (configureApp "vim") //
  (configureApp "vim-airline") //
  (configureApp "dunst") //
  (configureApp "zathura") //
  (configureApp "fzf") //
  {}
