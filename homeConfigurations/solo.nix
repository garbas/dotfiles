{ user, inputs, ... }: let

  homeUser = {
    inherit (user) username email fullname;
    sshKey = "${user.machines.solo.sshKey} ${user.username}@solo";
  };
in {

  imports = [
    (import ./profiles/linux.nix homeUser)
  ];

}
