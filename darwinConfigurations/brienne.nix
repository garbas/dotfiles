{
  pkgs,
  user,
  hostname,
  inputs,
  ...
}:
{

  imports = [
    ./profiles/common.nix
  ];

  nix.useDaemon = true;
  nix.extraOptions = ''
    ssl-cert-file = /etc/nix/nix-and-certs.crt
  '';
}
