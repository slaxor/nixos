{ ... }:
{
  users.users.rita = {
    isNormalUser = true;
    uid = 10001;
    extraGroups = [
      "audio"
      "lp"
      "networkmanager"
      "video"
    ];
  };
}
