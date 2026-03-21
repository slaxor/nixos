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

  # systemd.tmpfiles.rules = [
  # "L+ /var/lib/rancher/k3s/server/manifests/cilium.yaml - - - - ${pkgs.writeText "cilium-helmchart.yaml" ''
  # apiVersion: helm.cattle.io/v1
  # kind: HelmChart
  # metadata:
  # name: cilium
  # namespace: kube-system
  # spec:
  # repo: https://helm.cilium.io/
  # chart: cilium
  # version: "1.19.1"
  # targetNamespace: kube-system
  # bootstrap: true
  # valuesContent: |-
  # kubeProxyReplacement: true
  # k8sServiceHost: "10.13.0.1"
  # k8sServicePort: 6443
  # socketLB:
  # hostNamespaceOnly: true
  # ipam:
  # mode: kubernetes
  # operator:
  # replicas: 1
  # hubble:
  # enabled: true
  # relay:
  # enabled: true
  # listenHost: "0.0.0.0"
  # ui:
  # enabled: true
  # service:
  # type: ClusterIP
  # externalIPs:
  # - "10.13.0.1"
  # ports:
  # - port: 12000
  # targetPort: 8081
  # ''}"

  # "L+ /var/lib/rancher/k3s/server/manifests/cert-manager.yaml - - - - ${pkgs.writeText "cert-manager-helmchart.yaml" ''
  # apiVersion: helm.cattle.io/v1
  # kind: HelmChart
  # metadata:
  # name: cert-manager
  # namespace: kube-system
  # spec:
  # repo: https://charts.jetstack.io
  # chart: cert-manager
  # version: "v1.20.0"
  # targetNamespace: cert-manager
  # createNamespace: true
  # valuesContent: |-
  # crds:
  # enabled: true
  # ''}"

  # "L+ /var/lib/rancher/k3s/server/manifests/cert-manager-issuer.yaml - - - - ${pkgs.writeText "cert-manager-issuer.yaml" ''
  # apiVersion: cert-manager.io/v1
  # kind: ClusterIssuer
  # metadata:
  # name: letsencrypt-prod
  # spec:
  # acme:
  # server: https://acme-v02.api.letsencrypt.org/directory
  # email: "sascha.teske@microrprojects.de"
  # privateKeySecretRef:
  # name: letsencrypt-prod
  # solvers:
  # - http01:
  # ingress:
  # ingressClassName: traefik
  # ''}"

  # "L+ /var/lib/rancher/k3s/server/manifests/traefik-custom.yaml - - - - ${pkgs.writeText "traefik-helmchart.yaml" ''
  # apiVersion: helm.cattle.io/v1
  # kind: HelmChart
  # metadata:
  # name: traefik
  # namespace: kube-system
  # spec:
  # repo: https://traefik.github.io/charts
  # chart: traefik
  # version: "v39.1.0-ea.2"
  # targetNamespace: traefik
  # createNamespace: true
  # valuesContent: |-
  # deployment:
  # replicas: 1
  # service:
  # type: LoadBalancer
  # spec:
  # externalIPs:
  # - "144.76.195.142"
  # - "10.13.0.1"
  # - "2a01:4f8:200:7181::1"

  # ports:
  # web:
  # port: 80
  # exposedPort: 80
  # websecure:
  # port: 443
  # exposedPort: 443
  # ingressClass:
  # enabled: true
  # providers:
  # kubernetesIngress:
  # enabled: true
  # kubernetesCRD:
  # enabled: true
  # ''}"
  # ];

  systemd.services.k3s-manifests = {
    description = "Sync k3s manifests from nix store";
    before = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script =
      let
        ciliumChart = pkgs.writeText "cilium-helmchart.yaml" ''
          apiVersion: helm.cattle.io/v1
          kind: HelmChart
          metadata:
            name: cilium
            namespace: kube-system
          spec:
            repo: https://helm.cilium.io/
            chart: cilium
            version: "1.19.1"
            targetNamespace: kube-system
            bootstrap: true
            valuesContent: |-
              kubeProxyReplacement: true
              k8sServiceHost: "10.13.0.1"
              k8sServicePort: 6443
              socketLB:
                hostNamespaceOnly: true
              ipam:
                mode: kubernetes
              operator:
                replicas: 1
              hubble:
                enabled: true
                relay:
                  enabled: true
                  listenHost: "0.0.0.0"
                ui:
                  enabled: true
                  service:
                    type: ClusterIP
                    externalIPs:
                      - "10.13.0.1"
                    ports:
                      - port: 12000
                        targetPort: 8081
        '';
        traefikChart = pkgs.writeText "traefik-helmchart.yaml" ''
          apiVersion: helm.cattle.io/v1
          kind: HelmChart
          metadata:
            name: traefik
            namespace: kube-system
          spec:
            repo: https://traefik.github.io/charts
            chart: traefik
            version: "v39.1.0-ea.2"
            targetNamespace: traefik
            createNamespace: true
            valuesContent: |-
              deployment:
                replicas: 1
              service:
                type: LoadBalancer
                spec:
                  externalIPs:
                    - "144.76.195.142"
                    - "10.13.0.1"
                    - "2a01:4f8:200:7181::1"

              ports:
                web:
                  port: 80
                  exposedPort: 80
                websecure:
                  port: 443
                  exposedPort: 443
              ingressClass:
                enabled: true
              providers:
                kubernetesIngress:
                  enabled: true
                kubernetesCRD:
                  enabled: true
        '';
        certManagerChart = pkgs.writeText "cert-manager-helmchart.yaml" ''
          apiVersion: helm.cattle.io/v1
          kind: HelmChart
          metadata:
            name: cert-manager
            namespace: kube-system
          spec:
            repo: https://charts.jetstack.io
            chart: cert-manager
            version: "v1.20.0"
            targetNamespace: cert-manager
            createNamespace: true
            valuesContent: |-
              crds:
                enabled: true
        '';
        certManagerIssuer = pkgs.writeText "cert-manager-issuer.yaml" ''
          apiVersion: cert-manager.io/v1
          kind: ClusterIssuer
          metadata:
            name: letsencrypt-prod
          spec:
            acme:
              server: https://acme-v02.api.letsencrypt.org/directory
              email: "sascha.teske@microrprojects.de"
              privateKeySecretRef:
                name: letsencrypt-prod
              solvers:
                - http01:
                    ingress:
                      ingressClassName: traefik
        '';
        acmeDns = pkgs.writeText "acme-dns.yaml" ''
          apiVersion: v1
          kind: Namespace
          metadata:
            name: acme-dns
          ---
          apiVersion: v1
          kind: PersistentVolumeClaim
          metadata:
            name: acme-dns-data
            namespace: acme-dns
          spec:
            accessModes: [ReadWriteOnce]
            resources:
              requests:
                storage: 1Gi
          ---
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: acme-dns-config
            namespace: acme-dns
          data:
            config.cfg: |
              [general]
              listen = "0.0.0.0:53"
              protocol = "both"
              domain = "acme-dns.t5l.de"
              nsname = "acme-dns.t5l.de"
              nsadmin = "admin.t5l.de"
              records = [
                "acme-dns.t5l.de. A 144.76.195.142",
                "acme-dns.t5l.de. AAAA 2a01:4f8:200:7181::1",
              ]
              debug = false

              [database]
              engine = "sqlite"
              connection = "/var/lib/acme-dns/acme-dns.db"

              [api]
              ip = "0.0.0.0"
              disable_registration = false
              autocert = false
              port = "8080"
              tls = "none"
              corsorigins = ["*"]
              use_header = false
              header_name = "X-Forwarded-For"

              [logconfig]
              loglevel = "info"
              logtype = "stdout"
          ---
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: acme-dns
            namespace: acme-dns
          spec:
            replicas: 1
            selector:
              matchLabels:
                app: acme-dns
            template:
              metadata:
                labels:
                  app: acme-dns
              spec:
                containers:
                  - name: acme-dns
                    image: joohoi/acme-dns:v2.0.2
                    ports:
                      - containerPort: 53
                        protocol: UDP
                        name: dns-udp
                      - containerPort: 53
                        protocol: TCP
                        name: dns-tcp
                      - containerPort: 8080
                        name: api
                    volumeMounts:
                      - name: config
                        mountPath: /etc/acme-dns
                      - name: data
                        mountPath: /var/lib/acme-dns
                volumes:
                  - name: config
                    configMap:
                      name: acme-dns-config
                  - name: data
                    persistentVolumeClaim:
                      claimName: acme-dns-data
          ---
          apiVersion: v1
          kind: Service
          metadata:
            name: acme-dns-dns
            namespace: acme-dns
          spec:
            selector:
              app: acme-dns
            type: LoadBalancer
            externalIPs:
              - "144.76.195.142"
              - "2a01:4f8:200:7181::1"
            ports:
              - name: dns-udp
                port: 53
                protocol: UDP
                targetPort: 53
              - name: dns-tcp
                port: 53
                protocol: TCP
                targetPort: 53
          ---
          apiVersion: v1
          kind: Service
          metadata:
            name: acme-dns-api
            namespace: acme-dns
          spec:
            selector:
              app: acme-dns
            type: ClusterIP
            ports:
              - name: api
                port: 8080
                targetPort: 8080
        '';
        certManagerIssuerInternal = pkgs.writeText "cert-manager-issuer-internal.yaml" ''
          apiVersion: cert-manager.io/v1
          kind: ClusterIssuer
          # ... letsencrypt-internal (DNS-01 via acme-dns)
          # references the secret by NAME only, doesn't contain the value
        '';
        giteaChart = pkgs.writeText "gitea-helmchart.yaml" ''
          apiVersion: helm.cattle.io/v1
          kind: HelmChart
          # ... gitea values
        '';

      in
      ''
        mkdir -p /var/lib/rancher/k3s/server/manifests
        install -m 0644 ${ciliumChart}                /var/lib/rancher/k3s/server/manifests/cilium.yaml
        install -m 0644 ${traefikChart}               /var/lib/rancher/k3s/server/manifests/traefik-custom.yaml
        install -m 0644 ${certManagerChart}           /var/lib/rancher/k3s/server/manifests/cert-manager.yaml
        install -m 0644 ${certManagerIssuer}          /var/lib/rancher/k3s/server/manifests/cert-manager-issuer.yaml
        install -m 0644 ${acmeDns}                    /var/lib/rancher/k3s/server/manifests/acme-dns.yaml
        install -m 0644 ${certManagerIssuerInternal}  /var/lib/rancher/k3s/server/manifests/cert-manager-issuer-internal.yaml
        install -m 0644 ${giteaChart}                 /var/lib/rancher/k3s/server/manifests/gitea.yaml
      '';
  };

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
  # "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
  # "--cluster-init"
  # "--disable servicelb" # optional if you don't need default load balancer
  # "--disable traefik" # we’ll use nginx ingress
  # "--disable-network-policy"
  # "--etcd-snapshot-retention=10"
  # "--etcd-snapshot-schedule-cron=0 */6 * * *"
  # "--flannel-backend=none"
  # "--kubelet-arg=anonymous-auth=false"
  # "--kubelet-arg=feature-gates=GracefulNodeShutdown=true"
  # "--kubelet-arg=shutdown-grace-period-critical-pods=10s"
  # "--kubelet-arg=shutdown-grace-period=30s"
  # "--node-ip=144.76.195.142"
  # "--tls-san=144.76.195.142"
  # "--node-ip=${customSettings.publicIPv4}"
  # "--container-runtime-endpoint=unix:///var/run/crio/crio.sock"
  # "--docker=false"
  # "--kubelet-arg=v=4" # Optionally add additional args to k3s

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
        # Optionally set private registry credentials here instead of using /etc/rancher/k3s/registries.yaml
        # plugins."io.containerd.grpc.v1.cri".registry.configs."registry.example.com".auth = {
        #  username = "";
        #  password = "";
        # };
      };
  };
  # networking.firewall.trustedInterfaces = [
  # "cilium_host"
  # "cilium_net"
  # "cilium_vxlan"
  # "lxc+"
  # ];

  # systemd.mounts = [
  # {
  # what = "bpffs";
  # where = "/sys/fs/bpf";
  # type = "bpf";
  # }
  # ];
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
