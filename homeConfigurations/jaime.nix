{ user, ... }:
{

  imports = [
    (import ./profiles/darwin.nix)
  ];

  programs.ssh.matchBlocks."cercei" = {
    hostname = "192.168.64.3";
    user = user.username;
    port = 22;
  };

}
