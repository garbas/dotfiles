sshKey: { ... }: {

  services.tailscale.enable = true;

  nix.buildMachines = [
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::f";
      systems = [ "x86_64-linux" ];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
      mandatoryFeatures = [ ];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUZKUWVLUDkvUDBreG9FMGZUZVYyMFdkZnZYVlBWUGUrd2IyWkRuUitTSzAgcm9vdEBpcC0xMC0wLTEwLTIyMy5lYzIuaW50ZXJuYWwK";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::8";
      systems = [ "aarch64-linux" ];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUg3WDVVTkIyMDFzcVc3bDJUNjgxYXI2RnVmVlJlUTBHWDJETGxZaWhUS0Ugcm9vdEBpcC0xMC0wLTEwLTgyLmVjMi5pbnRlcm5hbAo=";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::11";
      systems = [ "x86_64-darwin" ];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUoxM1lNajNsMjl2YXVyM0pQVlJGanRGNzg0clk3aEw5SnB3QXMzZWp5VU4gCg==";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::12";
      systems = [ "aarch64-darwin" ];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUh5b1dDTXQxcUQ1TmRKRlQyMHVjUFRqbng1clpYaVVQYWxYTFpMVlBITEcgCg==";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::19";
      systems = [ "aarch64-linux" ];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUdRR0NlUVNhbHNHdWFwL2hVOWE1K2J6cEdHdWp1bU9JRC9tRVAyMjZkcm4gcm9vdEBpcC0xNzItMzEtMzctMTc2LmVjMi5pbnRlcm5hbAo=";
    }
  ];

}
