{ secrets }:

{ config, pkgs, lib, ... }:
{

  imports =
    [ ./common-new.nix
    ];

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

  networking.firewall.allowedTCPPorts = [ 22 80 443 8888 ];
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

  time.timeZone = "Europe/Berlin";

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
  users.users.temp = {
    isNormalUser = true;
    createHome = true;
    hashedPassword = "$6$EfZB2EFWQb0Nw$zHbYVG5oraaGfHoi7dtuuY7PFo8m1GOumcInzHBPyd1UHGScsW4lUUP.tJRLOFALLjhGgl4CNRkuxzy2x8zOD/";
  };
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEvkZniWHBs2AFuhAl2qTLC7SMpxBes7N7+xi1txrLZ2zEr6blKynNK/pJkd88jwsgNTgNo7b+stjfY5CJj1oIvqdsM0c/2bwMW3Mkf8mD9u1O5AxBcHqL6cdMmLNme6gsjGdkJNOW96grKpNtzs59K4lW9AnKV3FkA8SrSyMWI08hB2Rd+u1W8gzdeab/tmLoeiEgFFf6g/y8bLm1iTfxfMzN6utD0AhjZsGqxBik/4ixb0nNRjNSES5XICxlYMCm73ucOGMCjDGjQfFpTb1n0nHdNSi+8+n0oUdpwAdbZNmr61cnPOP2rac87rfgfl+VLrBR7qsHmqI8rQPVNwrr"  # pass@phone
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWvkx8C7PelPzOE+s3PXZ20YYQJbT1qqwHzKF8iRnfH6tNPfxISOek3g1bDpR4v8h2seTzxfiFFx+EXrpDZkiMXNrOm4JNWnN1ayOy0KR4mqTs0Wyve3xKv840o6oVRdP+yunSyl6KpIUm3+T6r1xRfWSBVy7v0xOp97WYni9RaDLyZ5yQpCjSTzoYGro7V85avk/81Wp94/nGvw+4Cdg5Lwk2+OFLD46wOPG/DHsZjkDZeNQmi0n/7lFULPki604P3yeSgsV7K0lp08YBGfvFleX9z1/1WoAMqoOyXDhGBmTT+V3Ul6Yvu54hQ9lqFi63RhyEpW4LANHZXk7k8M8vjXneAZMd+5dZ4BqqyACLgr8zFJQX/weJAlHjnZhmUcBzC8CFFoZ6ZadM/Iuj7AijoF5ZnpIM5wP4nfzsM6JbgH1DGLsWmPW4EQro3BpuPQL+76UZOk5t+YRTNVuyzupsn9Xl05vadKE/N1FQ2NkwLgc+mSP9udbfxBbR1bTPGw8Vv5AXDdH1scx+2min8r3RfHdnl9TzZLEzwroGIK8zidabnrkULrDodAQjvlIeu4OPHfN5kslYgc/B+T2RPWeHytVn6lb0Nb7JYDI0jmaLcNRL7W72N7s/2ihecklj3HAUdWruUUcBS1oUcFcIr3chLJIGXz0vO+ShAmWxRRWLzQ== rok@grayworm"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-dss AAAAB3NzaC1kc3MAAACBAMSjkowfIlAJn80+5ccsUpG0Dsunbg9nVzGJF4ZU2QlcqC8Hbw7WzhvUgqE5HY4eFxdrbX5nISZTokOT2lyoRH2bIbcCILFwFOoUvdCbbG/M/X+9lOm1cRe9DG20HbhxxquAC9PAKGvUBWRmRhRUv/jyEHITX/0Sq6IyK/VaP/xjAAAAFQD1osCdij1P/Hw8nBBaUYGPDJOeJwAAAIBdKBHJUWBwJyDr1Q/lrRrVjddNP2m9gMt3cJr+7KfpENcjODBsHIpFJNkwIhYfxZSJntij7NxYL2QlI6I9j1dLG4yXH/2kgK+1R4htUTAWDspDGNj7+SruNtVmCvtIDQH3Az+95qCOxYZyOocuWE/6MoqhzRgQQUer44M+KFX6xwAAAIAVwMXUyT0s5tp5wyR+87L6lp9kDR8Fey++K9H91k4p2i/EMI4k4zyvIWHKUqKpDmjvcxQmizpfKeceZv6lPYcXo7CO4dDFoR6U1gIcGYCM1Rgfxacsp10NbwA2DBO1VplNB7ffGx0nGRKRtUP4ZFkbzJiORYxr3RY4Q42HVAV9Eg== rok@oskar"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVxOBeJUJmWYrniuFyDaJIxjxwwV1ikQUbp7cvOO4F63RQt0AH2Yu9/dxIefuH4yXJb8dh1rqM7MtI5U0s5atfZymqqZJIcTdDs9rc2nOqW+uqsE3ROA9y5moVEdc+jJCjQRr4/wFCQd9xlzH2vwushYnI1w9cn9kWXelI/B8hbRZ22mNiXRIOoG9W+4iX7IFLqmyukxetL/cXV5FPxvfxXxDvGfj7mQ8y3bteotOObNZo5RBSd2EE0BIceC2bMruxZX1oOBdIgiixHfjzgaeEEzlbqnjpAIG2BgCad9WVJaBnGIYJnHtYavIZvHMKTsgExwgjwHbh79YAz735qDbn5CGYj1XZQB5OerRgNsokojan2XQYbo7YP88F4MGrDJEVZrBqHRFMwee0nfIXM9tml28DDAPnntkntNdMUrIiyhkGWOzn4PUCuvLPmWLq7Dba/bpXKcLKy9bXA8QPw6OYeIpOT6a6Ax6eP2aULOYN1Wti1Xa6MX5Eml4Te32UUBviGSf/ugVumcogZulURaxsMUeK7LzXcX1GVFs+1MoOvGAgUbu45qLRJGv7qHU3LbNBDP2eqCfaBLwKiqExwMhSzAuEEH+IzSUgOk88N2RTV/0BXGBqCUc/D2iF24btEL43PqBCoCkiCrIxJg9G/CHFdRau+RUMzvWCk2X9pG9IWQ== rok@nemo"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzV90PH95rCBALeCzDLL+W6aoA1nDz7Tn7IAi17S41BgPvf4NDrmFIvonAl7i7YoMpOEq6f2qgIPKN88ySiG7tAeyx9nZyCOOJlZ0+AhPdBkmeH7IbrP8nJR4bsDWqDz4rUTZupOAsb+QfJ/Fc9ckF80Ugk3WuXvElNzLPEEdt9Z+HGN8y67JRg2p8mfmq1PleAY5J7ZloD/6U2+Runmh9HVT9Uwy3yd328ce+YKQ72wv4X/4GJb/PHeUlyZ7CSi+uILggP3Vps8Jwr78CX56UaAki/h66Y3Bt95CVg4LF1pQ6JJYcmbBQjJNI5Mym1anmz7BTijVkjkjkdysWyhO9"  # terminus@phone
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWvkx8C7PelPzOE+s3PXZ20YYQJbT1qqwHzKF8iRnfH6tNPfxISOek3g1bDpR4v8h2seTzxfiFFx+EXrpDZkiMXNrOm4JNWnN1ayOy0KR4mqTs0Wyve3xKv840o6oVRdP+yunSyl6KpIUm3+T6r1xRfWSBVy7v0xOp97WYni9RaDLyZ5yQpCjSTzoYGro7V85avk/81Wp94/nGvw+4Cdg5Lwk2+OFLD46wOPG/DHsZjkDZeNQmi0n/7lFULPki604P3yeSgsV7K0lp08YBGfvFleX9z1/1WoAMqoOyXDhGBmTT+V3Ul6Yvu54hQ9lqFi63RhyEpW4LANHZXk7k8M8vjXneAZMd+5dZ4BqqyACLgr8zFJQX/weJAlHjnZhmUcBzC8CFFoZ6ZadM/Iuj7AijoF5ZnpIM5wP4nfzsM6JbgH1DGLsWmPW4EQro3BpuPQL+76UZOk5t+YRTNVuyzupsn9Xl05vadKE/N1FQ2NkwLgc+mSP9udbfxBbR1bTPGw8Vv5AXDdH1scx+2min8r3RfHdnl9TzZLEzwroGIK8zidabnrkULrDodAQjvlIeu4OPHfN5kslYgc/B+T2RPWeHytVn6lb0Nb7JYDI0jmaLcNRL7W72N7s/2ihecklj3HAUdWruUUcBS1oUcFcIr3chLJIGXz0vO+ShAmWxRRWLzQ== rok@grayworm"
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
          locations."/".root = "/var/www/static/garbas.si";
          extraConfig = ''
            add_header           X-Frame-Options SAMEORIGIN;
            add_header           X-Content-Type-Options nosniff;
            add_header           X-XSS-Protection "1; mode=block";
            add_header           Content-Security-Policy "default-src 'self';script-src 'self' www.google-analytics.com;img-src 'self' www.google-analytics.com;";
            add_header           Strict-Transport-Security "max-age=15768000; includeSubDomains; preload";
            ssl_session_tickets  off;
          '';

        };
      "travis.garbas.si" =
        { default = false;
          forceSSL = true;
          enableACME = true;
          acmeRoot = "/var/www/challenges";
          locations."/".root = "/var/www/static/travis.garbas.si";
          locations."/wheels_cache".root = "/var/www/static/travis.garbas.si";
          locations."/wheels_cache".extraConfig = ''
            autoindex on;
          '';
        };
      "stats.garbas.si" =
        { default = false;
          forceSSL = true;
          enableACME = true;
          acmeRoot = "/var/www/challenges";
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };
    };

    #  services.grafana.enable = true;
    #  services.grafana.rootUrl = "https://stats.garbas.si";
    #  services.grafana.security.adminUser = secrets.grafana_user;
    #  services.grafana.security.adminPassword = secrets.grafana_password;
    #  services.grafana.security.secretKey = secrets.grafana_secretkey;
    #
    #  services.prometheus.enable = true;
    #  services.prometheus.listenAddress = "127.0.0.1:9090";
    #  services.prometheus.scrapeConfigs = [
    #    { job_name = "prometheus";
    #      scrape_interval = "5s";
    #      static_configs = [
    #        {
    #	  targets = [ "127.0.0.1:9090" ];
    #	  labels = {};
    #        }
    #      ];
    #    }
    #    { job_name = "node";
    #      scrape_interval = "5s";
    #      static_configs = [
    #        {
    #	  targets = [ "127.0.0.1:9100" ];
    #	  labels = {};
    #        }
    #      ];
    #    }
    #  ];
    #
    #  services.prometheus.nodeExporter.enable = true;
    #  services.prometheus.nodeExporter.listenAddress = "127.0.0.1";
    #  services.prometheus.nodeExporter.port = 9100;

}
