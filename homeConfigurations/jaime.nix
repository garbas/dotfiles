{ ... }: {

  imports = [
    (import ./profiles/darwin.nix {
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKex8HTaW5y1IrhxVKU4r9XfLNWl6kvzpBF74VXovfPu rok@jaime";
      username = "rok";
      email = "rok@garbas.si";
      fullname = "Rok Garbas";
    })
  ];

  programs.ssh.matchBlocks."cercei" = {
    hostname = "192.168.64.3";
    user = "rok";
    port = 22;
  };

}
