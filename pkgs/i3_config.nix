{ i3, i3status, xrandr, feh, py3status, lib, rofi-menugen, writeScript
, termite, ipython, gnome_keyring, redshift, alot, networkmanagerapplet
, base16, rofi, rofi-pass, i3lock-fancy, xbacklight
, base16Theme, i3_tray_output, themeDark, themeLigth
}:

let

  i3Theme = builtins.readFile "${base16}/i3/base16-${base16Theme}.i3";
  getColors = theme: builtins.head (
    lib.splitString "\n\n## remember to add the rest of your configuration" theme);
  getBarColors = theme: builtins.head (
    lib.splitString "\n    }" (
      builtins.head (builtins.tail (
        lib.splitString "\n        colors {" theme))
    ));
  powerManagement = writeScript "rofi-power-management" ''
    #!${rofi-menugen}/bin/rofi-menugen
    #begin main
    prompt="Select:"
    add_exec 'Lock'         '${i3lock-fancy}/bin/i3lock-fancy'
    add_exec 'Sleep'        'systemctl suspend'
    add_exec 'Reboot'       'systemctl reboot'
    add_exec 'PowerOff'     'systemctl poweroff'
    #end main
  '';
  brigtnessManagement = writeScript "rofi-brigtness-management" ''
    #!${rofi-menugen}/bin/rofi-menugen
    #begin main
    prompt="Brigtness:"
    add_exec   "0" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 0"
    add_exec  "10" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 10"
    add_exec  "20" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 20"
    add_exec  "30" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 30"
    add_exec  "40" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 40"
    add_exec  "50" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 50"
    add_exec  "60" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 60"
    add_exec  "70" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 70"
    add_exec  "80" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 80"
    add_exec  "90" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 90"
    add_exec "100" "${xbacklight}/bin/xbacklight -time 500 -steps 30 -set 100"
    #end main
  '';
    
in ''
# Please see http://i3wm.org/docs/userguide.html for a complete reference!

#{{{ Main

set $mod Mod4

# monitors
set $mon_lap ${i3_tray_output}
set $mon_ext VGA1

# > horizontal | vertical | auto
default_orientation horizontal

# > default | stacking | tabbed
workspace_layout default

# > normal | 1pixel | none
new_window 1pixel

# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod

#}}}
#{{{ Modes
#{{{   Monitor mode
mode "monitor_select" {

  # only one
  bindsym 1 exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --auto --output $mon_ext --off --output $mon_ext1 --off --output $mon_ext2 --off ; mode "default"

  # office
  bindsym o exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --auto --output $mon_ext2 --auto --left-of $mon_lap ; mode "default"
  #bindsym o exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --auto --output $mon_ext2 --rotate left --auto --left-of $mon_lap ; mode "default"

  # left and right
  bindsym l exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --auto --output $mon_ext --auto --left-of $mon_lap ; mode "default"
  bindsym r exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --auto --output $mon_ext --auto --right-of $mon_lap ; mode "default"

  # up and down
  bindsym u exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --auto --output $mon_ext --auto --above $mon_lap ; mode "default"
  bindsym d exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --auto --output $mon_ext --auto --below $mon_lap ; mode "default"

  # clone
  bindsym c exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --auto --output $mon_ext --auto --same-as $mon_lap ; mode "default"

  # presentation
  bindsym p exec --no-startup-id ${xrandr}/bin/xrandr --output $mon_lap --off --output $mon_ext1 --auto ; mode "default"

  # back to normal: Enter or Escape
  bindsym Return mode "default"
  bindsym Escape mode "default"
}
#}}}
#}}}
#{{{ Fonts

font pango:monospace 11px
# font for window titles. ISO 10646 = Unicode
# font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1
# font -*-terminus-medium-r-normal-*-14-*-*-*-c-*-iso10646-1
#font -*-terminus-medium-r-normal-*-12-120-72-72-c-60-iso10646-1

#}}}
#{{{ Workspaces
set $w1 1: web
set $w2 2: vim
set $w3 3: dev1
set $w4 4: dev2
set $w5 5: dev3
set $w6 6:
set $w7 7:
set $w8 8:
set $w9 9: irc
set $w10 10: email

workspace "$w1" output $mon_ext
workspace "$w2" output $mon_ext
workspace "$w3" output $mon_ext
workspace "$w4" output $mon_ext
workspace "$w5" output $mon_ext
workspace "$w6" output $mon_ext
workspace "$w7" output $mon_lap
workspace "$w8" output $mon_lap
workspace "$w9" output $mon_lap
workspace "$w10" output $mon_lap

# switch to workspace
bindsym $mod+1 workspace $w1
bindsym $mod+2 workspace $w2
bindsym $mod+3 workspace $w3
bindsym $mod+4 workspace $w4
bindsym $mod+5 workspace $w5
bindsym $mod+6 workspace $w6
bindsym $mod+7 workspace $w7
bindsym $mod+8 workspace $w8
bindsym $mod+9 workspace $w9
bindsym $mod+0 workspace $w10

# move focused container to workspace
bindsym $mod+Shift+exclam move workspace $w1
bindsym $mod+Shift+at move workspace $w2
bindsym $mod+Shift+numbersign move workspace $w3
bindsym $mod+Shift+dollar move workspace $w4
bindsym $mod+Shift+percent move workspace $w5
bindsym $mod+Shift+asciicircum move workspace $w6
bindsym $mod+Shift+ampersand move workspace $w7
bindsym $mod+Shift+asterisk move workspace $w8
bindsym $mod+Shift+parenleft move workspace $w9
bindsym $mod+Shift+parenright move workspace $w10

bindsym $mod+Tab workspace back_and_forth

