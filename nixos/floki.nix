# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  custom_overlay = self: super: {
    neovim = import ./../../nvim-config { pkgs = super; };
    weechat = super.weechat.override {
      configure = { ... }: {
        scripts = with self.weechatScripts; [
          weechat-matrix-bridge
          wee-slack
        ];
      };
    };

  };
in {
  imports =
    [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ];

  services.weechat.enable = true;
  programs.screen.screenrc = ''
    multiuser on
    acladd rok
  '';

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2f54e8e6-ff9c-497a-88ea-ce159f6cd283";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nix.package = pkgs.nixUnstable;
  nix.maxJobs = lib.mkDefault 2;
  nix.useSandbox = true;
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];

  nixpkgs.overlays = [
    custom_overlay
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "floki";
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";


  environment.etc."gitconfig".source = ./gitconfig;
  environment.variables.NIX_PATH = lib.mkForce "nixpkgs=/etc/nixos/nixpkgs-channels:nixos-config=/etc/nixos/configuration.nix";
  environment.variables.GIT_EDITOR = lib.mkForce "nvim";
  environment.variables.EDITOR = lib.mkForce "nvim";
  environment.variables.FZF_DEFAULT_COMMAND = "rg --files";
  environment.systemPackages = with pkgs; [
    # editors
    neovim

    # nix tools
    nixpkgs-fmt
    niv
    direnv

    # version control
    gitAndTools.gitflow
    gitAndTools.hub
    gitAndTools.gh
    gitFull
    git-lfs

    # console tools
    bat
    fzf
    gnumake
    htop
    mosh
    ripgrep
    sshuttle
    termite.terminfo
    tig
    tree
    unzip
    wget
    which
  ];

  security.hideProcessInformation = true;
  security.sudo.enable = true;

  services.openssh.enable = true;

  # https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
  services.nginx.enable = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.sslProtocols = "TLSv1.2";
  services.nginx.sslCiphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256";
  services.nginx.sslDhparam = "/etc/ssl/certs/dhparam.pem";
  services.nginx.statusPage = true;
  services.nginx.appendHttpConfig = ''
    limit_req_zone $binary_remote_addr zone=weechat:10m rate=5r/m;  # Setup brute force protection
  '';
  security.acme.acceptTerms = true;
  security.acme.email = "rok@garbas.si";
  services.nginx.virtualHosts =
    { "garbas.si" =
        { default = true;
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            ssl_session_tickets  off;
          '';
          locations =
            { "/weechat" =
                { proxyPass = "https://localhost:8888/weechat";
                  proxyWebsockets = true;
                  extraConfig = ''
                    proxy_read_timeout 604800;                # Prevent idle disconnects
                    proxy_set_header X-Real-IP $remote_addr;  # Let Weechat see client's IP
                    limit_req zone=weechat burst=1 nodelay;   # Brute force prevention
                  '';
                };
              "/" =
                { root = "/var/www/garbas.si";
                  extraConfig = ''
                    add_header           X-Frame-Options SAMEORIGIN;
                    add_header           X-Content-Type-Options nosniff;
                    add_header           X-XSS-Protection "1; mode=block";
                    add_header           Content-Security-Policy "default-src 'self';script-src 'self' www.google-analytics.com;img-src 'self' www.google-analytics.com;";
                    add_header           Strict-Transport-Security "max-age=15768000; includeSubDomains; preload";
                  '';
                };
            };

        };
      "url.garbas.si" =
        { forceSSL = true;
          enableACME = true;
          acmeRoot = "/var/www/challenges";
          extraConfig = ''
            ssl_session_tickets  off;
          '';
          locations =
            { "/" = 
                { proxyPass = "http://localhost:8123";
                };
            };
        };
    };

  users.mutableUsers = false;
  users.users.root.hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
  users.users."nginx".extraGroups = [ "weechat" "rok" ];
  users.users."weechat".extraGroups = [ "nginx" ];
  users.users."rok" = {
    hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [
      "wheel"  # sudo
      "nginx"  # to publish
    ] ;
    group = "users";
    home = "/home/rok";
    openssh.authorizedKeys.keys = [
      "ssh-dss AAAAB3NzaC1kc3MAAACBAMSjkowfIlAJn80+5ccsUpG0Dsunbg9nVzGJF4ZU2QlcqC8Hbw7WzhvUgqE5HY4eFxdrbX5nISZTokOT2lyoRH2bIbcCILFwFOoUvdCbbG/M/X+9lOm1cRe9DG20HbhxxquAC9PAKGvUBWRmRhRUv/jyEHITX/0Sq6IyK/VaP/xjAAAAFQD1osCdij1P/Hw8nBBaUYGPDJOeJwAAAIBdKBHJUWBwJyDr1Q/lrRrVjddNP2m9gMt3cJr+7KfpENcjODBsHIpFJNkwIhYfxZSJntij7NxYL2QlI6I9j1dLG4yXH/2kgK+1R4htUTAWDspDGNj7+SruNtVmCvtIDQH3Az+95qCOxYZyOocuWE/6MoqhzRgQQUer44M+KFX6xwAAAIAVwMXUyT0s5tp5wyR+87L6lp9kDR8Fey++K9H91k4p2i/EMI4k4zyvIWHKUqKpDmjvcxQmizpfKeceZv6lPYcXo7CO4dDFoR6U1gIcGYCM1Rgfxacsp10NbwA2DBO1VplNB7ffGx0nGRKRtUP4ZFkbzJiORYxr3RY4Q42HVAV9Eg== rok@oskar"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzV90PH95rCBALeCzDLL+W6aoA1nDz7Tn7IAi17S41BgPvf4NDrmFIvonAl7i7YoMpOEq6f2qgIPKN88ySiG7tAeyx9nZyCOOJlZ0+AhPdBkmeH7IbrP8nJR4bsDWqDz4rUTZupOAsb+QfJ/Fc9ckF80Ugk3WuXvElNzLPEEdt9Z+HGN8y67JRg2p8mfmq1PleAY5J7ZloD/6U2+Runmh9HVT9Uwy3yd328ce+YKQ72wv4X/4GJb/PHeUlyZ7CSi+uILggP3Vps8Jwr78CX56UaAki/h66Y3Bt95CVg4LF1pQ6JJYcmbBQjJNI5Mym1anmz7BTijVkjkjkdysWyhO9"  # terminus@phone
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWvkx8C7PelPzOE+s3PXZ20YYQJbT1qqwHzKF8iRnfH6tNPfxISOek3g1bDpR4v8h2seTzxfiFFx+EXrpDZkiMXNrOm4JNWnN1ayOy0KR4mqTs0Wyve3xKv840o6oVRdP+yunSyl6KpIUm3+T6r1xRfWSBVy7v0xOp97WYni9RaDLyZ5yQpCjSTzoYGro7V85avk/81Wp94/nGvw+4Cdg5Lwk2+OFLD46wOPG/DHsZjkDZeNQmi0n/7lFULPki604P3yeSgsV7K0lp08YBGfvFleX9z1/1WoAMqoOyXDhGBmTT+V3Ul6Yvu54hQ9lqFi63RhyEpW4LANHZXk7k8M8vjXneAZMd+5dZ4BqqyACLgr8zFJQX/weJAlHjnZhmUcBzC8CFFoZ6ZadM/Iuj7AijoF5ZnpIM5wP4nfzsM6JbgH1DGLsWmPW4EQro3BpuPQL+76UZOk5t+YRTNVuyzupsn9Xl05vadKE/N1FQ2NkwLgc+mSP9udbfxBbR1bTPGw8Vv5AXDdH1scx+2min8r3RfHdnl9TzZLEzwroGIK8zidabnrkULrDodAQjvlIeu4OPHfN5kslYgc/B+T2RPWeHytVn6lb0Nb7JYDI0jmaLcNRL7W72N7s/2ihecklj3HAUdWruUUcBS1oUcFcIr3chLJIGXz0vO+ShAmWxRRWLzQ== rok@grayworm"
    ];
  };

  # disable as much as possible
  hardware.pulseaudio.enable = false;
  services.printing.enable = false;
  services.xserver.enable = false;
  sound.enable = false;

  system.stateVersion = "18.09";

}
