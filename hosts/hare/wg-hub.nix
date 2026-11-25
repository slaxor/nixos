let
  kea = "10.13.0.17";
in
{
  publicKey = "3GPB7wIX/lWLV5C54teL0D0/FvhOgJXazx8Fsv+ZbH0=";
  endpoint = "wg.m11s.de:51820";
  network = "10.13.0.0/24";
  inherit kea;
  install = {
    subnet = "10.13.0.240/28";
    admins = [ kea ];
  };
}
