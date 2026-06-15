{ lib, ... }:
{
  # home.packages = with pkgs; [
  # ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "127.0.0.1" = {
        userKnownHostsFile = "/dev/null";
        StrictHostKeyChecking = "no";
      };

      "localhost" = lib.hm.dag.entryBefore [ "127.0.0.1" ] {
        userKnownHostsFile = "/dev/null";
        StrictHostKeyChecking = "no";
      };

      "camel" = {
        user = "root";
        hostname = "192.168.178.24";
      };

      "hermi" = {
        hostname = "192.168.117.254";
        port = 22;
        user = "root";
      };

      "wrt" = {
        hostname = "192.168.1.1";
        port = 22;
        user = "root";
        StrictHostKeyChecking = "no";
        userKnownHostsFile = "/dev/null";
      };

      "boot.*" = {
        user = "root";
        StrictHostKeyChecking = "no";
        userKnownHostsFile = "/dev/null";
      };

      "rescue.*" = {
        user = "root";
        StrictHostKeyChecking = "no";
        userKnownHostsFile = "/dev/null";
      };

      "hare" = {
        hostname = "144.76.195.142";
      };

      "hareboot" = {
        port = 2222;
        user = "root";
        hostname = "144.76.195.142";
      };

      # sometimes config files are just a knowledge-base ;)
      "jump-host" = {
        hostname = "144.76.195.142";
        user = "slash";
      };

      "final-server" = {
        hostname = "192.168.122.1";
        user = "slash";
        proxyJump = "jump-host";
      };

      "codeberg.org" = {
        controlMaster = "auto";
        controlPath = "~/.ssh/cm-%r@%h:%p";
        controlPersist = "10m";
      };

      "*" = {
        forwardAgent = false;
        addKeysToAgent = "yes";
        compression = true;
        KexAlgorithms = "sntrup761x25519-sha512@openssh.com,curve25519-sha256,diffie-hellman-group18-sha512";
        HashKnownHosts = "yes";
        VerifyHostKeyDNS = "yes";

      };
    };
  };
}
