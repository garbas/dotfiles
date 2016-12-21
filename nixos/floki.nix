{ secrets }:

{ config, pkgs, lib, ... }:
{

  nix.package = pkgs.nixUnstable;
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];
  nix.useSandbox = true;
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
    auto-optimise-store = true
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.packageOverrides = pkgs: import ./../pkgs { inherit pkgs; };

  security.hideProcessInformation = true;

  services.xserver.enable = false;

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.fail2ban.enable = true;

  networking.hostName = "floki";
  networking.hostId = "cff52adb";

  system.autoUpgrade.enable = true;
  system.autoUpgrade.flags = lib.mkForce
    [ "--no-build-output"
      "-I" "nixpkgs=/etc/nixos/nixpkgs-channels"
    ];
  systemd.services.nixos-upgrade.path = [ pkgs.git ];
  systemd.services.nixos-upgrade.preStart = ''
    cd /etc/nixos/nixpkgs-channels 
    ${pkgs.git}/bin/git pull
  '';

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  networking.defaultMailServer =
    { directDelivery = secrets.gmail_user != null || secrets.gmail_pass != null;
      hostName = "smtp.gmail.com:587";
      root = "floki@garbas.si";
      domain = "garbas.si";
      useTLS = true;
      useSTARTTLS = true;
      authUser = secrets.gmail_user;
      authPass = secrets.gmail_pass;
      #TODO: fromLineOverride = true;
    };

  i18n.consoleFont = "lat9w-16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Berlin";

  environment.variables.NIX_PATH = lib.mkForce "nixpkgs=/etc/nixos/nixpkgs-channels:nixos-config=/etc/nixos/configuration.nix";
  environment.variables.GIT_EDITOR = lib.mkForce "nvim";
  environment.variables.EDITOR = lib.mkForce "nvim";
  environment.systemPackages = with pkgs; [
    tmux
    htop
    mosh
    neovim
    git
    gnumake
    rxvt_unicode.terminfo
    termite.terminfo
  ];

  users.mutableUsers = false;
  users.users.travis= {
    uid = 998;
    home = "/var/travis";
    shell = "/run/current-system/sw/bin/bash";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNa69Z0oaGLofKOydu7ACwBoX+o3zYq2DYQSVTgGp/jM1fHrTlubUW0R/+/Oc3egbcoBfNxntwICStjx7sOLaIMviedJTTe0NqhnWPdf4TYzKgogDKjR+rqXptP3eHADvxXSBM5VM4+buoWpjFR+ZKK6IUhR+G2S7Vo9OzfF3bOhpIHZYsseNj8ki/JZsumaY9//xMSj+8LTP521J18ID5hrQyn/TGJFHqcrNfrif0V2QduDoeVc910eRXDwjaW5I98e9K/ZdyuI4oDvA8Z4Yuo5CJiMtIGOf68lCLYZj/6SB/2ubJGrV6ukKckzncLVYDUgCUUVEwciyV4ShYWrA5crGK3UH2DpaMTm9Py540JVC6YzC9lEAFte/1KkxuiHHlKUqdCQEyLktutdV1nUYNgIwNoYZElyMS6KoNvHiIZESe91HyuGcKtGQOnS6iz17gxFiZE+IFF78KWEEsI4LhvmzVkq+gUs+/Ab0oPcZ9eiV6azcR4J9K8TqXzULkRuo9iVj+A0ofcmoleSmSpOGWNEVJnFK9kkcuD8IDPrpQ5lZUZrt0yKseRmLzVdXC1ikZqXqTi5gWPijWGlyF26tenUMlC9oKja3FCxK8dKj6BeTRirgUo4g3zmruCwNE7Z2EVsrm0uceHgeYbkxOsFoMFuylkwpW2IbScx2KyYs75w== nixpkgs-mozilla@travis-ci.org"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDE5z+i59jWwXY4gOPRltiCEK0WzQDqZFmntn10y/3x/ByqfPJRJ7HCTZUp3UoguvseqHDL+5pJn6VZDthZhifhjVShZxC5RDYTW9dSM+K9nVehS4ndWQNGObDiehp6ty4lNW27mhu4hyd9XZGGA/e1267BspYg4QtcO873AiB68FLqLDoxTD5N7gXT9cmmpERh4k4bW8+x7WeEOaJaKeXaQdst6JuOa+Y/KO9EB7tZUUfYVSHaMNh6fNUCUWq2E8g/e+YIyqua2NPssHLxy4PcIwgmvWWhsyKu818BRAOix1vqRE5IJF2IoGNhm2NBfVA0+716yH52H8UF0ukbBCjs9qL2G6eGQ29GkXXa2V0ck3T6E51esTiCrdcpGzqtta1xPKnnKsIaWTt+j5paVF4+1+Xf49ubrA6/zVB7V0VtLq4DGu1ApGs2ktf+skjvH2FttFf7rHz94AVEINUHXjC8eMuhvE0Dlfd14RwONDKim7AFYd4+0Zjczgy2peK0E0aw2JtEkktB0iPD2KMc2X9euplq+z3XUsjGSEwsp70D8KX0tQSJshoKw/1PhpdbmyzC/PkIWnMR7+t+V206CoAV75wQR8w71BMhL4fED78P8vuiosS9FzSmj+YAqj1paXiahbZaZI455uz/2Jk35YuIpg0j6umhNebzAwrDtaAEvQ== nixpkgs-python@travis-ci.org"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiHUM1LJJYvpYX8+rJTQ99+Owi72bMDxx5vdOeeag2asi/Zep2f09ZxGa+b697ugYnJ4zKYlB5SOLwG2auGZ1GgZbXKBmxpWWE5Za/GONSDPNT1i9rpAh4FM85KPQk0cSKebCVq8qDIYOVvVzGwqcYYaHxVCq3tgCNNvVaznEuPSakIsCtNIJZVBTjZkmW8VTOh6p+OTyFEDlBU9bVghsHmYUbGXcgOQlMgN/wwJvGkKFaUrmxLi1pFomzd/C9SlWSyBht7wX8UVRS4dED4aSckjUAcX/n43v6369JjL/4yWcBWZMOpu2hG1bmBHn9+tall+moknNWMs8obvX8xosa3nyeG3v6l5hyk68xLP/onzcy3JulH8qxCDLe1XnvGTnxiQ9ivuDgIKy5jeqzm9UbDr3g3CIXD+Et9HNP1u2CZp/+v7/h3W5gd5P6pNEoRDEhnV6RLbV/xuO5aaF5ALAYKFIlS8PHWrQpd6hPMPYtqhaEwE68MF3W+LpUpb4u8kV0/hJas4JREtjFDUf6H1ou0/ba+R6aCJSgZYi+Lduzhek9tJ2pVZqcfcLEg2UJjk+bvcfhAFJoq4AX+w5V3/pFQmmFKSTlcWq8wsH46QrvQPUEgPlAo5Y/WQoJCFo8kam5fPrqmBJhQXKjYT5uyTaFweXMRrGkMf6JrB3ResGouw== pypi2nix@travis-ci.org"
    ];
  };
  users.users.git = {
    uid = 999;
    home = "/var/git";
    shell = "/run/current-system/sw/bin/bash";
    openssh.authorizedKeys.keys = [
      "ssh-dss AAAAB3NzaC1kc3MAAACBAMSjkowfIlAJn80+5ccsUpG0Dsunbg9nVzGJF4ZU2QlcqC8Hbw7WzhvUgqE5HY4eFxdrbX5nISZTokOT2lyoRH2bIbcCILFwFOoUvdCbbG/M/X+9lOm1cRe9DG20HbhxxquAC9PAKGvUBWRmRhRUv/jyEHITX/0Sq6IyK/VaP/xjAAAAFQD1osCdij1P/Hw8nBBaUYGPDJOeJwAAAIBdKBHJUWBwJyDr1Q/lrRrVjddNP2m9gMt3cJr+7KfpENcjODBsHIpFJNkwIhYfxZSJntij7NxYL2QlI6I9j1dLG4yXH/2kgK+1R4htUTAWDspDGNj7+SruNtVmCvtIDQH3Az+95qCOxYZyOocuWE/6MoqhzRgQQUer44M+KFX6xwAAAIAVwMXUyT0s5tp5wyR+87L6lp9kDR8Fey++K9H91k4p2i/EMI4k4zyvIWHKUqKpDmjvcxQmizpfKeceZv6lPYcXo7CO4dDFoR6U1gIcGYCM1Rgfxacsp10NbwA2DBO1VplNB7ffGx0nGRKRtUP4ZFkbzJiORYxr3RY4Q42HVAV9Eg== rok@oskar"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVxOBeJUJmWYrniuFyDaJIxjxwwV1ikQUbp7cvOO4F63RQt0AH2Yu9/dxIefuH4yXJb8dh1rqM7MtI5U0s5atfZymqqZJIcTdDs9rc2nOqW+uqsE3ROA9y5moVEdc+jJCjQRr4/wFCQd9xlzH2vwushYnI1w9cn9kWXelI/B8hbRZ22mNiXRIOoG9W+4iX7IFLqmyukxetL/cXV5FPxvfxXxDvGfj7mQ8y3bteotOObNZo5RBSd2EE0BIceC2bMruxZX1oOBdIgiixHfjzgaeEEzlbqnjpAIG2BgCad9WVJaBnGIYJnHtYavIZvHMKTsgExwgjwHbh79YAz735qDbn5CGYj1XZQB5OerRgNsokojan2XQYbo7YP88F4MGrDJEVZrBqHRFMwee0nfIXM9tml28DDAPnntkntNdMUrIiyhkGWOzn4PUCuvLPmWLq7Dba/bpXKcLKy9bXA8QPw6OYeIpOT6a6Ax6eP2aULOYN1Wti1Xa6MX5Eml4Te32UUBviGSf/ugVumcogZulURaxsMUeK7LzXcX1GVFs+1MoOvGAgUbu45qLRJGv7qHU3LbNBDP2eqCfaBLwKiqExwMhSzAuEEH+IzSUgOk88N2RTV/0BXGBqCUc/D2iF24btEL43PqBCoCkiCrIxJg9G/CHFdRau+RUMzvWCk2X9pG9IWQ== rok@nemo"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-dss AAAAB3NzaC1kc3MAAACBAMSjkowfIlAJn80+5ccsUpG0Dsunbg9nVzGJF4ZU2QlcqC8Hbw7WzhvUgqE5HY4eFxdrbX5nISZTokOT2lyoRH2bIbcCILFwFOoUvdCbbG/M/X+9lOm1cRe9DG20HbhxxquAC9PAKGvUBWRmRhRUv/jyEHITX/0Sq6IyK/VaP/xjAAAAFQD1osCdij1P/Hw8nBBaUYGPDJOeJwAAAIBdKBHJUWBwJyDr1Q/lrRrVjddNP2m9gMt3cJr+7KfpENcjODBsHIpFJNkwIhYfxZSJntij7NxYL2QlI6I9j1dLG4yXH/2kgK+1R4htUTAWDspDGNj7+SruNtVmCvtIDQH3Az+95qCOxYZyOocuWE/6MoqhzRgQQUer44M+KFX6xwAAAIAVwMXUyT0s5tp5wyR+87L6lp9kDR8Fey++K9H91k4p2i/EMI4k4zyvIWHKUqKpDmjvcxQmizpfKeceZv6lPYcXo7CO4dDFoR6U1gIcGYCM1Rgfxacsp10NbwA2DBO1VplNB7ffGx0nGRKRtUP4ZFkbzJiORYxr3RY4Q42HVAV9Eg== rok@oskar"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVxOBeJUJmWYrniuFyDaJIxjxwwV1ikQUbp7cvOO4F63RQt0AH2Yu9/dxIefuH4yXJb8dh1rqM7MtI5U0s5atfZymqqZJIcTdDs9rc2nOqW+uqsE3ROA9y5moVEdc+jJCjQRr4/wFCQd9xlzH2vwushYnI1w9cn9kWXelI/B8hbRZ22mNiXRIOoG9W+4iX7IFLqmyukxetL/cXV5FPxvfxXxDvGfj7mQ8y3bteotOObNZo5RBSd2EE0BIceC2bMruxZX1oOBdIgiixHfjzgaeEEzlbqnjpAIG2BgCad9WVJaBnGIYJnHtYavIZvHMKTsgExwgjwHbh79YAz735qDbn5CGYj1XZQB5OerRgNsokojan2XQYbo7YP88F4MGrDJEVZrBqHRFMwee0nfIXM9tml28DDAPnntkntNdMUrIiyhkGWOzn4PUCuvLPmWLq7Dba/bpXKcLKy9bXA8QPw6OYeIpOT6a6Ax6eP2aULOYN1Wti1Xa6MX5Eml4Te32UUBviGSf/ugVumcogZulURaxsMUeK7LzXcX1GVFs+1MoOvGAgUbu45qLRJGv7qHU3LbNBDP2eqCfaBLwKiqExwMhSzAuEEH+IzSUgOk88N2RTV/0BXGBqCUc/D2iF24btEL43PqBCoCkiCrIxJg9G/CHFdRau+RUMzvWCk2X9pG9IWQ== rok@nemo"
  ];


  # =========
  #  WeeChat
  # =========
  #
  # http://www.mythmon.com/posts/2015-02-15-systemd-weechat.html
  #
  systemd.services."weechat" = with pkgs; {
    enable = true;
    description = "Weechat IRC Client (in tmux)";
    environment = {
      LANG = "en_US.utf8";
      LC_ALL = "en_US.utf8";
      TERM = "${rxvt_unicode.terminfo}";
    };
    path = [ tmux weechat termite.terminfo which binutils ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/var/weechat";
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${tmux}/bin/tmux -v -S /run/tmux-weechat new-session -d -s weechat -n 'weechat' '${weechat}/bin/weechat-curses -d /var/weechat'";
      ExecStop = "${tmux}/bin/tmux -S /run/tmux-weechat kill-session -t weechat";
      KillMode = "none";
    };
  };

  # =======
  #  Nginx
  # =======
  #
  # https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
  #
  services.nginx.enable = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.sslProtocols = "TLSv1.2";
  services.nginx.sslCiphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256";
  services.nginx.sslDhparam = secrets.nginx_garbas_ssl_dhparam;
  services.nginx.statusPage = true;
  services.nginx.virtualHosts =
    { "garbas.si" =
        { default = true;
          forceSSL = true;
          enableACME = true;
          acmeRoot = "/var/www/challenges";
          locations."/".root = /var/www/static/garbas.si;
          extraConfig = ''
            add_header           X-Frame-Options SAMEORIGIN;
            add_header           X-Content-Type-Options nosniff;
            add_header           X-XSS-Protection "1; mode=block";
            add_header           Content-Security-Policy "default-src 'self'";
            add_header           Strict-Transport-Security "max-age=15768000; includeSubDomains; preload";
            ssl_session_tickets  off;
          '';

        };
      "travis.garbas.si" =
        { default = false;
          forceSSL = true;
          enableACME = true;
          acmeRoot = "/var/www/challenges";
          locations."/".root = /var/www/static/travis.garbas.si;
        };
      "stats.garbas.si" =
        { default = false;
          forceSSL = true;
          enableACME = true;
          acmeRoot = "/var/www/challenges";
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };
    };

  services.grafana.enable = true;
  services.grafana.rootUrl = "https://stats.garbas.si";
  services.grafana.security.adminUser = secrets.grafana_user;
  services.grafana.security.adminPassword = secrets.grafana_password;
  services.grafana.security.secretKey = secrets.grafana_secretkey;

  services.prometheus.enable = true;
  services.prometheus.listenAddress = "127.0.0.1:9090";
  services.prometheus.scrapeConfigs = [
    { job_name = "prometheus";
      scrape_interval = "5s";
      static_configs = [
        {
	  targets = [ "127.0.0.1:9090" ];
	  labels = {};
        }
      ];
    }
    { job_name = "node";
      scrape_interval = "5s";
      static_configs = [
        {
	  targets = [ "127.0.0.1:9100" ];
	  labels = {};
        }
      ];
    }
  ];

  services.prometheus.nodeExporter.enable = true;
  services.prometheus.nodeExporter.listenAddress = "127.0.0.1";
  services.prometheus.nodeExporter.port = 9100;

}
