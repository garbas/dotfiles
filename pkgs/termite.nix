{ default
, theme

, termite

, writeTextFile
}:

let

  config = ''
    [options]
    allow_bold = true
    audible_bell = false
    bold_is_bright = true
    browser = xdg-open
    cell_height_scale = 1.0
    cell_width_scale = 1.0
    clickable_url = true
    cursor_blink = off
    cursor_shape = ibeam
    dynamic_title = true
    filter_unmatched_urls = true
    font = ${default.font} ${default.fontSize}
    fullscreen = true
    hyperlinks = false
    icon_name = terminal
    modify_other_keys = false
    mouse_autohide = false
    scroll_on_keystroke = true
    scroll_on_output = false
    scrollback_lines = 10000000
    scrollbar = off
    search_wrap = true
    size_hints = false
    urgent_on_bell = true

    [hints]
    active_background = #3f3f3f
    active_foreground = #e68080
    background = #3f3f3f
    border = #3f3f3f
    border_width = 0.5
    font = ${default.font} ${default.fontSize}
    foreground = #dcdccc
    padding = 2
    roundness = 2.0

    ${builtins.readFile theme.termite}
  '';


  configFile = writeTextFile {
    name = "termite-config-with-${theme.name}-theme";
    text = config;
  };

in termite.override { inherit configFile; }
