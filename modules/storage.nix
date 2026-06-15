{ ... }:
{
  users.groups.hoarders = { };
  systemd.tmpfiles.rules = [
    "d /data/dump 2775 root hoarders - -"
  ];
}
