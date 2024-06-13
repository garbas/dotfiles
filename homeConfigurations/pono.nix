{ ... }: let
  config = {
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICut/WcUHHbTfFiE+5OHIrQguBbC7bXgkRwbPqEK0PcD rok@pono";
      username = "rok";
      email = "rok@flox.dev";
      fullname = "Rok Garbas";
  };
in {
  imports = [
    (import ./profiles/linux.nix config)
  ];
}
