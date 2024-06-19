sshKey: { ... }: {

  services.tailscale.enable = true;

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::19";
      systems = ["aarch64-linux"];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["kvm" "big-parallel" "nixos-test" "benchmark"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU93SjIvSGdwL0N4UWFac2Q0ak1oYjhhNUllY1l1Qm00NWltdGJUWlRWS2Ugcm9vdEBidWlsZC1hcm0K";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::f";
      systems = ["x86_64-linux"];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["kvm" "big-parallel" "nixos-test" "benchmark"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUZKUWVLUDkvUDBreG9FMGZUZVYyMFdkZnZYVlBWUGUrd2IyWkRuUitTSzAgcm9vdEBpcC0xMC0wLTEwLTIyMy5lYzIuaW50ZXJuYWwK";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::8";
      systems = ["aarch64-linux"];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["kvm" "big-parallel" "nixos-test" "benchmark"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1EWnAzU1RtZk5oY09EN0E1MktxSmg3L1hna1dra01RTjRsZG5IaXZETEYgcm9vdEBidWlsZHkK";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::22";
      systems = ["x86_64-linux"];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["kvm" "big-parallel" "nixos-test" "benchmark"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUtTTmlPenBremUySGwxcm1IMWQ5VUxvcVE4dUN2ZGY2c1RoRWcyWU9lNVAgcm9vdEBoZXR6bmVyLXg4Ni02NC1pbmRpZ28tMDEK";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::6";
      systems = ["x86_64-linux"];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["kvm" "big-parallel" "nixos-test" "benchmark"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUFHYmlKejZKWEd4MFlBSDZLS050Y1FrVUxnLzYrVDBjN0RjVkp4bWJ6dTYgcm9vdEBoZXR6bmVyLXg4Ni02NC1pbmRpZ28tMDIK";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::12";
      systems = ["aarch64-darwin"];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["kvm" "big-parallel" "nixos-test" "benchmark"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUh5b1dDTXQxcUQ1TmRKRlQyMHVjUFRqbng1clpYaVVQYWxYTFpMVlBITEcgCg==";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::11";
      systems = ["x86_64-darwin"];
      inherit sshKey;
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["kvm" "big-parallel" "nixos-test" "benchmark"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUoxM1lNajNsMjl2YXVyM0pQVlJGanRGNzg0clk3aEw5SnB3QXMzZWp5VU4gCg==";
    }
  ];
}
