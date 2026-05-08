{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    conmon
    fuse-overlayfs
    podman
    podman-bootc
    podman-compose
    podman-tui
    runc
    skopeo
    slirp4netns
  ];

  virtualisation = {
    cri-o.enable = false;
    containers = {
      enable = true;
      registries.search = [ "docker.io" ];
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    # oci-containers = {
    # backend = "podman";
    # containers = {
    # container-name = {
    # image = "container-image";
    # autoStart = true;
    # ports = [ "127.0.0.1:1234:1234" ];
    # };
    # };
    # };
  };
}
