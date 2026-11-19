{ lib, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtjkbH0TGABWHHuV5Rrzt0UIKJBkPIo8tHXHoyC9kBT slash@kea"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMofo4uP8iGMw2R1LFzBQu7TuiSqwS28ILf1L1Mx/xGx slash@taz"
  ];
}
