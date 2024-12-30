{ ... }:
let
  config = {
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZr0HtRTIngjPGi4yliL4vffUYxx1OMCcfHcecAhgO5 rok@cercei";
    username = "rok";
    email = "rok@garbas.si";
    fullname = "Rok Garbas";
  };
in
{
  imports = [
    (import ./profiles/linux.nix config)
    (import ./profiles/wayland.nix (
      config
      // {
        bluetooth = false;
        outputs = {
          left = {
            monitor = "Virtual-1";
            pos = "0 0";
            scale = "2";
            res = "3840x2160";
            workspaces = [
              "1"
              "2"
              "3"
              "4"
              "5"
              "6"
              "7"
              "8"
              "9"
              "10"
            ];
          };
          #center = {
          #  monitor = "DP-6";
          #};
          #right = {
          #  monitor = "DP-5";
          #};
        };
      }
    ))
  ];
}
