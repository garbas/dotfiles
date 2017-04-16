{ writeText, firefox, theme }:


let
  self = brightness: writeText "termite-config-${brightness}"
    (''
      [options]
      scroll_on_output = false
      scroll_on_keystroke = true
      audible_bell = false
      mouse_autohide = false
      allow_bold = true
      dynamic_title = true
      urgent_on_bell = true
      clickable_url = true

      font = Terminus 9

      scrollback_lines = 10000
      search_wrap = true
      #icon_name = terminal
      #geometry = 640x480

      # "system", "on" or "off"
      cursor_blink = system

      # "block", "underline" or "ibeam"
      cursor_shape = block

      # $BROWSER is used by default if set, with xdg-open as a fallback
      browser = ${firefox}/bin/firefox

      # set size hints for the window
      #size_hints = false

      # Hide links that are no longer valid in url select overlay mode
      filter_unmatched_urls = true

      # emit escape sequences for extra modified keys
      #modify_other_keys = false

      '' + (builtins.readFile "${theme}/termite.${brightness}"));
in {
  dark = self "dark";
  light = self "light";
  packages = {
    inherit firefox;
  };
}
