{ xinput, xset, xmodmap, setxkbmap }:
''
  # http://www.thinkwiki.org/wiki/How_to_configure_the_TrackPoint#Configuration_using_the_X_server_.28xorg.conf.29
  for id in `${xinput}/bin/xinput list |grep -i trackpoint |cut -d= -f2 |cut -d'[' -f1`; do
      ${xinput}/bin/xinput set-int-prop $id "Evdev Wheel Emulation" 8 1 2>/dev/null &
      ${xinput}/bin/xinput set-int-prop $id "Evdev Wheel Emulation Button" 8 2 2>/dev/null &
      ${xinput}/bin/xinput set-int-prop $id "Evdev Wheel Emulation Timeout" 8 200 2>/dev/null &
      ${xinput}/bin/xinput set-int-prop $id "Evdev Wheel Emulation Axes" 8 6 7 4 5 2>/dev/null &
  done
  for id in `${xinput}/bin/xinput list |grep -i touchpad |cut -d= -f2 |cut -d'[' -f1`; do
      ${xinput}/bin/xinput set-prop $id "Device Enabled" 0 2>/dev/null &
  done

  # bell off
  ${xset}/bin/xset b off &

  ${setxkbmap}/bin/setxkbmap -model thinkpad60 -layout us
  ${xmodmap}/bin/xmodmap /etc/Xmodmap
  ${xset}/bin/xset r rate 250 100

  # checking out different mouse behaviour
  ${xset}/bin/xset m 3 0 &
''
