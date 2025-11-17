{
  config,
  pkgs,
  lib,
  modulesPath,
  user,
  hostname,
  inputs,
  customVimPlugins,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.home-manager.nixosModules.home-manager
    ./profiles/console.nix
  ];

  # -- HARDWARE ---------------------------------------------------------------

  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [ ];
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2f54e8e6-ff9c-497a-88ea-ce159f6cd283";
    fsType = "ext4";
  };

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 2;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    8888
    25565
  ];
  networking.firewall.allowedUDPPorts = [ 25565 ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 60000;
      to = 61000;
    }
  ];

  # -- HOME MANAGER -----------------------------------------------------------

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit
      user
      inputs
      hostname
      customVimPlugins
      ;
  };
  home-manager.backupFileExtension = "backup";
  home-manager.users.${user.username} = import ./../homeConfigurations/profiles/linux.nix;

  # ---------------------------------------------------------------------------

  # TODO:
  #  # https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
  #  services.nginx.enable = true;
  #  services.nginx.recommendedGzipSettings = true;
  #  services.nginx.recommendedOptimisation = true;
  #  services.nginx.recommendedProxySettings = true;
  #  services.nginx.recommendedTlsSettings = true;
  #  services.nginx.sslProtocols = "TLSv1.2";
  #  services.nginx.sslCiphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256";
  #  services.nginx.sslDhparam = "/etc/ssl/certs/dhparam.pem";
  #  services.nginx.statusPage = true;
  #  services.nginx.appendHttpConfig = ''
  #    limit_req_zone $binary_remote_addr zone=weechat:10m rate=5r/m;  # Setup brute force protection
  #  '';
  #  services.nginx.virtualHosts =
  #    { "garbas.si" =
  #        { default = true;
  #          forceSSL = true;
  #          enableACME = true;
  #          extraConfig = ''
  #            ssl_session_tickets  off;
  #          '';
  #          locations =
  #            { "/" =
  #                { root = "/var/www/garbas.si";
  #                  extraConfig = ''
  #                    add_header           X-Frame-Options SAMEORIGIN;
  #                    add_header           X-Content-Type-Options nosniff;
  #                    add_header           X-XSS-Protection "1; mode=block";
  #                    add_header           Content-Security-Policy "default-src 'self';script-src 'self' www.google-analytics.com;img-src 'self' www.google-analytics.com;";
  #                    add_header           Strict-Transport-Security "max-age=15768000; includeSubDomains; preload";
  #                  '';
  #                };
  #            };
  #
  #        };
  #      "url.garbas.si" =
  #        { forceSSL = true;
  #          enableACME = true;
  #          acmeRoot = "/var/www/challenges";
  #          extraConfig = ''
  #            ssl_session_tickets  off;
  #          '';
  #          locations =
  #            { "/" =
  #                { proxyPass = "http://localhost:8123";
  #                };
  #            };
  #        };
  #    };
  #
  #  security.acme.acceptTerms = true;
  #  security.acme.defaults.email = user.email;
  security.sudo.enable = true;

  #users.users.root.hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
  #users.users."nginx".extraGroups = [ "rok" ];
  #users.users.${user.username} =
  #  { hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
  #    isNormalUser = true;
  #    uid = 1000;
  #    description = "Rok Garbas";
  #    extraGroups = [
  #      "wheel"  # sudo
  #      "nginx"  # to publish
  #    ] ;
  #    group = "users";
  #    home = "/home/rok";
  #    openssh.authorizedKeys.keys = [
  #      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHuU8Wfp2mqniuQ3aKG8nyfOYY08DTg889GJPRa2rDe rok@phone"
  #      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8XQFxgFa4mEE0sPOMyJuc002FJf8z3F7S1b5lUSrsN rok@drogo"
  #      "ssh-dss AAAAB3NzaC1kc3MAAACBAMSjkowfIlAJn80+5ccsUpG0Dsunbg9nVzGJF4ZU2QlcqC8Hbw7WzhvUgqE5HY4eFxdrbX5nISZTokOT2lyoRH2bIbcCILFwFOoUvdCbbG/M/X+9lOm1cRe9DG20HbhxxquAC9PAKGvUBWRmRhRUv/jyEHITX/0Sq6IyK/VaP/xjAAAAFQD1osCdij1P/Hw8nBBaUYGPDJOeJwAAAIBdKBHJUWBwJyDr1Q/lrRrVjddNP2m9gMt3cJr+7KfpENcjODBsHIpFJNkwIhYfxZSJntij7NxYL2QlI6I9j1dLG4yXH/2kgK+1R4htUTAWDspDGNj7+SruNtVmCvtIDQH3Az+95qCOxYZyOocuWE/6MoqhzRgQQUer44M+KFX6xwAAAIAVwMXUyT0s5tp5wyR+87L6lp9kDR8Fey++K9H91k4p2i/EMI4k4zyvIWHKUqKpDmjvcxQmizpfKeceZv6lPYcXo7CO4dDFoR6U1gIcGYCM1Rgfxacsp10NbwA2DBO1VplNB7ffGx0nGRKRtUP4ZFkbzJiORYxr3RY4Q42HVAV9Eg== rok@oskar"
  #      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzV90PH95rCBALeCzDLL+W6aoA1nDz7Tn7IAi17S41BgPvf4NDrmFIvonAl7i7YoMpOEq6f2qgIPKN88ySiG7tAeyx9nZyCOOJlZ0+AhPdBkmeH7IbrP8nJR4bsDWqDz4rUTZupOAsb+QfJ/Fc9ckF80Ugk3WuXvElNzLPEEdt9Z+HGN8y67JRg2p8mfmq1PleAY5J7ZloD/6U2+Runmh9HVT9Uwy3yd328ce+YKQ72wv4X/4GJb/PHeUlyZ7CSi+uILggP3Vps8Jwr78CX56UaAki/h66Y3Bt95CVg4LF1pQ6JJYcmbBQjJNI5Mym1anmz7BTijVkjkjkdysWyhO9"  # terminus@phone
  #      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWvkx8C7PelPzOE+s3PXZ20YYQJbT1qqwHzKF8iRnfH6tNPfxISOek3g1bDpR4v8h2seTzxfiFFx+EXrpDZkiMXNrOm4JNWnN1ayOy0KR4mqTs0Wyve3xKv840o6oVRdP+yunSyl6KpIUm3+T6r1xRfWSBVy7v0xOp97WYni9RaDLyZ5yQpCjSTzoYGro7V85avk/81Wp94/nGvw+4Cdg5Lwk2+OFLD46wOPG/DHsZjkDZeNQmi0n/7lFULPki604P3yeSgsV7K0lp08YBGfvFleX9z1/1WoAMqoOyXDhGBmTT+V3Ul6Yvu54hQ9lqFi63RhyEpW4LANHZXk7k8M8vjXneAZMd+5dZ4BqqyACLgr8zFJQX/weJAlHjnZhmUcBzC8CFFoZ6ZadM/Iuj7AijoF5ZnpIM5wP4nfzsM6JbgH1DGLsWmPW4EQro3BpuPQL+76UZOk5t+YRTNVuyzupsn9Xl05vadKE/N1FQ2NkwLgc+mSP9udbfxBbR1bTPGw8Vv5AXDdH1scx+2min8r3RfHdnl9TzZLEzwroGIK8zidabnrkULrDodAQjvlIeu4OPHfN5kslYgc/B+T2RPWeHytVn6lb0Nb7JYDI0jmaLcNRL7W72N7s/2ihecklj3HAUdWruUUcBS1oUcFcIr3chLJIGXz0vO+ShAmWxRRWLzQ== rok@grayworm"
  #    ];
  #  };
}
