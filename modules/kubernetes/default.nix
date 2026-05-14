{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    cilium-cli
    helm
    k9s
    krew
    kubecolor
    kubectl
    kubectl
    kubectx
    kubelogin
    kubernetes-helm
    # kubernetes-kcp
    kubeswitch
    kubie
    kubefetch
  ];

  imports = [
    ./cert_manager.nix
    ./cilium.nix
    ./traefik.nix
    ./gitea.nix
    ./k3s-backup.nix
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--advertise-address=10.13.0.1"
      "--bind-address=10.13.0.1"
      "--disable-kube-proxy"
      "--disable-network-policy"
      "--disable=servicelb"
      "--disable=traefik"
      "--flannel-backend=none"
      "--node-ip=10.13.0.1"
      "--tls-san=10.13.0.1"
    ];
  };

  virtualisation.containerd = {
    enable = true;
    settings =
      let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs; [
            cni-plugins
            cni-plugin-flannel
          ];
        };
      in
      {
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "${fullCNIPlugins}/bin";
          conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        };
      };
  };
  systemd.services.cilium-interface-cleanup = {
    description = "Clean up lingering Cilium and Flannel interfaces";
    before = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.iproute2}/bin/ip link delete cilium_vxlan 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip link delete cilium_net 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip link delete cilium_host 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip link delete flannel.1 2>/dev/null || true
    '';
  };
}
