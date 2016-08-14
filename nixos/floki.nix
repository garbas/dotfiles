{ secrets }:

let

  isGmail = secrets.gmail_user != null ||
            secrets.gmail_pass != null;

  isSSL = secrets.nginx_garbas_ssl_dhparam != null;

  isDD = secrets.datadog_api_key != null ||
         secrets.datadog_postgresql_password != null;

  isLogentries = secrets.logentries_token != null;

  _pkgs = import <nixpkgs> {};

  # https://logentries.com/doc/nixos/
  logentries-crt = _pkgs.fetchurl {
    url = https://bits.lecdn.net/certs/1/logentries.all.crt;
    sha256 = "1ppsr783pd05ymcrwdqyxaw977hahzzzdy5na0ma9fslz5h9sxmj";
  };

in

{ config, pkgs, lib, ... }:
let

  createSite = domain: domainConfig:
    ''
      server {
        listen                      80;
        listen                      [::]:80;
        server_name                 ${domain};

        location /.well-known/acme-challenge {
          root /var/www/challenges;
        }

        location / {
          return 301 https://$host$request_uri;
        }
      }
      server {
        listen                  443 ssl;
        server_name             ${domain};

        # certs sent to the client in SERVER HELLO are concatenated in ssl_certificate
        ssl                         on;
        ssl_certificate             ${config.security.acme.directory}/${domain}/fullchain.pem;
        ssl_certificate_key         ${config.security.acme.directory}/${domain}/key.pem;
        ssl_session_timeout         1d;
        ssl_session_cache           shared:SSL:50m;

        # Diffie-Hellman parameter for DHE ciphersuites, recommended 2048 bits
        ssl_dhparam                 ${secrets.nginx_garbas_ssl_dhparam};

        # modern configuration.
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

        # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
        add_header                  Strict-Transport-Security max-age=15768000;

        # OCSP Stapling ---
        # fetch OCSP records from URL in ssl_certificate and cache them
        ssl_stapling                on;
        ssl_stapling_verify         on;

        ## verify chain of trust of OCSP response using Root CA and Intermediate certs

        resolver                    127.0.0.1 [::1];

        # test -> https://mozilla.github.io/http-observatory-website/analyze.html?host=garbas.si
        # example -> https://gist.github.com/plentz/6737338
        add_header                  X-Frame-Options SAMEORIGIN;
        add_header                  X-Content-Type-Options nosniff;
        add_header                  X-XSS-Protection "1; mode=block";
        add_header                  Content-Security-Policy "default-src https:";

        ${domainConfig}
      }
    '';

  createStaticSite = domain: createSite domain ''
    location / {
      alias                     /var/www/static/${domain}/;
      autoindex                 off;
    }

    location /__status__ {
      stub_status;
    }
  '';

