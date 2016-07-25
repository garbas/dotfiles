{ writeText }:

let
  self = writeText "config-xmodmap"
    ''
      ! Clear modifiers
      clear lock
      clear mod1
      clear mod4
      clear mod5

      ! for awesome it is convenient to have two mod4, one for each hand
      ! between left ctrl and left alt
      ! XXX: arent these the defaults?
      keycode 133 = Super_L
      ! left of space
      keycode  64 = Alt_L
      ! right of space
      keycode 108 = ISO_Level3_Shift

      ! Caps lock as control, normal controls disabled
      keycode  66 = Control_L

      ! the key between right alt and ctrl serves as level3 shift
      keycode 135 = Super_R

      ! cursor keys are on Alt_R/level3 + i/j/k/l
      ! educative measure til the cursor keys get some more appropriate job
      !keycode 111 =
      !keycode 113 =
      !keycode 114 =
      !keycode 116 =

      add control = Control_L
      add mod1 = Alt_L
      add mod4 = Super_L Super_R
      add mod5 = ISO_Level3_Shift
    '';
in {
  light = self;
  dark = self;
  packages = {};
}
