{ ... }:
{

  imports = [
    (import ./profiles/linux.nix)
  ];

  # TODO: add this to common.nix for machines with hostname defined
  #programs.ssh.matchBlocks."cercei" = {
  #  hostname = "192.168.64.3";
  #  user = "rok";
  #  port = 22;
  #};

}
