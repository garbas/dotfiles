{ myConfig
, i3
, makeWrapper
, symlinkJoin
, writeTextFile
}:

let
  config = ''
    # i3 config file (v4)
    #
    # Please see https://i3wm.org/docs/userguide.html for a complete reference!

    set $mod Mod4

    font pango:${myConfig.fontFamily} ${builtins.toString (myConfig.fontSize / 3)}

    # Use Mouse+$mod to drag floating windows to their wanted position
    floating_modifier $mod

    # start a terminal
    bindsym $mod+Return exec ${myConfig.terminal}

    # kill focused window
    bindsym $mod+Shift+q kill

    # start dmenu (a program launcher)
    bindsym $mod+space exec --no-startup-id rofi -show drun

    # change focus
    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right

    # move focused window
    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up
    bindsym $mod+Shift+l move right

    # split in horizontal orientation
    bindsym $mod+x split h

    # split in vertical orientation
    bindsym $mod+z split v

    # enter fullscreen mode for the focused container
    bindsym $mod+f fullscreen toggle

    # change container layout (stacked, tabbed, toggle split)
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split

    # change between 2 recent workspaces
    bindsym $mod+Tab workspace back_and_forth

    # focus the parent container
    bindsym $mod+a focus parent

    # focus the child container
    bindsym $mod+d focus child

    # toggle tiling / floating
    bindsym $mod+Shift+space floating toggle

    # Make the currently focused window a scratchpad
    bindsym $mod+Shift+BackSpace move scratchpad

    # Show the first scratchpad window
    bindsym $mod+BackSpace scratchpad show

    # Define names for default workspaces for which we configure key bindings later on.
    # We use variables to avoid repeating the names in multiple places.
    set $ws01 1 
    set $ws02 2 
    set $ws03 3 
    set $ws04 4 
    set $ws05 5 
    set $ws06 6 
    set $ws07 7 
    set $ws08 8 
    set $ws09 9 
    set $ws10 10 

    #set $center_screen HDMI-1
    #set $left_screen HDMI-1

    #set $left_screen DP-1-1
    #set $right_screen DP-1-2
    set $left_screen DP-2-1
    set $right_screen DP-2-2

    set $laptop_screen eDP-1

    #set $left_screen DP-1-1
    #set $right_screen DP-1-2

    # assign workspace to screen
    workspace "$ws01" output $laptop_screen
    workspace "$ws02" output $left_screen
    workspace "$ws03" output $left_screen
    workspace "$ws04" output $left_screen
    workspace "$ws05" output $left_screen
    workspace "$ws06" output $left_screen
    workspace "$ws07" output $right_screen
    workspace "$ws08" output $right_screen
    workspace "$ws09" output $right_screen
    workspace "$ws10" output $right_screen

    # switch to workspace
    bindsym $mod+1 workspace $ws01
    bindsym $mod+2 workspace $ws02
    bindsym $mod+3 workspace $ws03
    bindsym $mod+4 workspace $ws04
    bindsym $mod+5 workspace $ws05
    bindsym $mod+6 workspace $ws06
    bindsym $mod+7 workspace $ws07
    bindsym $mod+8 workspace $ws08
    bindsym $mod+9 workspace $ws09
    bindsym $mod+0 workspace $ws10

    # move focused container to workspace
    bindsym $mod+Shift+1 move container to workspace $ws01
    bindsym $mod+Shift+2 move container to workspace $ws02
    bindsym $mod+Shift+3 move container to workspace $ws03
    bindsym $mod+Shift+4 move container to workspace $ws04
    bindsym $mod+Shift+5 move container to workspace $ws05
    bindsym $mod+Shift+6 move container to workspace $ws06
    bindsym $mod+Shift+7 move container to workspace $ws07
    bindsym $mod+Shift+8 move container to workspace $ws08
    bindsym $mod+Shift+9 move container to workspace $ws09
    bindsym $mod+Shift+0 move container to workspace $ws10


    # reload the configuration file
    bindsym $mod+Shift+c reload
    # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
    bindsym $mod+Shift+r restart
    # exit i3 (logs you out of your X session)
    #bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"
    bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'xfce4-session-logout'"

    bindsym $mod+t border normal
    bindsym $mod+y border 1pixel
    bindsym $mod+u border none
    bindsym $mod+b border toggle

    # from `pactl list sinks| grep Name`
    set $out_sink alsa_output.pci-0000_00_1f.3.analog-stereo
    # from `pactl list sources | grep Name`
    set $in_source alsa_input.pci-0000_00_1f.3.analog-stereo

    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume $out_sink +5% && killall -s USR1 py3status
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume $out_sink -5% && killall -s USR1 py3status
    bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute $out_sink toggle && killall -s USR1 py3status
    bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute $in_source toggle && killall -s USR1 py3status
    bindsym XF86MonBrightnessDown exec --no-startup-id xbacklight -dec 5 && killall -s USR1 py3status
    bindsym XF86MonBrightnessUp exec --no-startup-id xbacklight -inc 10 && killall -s USR1 py3status

    # resize window (you can also use the mouse for that)
    mode "resize" {
            # These bindings trigger as soon as you enter the resize mode

            # Pressing left will shrink the window’s width.
            # Pressing right will grow the window’s width.
            # Pressing up will shrink the window’s height.
            # Pressing down will grow the window’s height.
            bindsym h resize shrink width 10 px or 10 ppt
            bindsym j resize grow height 10 px or 10 ppt
            bindsym k resize shrink height 10 px or 10 ppt
            bindsym l resize grow width 10 px or 10 ppt

            # back to normal: Enter or Escape or $mod+r
            bindsym Return mode "default"
            bindsym Escape mode "default"
            bindsym $mod+r mode "default"
    }

    bindsym $mod+r mode "resize"

    # Nord theme
    # -> https://github.com/sarveshspatil111/i3wm-nord/blob/main/.config/i3/config#L414
    set $base00 #101218
    set $base01 #1f222d
    set $base02 #252936
    set $base03 #5e81ac
    set $base04 #C0C5CE
    set $base05 #d1d4e0
    set $base06 #C9CCDB
    set $base07 #ffffff
    set $base08 #ee829f
    set $base09 #f99170
    set $base0A #ffefcc
    set $base0B #a5ffe1
    set $base0C #97e0ff
    set $base0D #97bbf7
    set $base0E #c0b7f9
    set $base0F #fcc09e

    # Start i3bar to display a workspace bar (plus the system information
    # i3status finds out, if available)
    bar {
      position bottom
      status_command i3status-rs
      tray_output $laptop_screen
      tray_padding 0
      separator_symbol "‖"

      colors {
        separator  $base01
        background $base01
        statusline #81a1c1

        #                   border  background text
        focused_workspace  $base01 $base01    #81a1c1 
        active_workspace   $base01 $base02    $base03
        inactive_workspace $base01 $base01    #4c566a
        urgent_workspace   $base01 $base01    $base08
        binding_mode       $base01 #81a1c1    #2e3440
      }
    }

    # Window color settings
    # class                 border  backgr. text    indicator
    client.focused          #81a1c1 #81a1c1 #ffffff #81a1c1
    client.unfocused        #2e3440 #2e3440 #888888 #2e3440
    client.focused_inactive #2e3440 #2e3440 #888888 #2e3440
    client.placeholder      #2e3440 #2e3440 #888888 #2e3440
    client.urgent           #900000 #900000 #ffffff #900000

    client.background       #242424

    for_window [class="Firefox" window_role="About"] floating enable
    for_window [class="pavucontrol"] floating enable
    for_window [class="VidyoDesktop"] floating enable
    for_window [class="zoom" instance="zoom"] floating enable
    for_window [class="1Password"] floating enable

    exec --no-startup-id nm-applet
    exec --no-startup-id pasystray
    exec --no-startup-id element-desktop --no-update --hidden
    exec --no-startup-id blueman-applet

    for_window [class="^.*"] border pixel 1
  '';

  configFile = writeTextFile {
    name = "i3-config-with-${myConfig.theme}-theme";
    text = config;
  };

in symlinkJoin {
  name = "i3-with-config-${i3.version}";

  paths = [
    i3.out
  ];

  buildInputs = [ makeWrapper ];
  preferLocalBuild = true;
  allowSubstitutes = false;
  passthru.unwrapped = i3;

  postBuild = ''
    rm $out/bin/i3
    makeWrapper ${i3}/bin/i3 $out/bin/i3 --add-flags "-c ${configFile}"
  '';

  meta = i3.meta // {
    priority = (i3.meta.priority or 0) - 1;
  };
}