bindsym $mod+grave workspace prev
bindsym $mod+minus workspace prev
bindsym $mod+equal workspace next

bindsym $mod+m mode "monitor_select"

#}}}
#{{{ Windows
#{{{   Change focus

# change focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# focus the parent container
#bindsym $mod+a focus parent

# focus the child container
#bindcode $mod+d focus child

#}}}
#{{{   Move

# move focused window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

#}}}
#{{{   Split

#split in horizontal orientation
bindsym $mod+x split h

# split in vertical orientation
bindsym $mod+z split v

#}}}
#{{{   Resize

mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        # They resize the border in the direction you pressed, e.g.
        # when pressing left, the window is resized so that it has
        # more space on its left

bindsym j resize shrink left 10 px or 10 ppt
bindsym Shift+J resize grow left 10 px or 10 ppt

bindsym k resize shrink down 10 px or 10 ppt
bindsym Shift+K resize grow down 10 px or 10 ppt

bindsym l resize shrink up 10 px or 10 ppt
bindsym Shift+L resize grow up 10 px or 10 ppt

bindsym semicolon resize shrink right 10 px or 10 ppt
bindsym Shift+colon resize grow right 10 px or 10 ppt

        # same bindings, but for the arrow keys
bindsym Left resize shrink left 10 px or 10 ppt
bindsym Shift+Left resize grow left 10 px or 10 ppt

bindsym Down resize shrink down 10 px or 10 ppt
bindsym Shift+Down resize grow down 10 px or 10 ppt

bindsym Up resize shrink up 10 px or 10 ppt
bindsym Shift+Up resize grow up 10 px or 10 ppt

bindsym Right resize shrink right 10 px or 10 ppt
bindsym Shift+Right resize grow right 10 px or 10 ppt

        # back to normal: Enter or Escape
bindsym Return mode "default"
bindsym Escape mode "default"
}

bindsym $mod+r mode "resize"
#}}}
#{{{   Tiling / Floating / Fullscreen

# toggle tiling / floating
bindsym $mod+Shift+g floating toggle

# change focus between tiling / floating windows
bindsym $mod+g focus mode_toggle

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen

#}}}
#{{{   Layout

# change container layout (stacked, tabbed, default)
bindsym $mod+e layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+q layout default

#}}}
#{{{   Other

bindsym $mod+t border normal
bindsym $mod+y border 1pixel
bindsym $mod+u border none

#}}}
#}}}
#{{{ Applications
#{{{   Shortcuts

#bindsym Mod4+l exec xset s activate

# rofi program launcher
bindsym $mod+space exec --no-startup-id ${i3}/bin/i3-dmenu-desktop --dmenu='${rofi}/bin/rofi -fuzzy -dmenu -p "run:"'
bindsym $mod+Shift+space exec --no-startup-id ${rofi}/bin/rofi -fuzzy -show window
bindsym $mod+Shift+p exec --no-startup-id ${rofi-pass}/bin/rofi-pass
bindsym $mod+Shift+o exec --no-startup-id ${powerManagement}
bindsym $mod+Shift+b exec --no-startup-id ${brigtnessManagement}

# start a terminal
bindsym $mod+Return exec ${termite}/bin/termite

# ipython
bindsym $mod+Shift+i [instance="ipython"] scratchpad show
for_window [instance="ipython"] move scratchpad
for_window [instance="ipython"] floating enable

# alot
bindsym $mod+Shift+m [instance="alot"] scratchpad show
for_window [instance="alot"] move scratchpad
for_window [instance="alot"] floating enable

# weechat
bindsym $mod+Shift+u [instance="weechat"] scratchpad show
for_window [instance="weechat"] move scratchpad
for_window [instance="weechat"] floating enable

#}}}
#{{{   Assigns

#assign [class="Opera"] $w3
#assign [class="Chromium"] $w3
#assign [class="Firefox"] $w3
#assign [class="Nightly"] $w3
#assign [class="Gvim"] $w2

#}}}
#{{{ Other shortcuts

# Make the currently focused window a scratchpad
bindsym $mod+Ctrl+BackSpace move scratchpad

# Show the first scratchpad window
bindsym $mod+BackSpace scratchpad show

# kill focused window
bindsym $mod+Shift+Q kill

# focus the parent container
bindsym $mod+a focus parent

# focus the child container
#bindcode $mod+d focus child

# reload the configuration file
bindsym $mod+Shift+C exec "${themeLigth} && i3-msg reload"
bindsym $mod+Shift+D exec "${themeDark} && i3-msg reload"

# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+R restart


# exit i3 (logs you out of your X session)
bindsym $mod+Shift+E exit

# }}}
#}}}
#{{{ Colors

${getColors i3Theme}

#}}}
#{{{ i3bar
# Start i3bar to display a workspace bar (plus the system information i3status
# finds out, if available)
bar {
    status_command ${py3status}/bin/py3status -c /etc/i3status-config
    position bottom
    tray_output $mon_lap
#{{{ i3bar colors
    colors {
${getBarColors i3Theme}
    }
#}}}
}
#}}}
#{{{ Autostart

# TODO: move this section to systemd
exec --no-startup-id ${feh}/bin/feh  --bg-scale $HOME/wallpaper_latest.png
exec_always xset s 900
exec --no-startup-id ${networkmanagerapplet}/bin/nm-applet
exec --no-startup-id ${termite}/bin/termite --name alot -e ${alot}/bin/alot
exec --no-startup-id ${termite}/bin/termite --name ipython -e ${ipython}/bin/ipython
exec --no-startup-id ${gnome_keyring}/bin/gnome-keyring
exec --no-startup-id ${redshift}/bin/redshift -l 46.055556:14.508333 -t 5700:3600

# }}}
''
