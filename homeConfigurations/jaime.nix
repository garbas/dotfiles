{ user, inputs, ... }: let

  homeUser = {
    inherit (user) username email fullname;
    sshKey = "${user.machines.jaime.sshKey} ${user.username}@jaime";
  };
in {

  imports = [
    inputs.mac-app-util.homeManagerModules.default
    (import ./profiles/darwin.nix homeUser)
  ];

  programs.ssh.matchBlocks."cercei" = {
    hostname = "192.168.64.3";
    user = "rok";
    port = 22;
  };

}
