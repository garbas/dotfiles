user: { ... }: let

  homeUser = {
    inherit (user) username email fullname;
    sshKey = "${user.machines.jaime.sshKey} ${user.username}@jaime";
  };
in {

  imports = [
    (import ./profiles/darwin.nix homeUser)
  ];

  programs.ssh.matchBlocks."cercei" = {
    hostname = "192.168.64.3";
    user = "rok";
    port = 22;
  };

}