in {

  nix.distributedBuilds = true;
  nix.nrBuildUsers = 30;
  nix.extraOptions = ''
    build-use-chroot = relaxed
    auto-optimise-store = true
  '';
  nix.binaryCaches = [
    #"https://cache.nixos.org/"
    "https://hydra.nixos.org"
  ];
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];
  nix.gc.automatic = true;
  nix.gc.dates = "05:15";
  nix.gc.options = ''--max-freed "$((12 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: import ./../pkgs { inherit pkgs; i3_tray_output = ""; };

  #
  # Initialization commands
  #
  # on nixops server:
  # - ssh-keygen -C "hydra@hydra.example.org" -N "" -f id_buildfarm
  #
  # on master server:
  #   - hydra-create-user garbas --full-name 'Rok Garbas' --email-address 'rok@garbas.si' --password 'XXX' --role admin
  #   - install -d -m 551 /etc/nix/hydra.garbas.si-1
  #   - nix-store --generate-binary-cache-key hydra.garbas.si-1 /etc/nix/hydra.garbas.si-1/secret /etc/nix/hydra.garbas.si-1/public
  #   - chown -R hydra:hydra /etc/nix/hydra.garbas.si-1
  #   - chmod 440 /etc/nix/hydra.garbas.si-1/secret
  #   - chmod 444 /etc/nix/hydra.garbas.si-1/public
  services.hydra.enable = true;
  services.hydra.dbi = "dbi:Pg:dbname=hydra;user=hydra;";
  #services.hydra.package = hydra;
  services.hydra.hydraURL = "https://hydra.garbas.si/";
  services.hydra.listenHost = "127.0.0.1";
  services.hydra.port = 3000;
  services.hydra.extraConfig = "binary_cache_secret_key_file = /etc/nix/hydra.garbas.si-1/secret";
  services.hydra.minimumDiskFree = 2;  # in GB
  services.hydra.minimumDiskFreeEvaluator = 1;
  services.hydra.notificationSender = "hydra@garbas.si";
  services.hydra.logo = null;
  services.hydra.debugServer = false;

  services.xserver.enable = false;

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.fail2ban.enable = true;

  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "8.8.8.8" "8.8.4.4" ];

  networking.hostName = "floki";
  networking.hostId = "cff52adb";

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  networking.defaultMailServer.directDelivery = isGmail;
  networking.defaultMailServer.hostName = "smtp.gmail.com:587";
  networking.defaultMailServer.root = "floki@garbas.si";
  networking.defaultMailServer.domain = "garbas.si";
  networking.defaultMailServer.useTLS = true;
  networking.defaultMailServer.useSTARTTLS = true;
  networking.defaultMailServer.authUser = secrets.gmail_user;
  networking.defaultMailServer.authPass = secrets.gmail_pass;
  #networking.defaultMailServer.fromLineOverride = true;

  i18n.consoleFont = "lat9w-16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Berlin";

  environment.etc = if secrets.hydra_id_buildfarm == null then [] else (
    pkgs.lib.singleton {
      target = "nix/id_buildfarm";
      text = builtins.readFile secrets.hydra_id_buildfarm;
      uid = config.ids.uids.hydra;
      gid = config.ids.gids.hydra;
      mode = "0440";
    });

  environment.systemPackages = with pkgs; [
    tmux
    htop
    mosh
    vim
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
  users.users.hydra.uid = config.ids.uids.hydra;
  users.groups.hydra.gid = config.ids.gids.hydra;

  # From: http://www.mythmon.com/posts/2015-02-15-systemd-weechat.html
  systemd.services."weechat" = with pkgs; {
    enable = true;
    description = "Weechat IRC Client (in tmux)";
    environment = {
      LANG = "en_US.utf8";
      LC_ALL = "en_US.utf8";
      TERM = "${rxvt_unicode.terminfo}";
    };
    path = [ tmux weechat rxvt_unicode.terminfo which binutils ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${tmux}/bin/tmux -v -S /run/tmux-weechat new-session -d -s weechat -n 'weechat' '${weechat}/bin/weechat-curses -d /root/dotfiles/pkgs/weechat'";
      ExecStop = "${tmux}/bin/tmux -S /run/tmux-weechat kill-session -t weechat";
    };
  };

  # https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
  services.nginx.enable = true;
  services.nginx.config = ''
    worker_processes 2;
    #events {
    #  worker_connections  2048;
    #}
  '';
  services.nginx.httpConfig = ''

    client_body_buffer_size       10K;
    client_header_buffer_size     1k;
    client_max_body_size          8m;
    large_client_header_buffers   2 1k;

    client_body_timeout     12;
    client_header_timeout   12;
    keepalive_timeout       15;
    send_timeout            10;

    gzip                    on;
    gzip_comp_level         2;
    gzip_min_length         1000;
    gzip_proxied            expired no-cache no-store private auth;
    gzip_types              text/plain application/x-javascript text/xml text/css application/xml;
    gzip_disable            "msie6";

    access_log              syslog:server=unix:/dev/log;
    error_log               syslog:server=unix:/dev/log;

    server_tokens off;

  '' + (createStaticSite "garbas.si")
     + (createStaticSite "travis.garbas.si")
     + (createSite "hydra.garbas.si"
        ''
        location / {
          proxy_set_header Host $http_host;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-Port 443;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Request-Base "https://hydra.garbas.si";
          proxy_pass http://${config.services.hydra.listenHost}:${builtins.toString config.services.hydra.port}/;
        }
        ''
       );

  security.acme.certs."garbas.si" = {
    webroot = "/var/www/challenges";
    email = "rok@garbas.si";
    group = "nginx";
  };

  security.acme.certs."travis.garbas.si" = {
    webroot = "/var/www/challenges";
    email = "rok@garbas.si";
    group = "nginx";
  };

  security.acme.certs."db.garbas.si" = {
    webroot = "/var/www/challenges";
    email = "rok@garbas.si";
    group = "nginx";
  };

  security.acme.certs."hydra.garbas.si" = {
    webroot = "/var/www/challenges";
    email = "rok@garbas.si";
    group = "nginx";
  };

  services.dd-agent.enable = isDD;
  services.dd-agent.api_key = lib.optionalString isDD secrets.datadog_api_key;
  services.dd-agent.hostname = "floki.garbas.si";
  services.dd-agent.postgresqlConfig = lib.optionalString isDD ''
    init_config:

    instances:
      - host: localhost
        port: 5432
        username: datadog
        password: ${secrets.datadog_postgresql_password}
  '';
  services.dd-agent.nginxConfig = ''
    init_config:

    instances:
      - nginx_status_url: https://garbas.si/__status__/
        tags:
          - instance:www
  '';

  services.rsyslogd.enable = isLogentries;
  services.rsyslogd.extraConfig = lib.optionalString isLogentries ''
    $ModLoad imjournal

    $DefaultNetstreamDriverCAFile ${logentries-crt}

    $ActionSendStreamDriver gtls
    $ActionSendStreamDriverMode 1
    $ActionSendStreamDriverAuthMode x509/name
    $ActionSendStreamDriverPermittedPeer *.logentries.com

    $template LogentriesFormat,"${secrets.logentries_token} %HOSTNAME% %syslogtag%%msg%\n"
    *.* @@data.logentries.com:443;LogentriesFormat
  '';

   services.postgresql.package = pkgs.postgresql94;

}
