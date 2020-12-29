{ default
, theme

, i3status-rust

, makeWrapper
, symlinkJoin
, writeTextFile
}:

let
  config = ''
    ${builtins.readFile theme.i3status-rust}

    [icons]
    name = "awesome"

    [[block]]
    block = "disk_space"
    path = "/"
    alias = "/"
    info_type = "available"
    unit = "GB"
    interval = 20

    [[block]]
    block = "battery"
    interval = 10
    format = "{percentage}% {time}"

    [[block]]
    block = "keyboard_layout"
    driver = "setxkbmap"
    interval = 15

    [[block]]
    block = "sound"
    step_width = 5


    [[block]]
    block = "time"
    format = "%a %d/%m/%Y %R"
    timezone = "Europe/Ljubljana"
    interval = 60

    #[[block]]
    #block = "notmuch"
    #query = "tag:alert and not tag:trash"
    #threshold_warning = 1
    #threshold_critical = 10
    #name = "A"
  '';

  configFile = writeTextFile {
    name = "i3status-rust-config-with-${theme.name}-theme";
    text = config;
  };

in symlinkJoin {
  name = "i3status-rust-with-config-${i3status-rust.version}";

  paths = [
    i3status-rust.out
  ];

  buildInputs = [ makeWrapper ];
  preferLocalBuild = true;
  allowSubstitutes = false;
  passthru.unwrapped = i3status-rust;

  postBuild = ''
    rm $out/bin/i3status-rs
    makeWrapper ${i3status-rust}/bin/i3status-rs $out/bin/i3status-rs --add-flags "${configFile}"
  '';

  meta = i3status-rust.meta // {
    priority = (i3status-rust.meta.priority or 0) - 1;
  };
}

