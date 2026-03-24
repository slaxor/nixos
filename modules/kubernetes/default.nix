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

  systemd.tmpfiles.rules = [
    "L+ /var/lib/rancher/k3s/server/manifests/cilium.yaml - - - - ${pkgs.writeText "cilium-helmchart.yaml" ''
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
    ''}"
    "L+ /var/lib/rancher/k3s/server/manifests/traefik-custom.yaml - - - - ${pkgs.writeText "traefik-helmchart.yaml" ''
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
            isDefaultClass: true
          providers:
            kubernetesIngress:
              enabled: true
            kubernetesCRD:
              enabled: true
          additionalArguments:
            []
          extraObjects:
            - apiVersion: traefik.io/v1alpha1
              kind: Middleware
              metadata:
                name: wireguard-only
                namespace: traefik
              spec:
                ipAllowList:
                  sourceRange:
                    - "10.13.0.0/24"
    ''}"
    "L+ /var/lib/rancher/k3s/server/manifests/cert-manager.yaml - - - - ${pkgs.writeText "cert-manager-helmchart.yaml" ''
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
    ''}"
    "L+ /var/lib/rancher/k3s/server/manifests/cert-manager-issuer.yaml - - - - ${pkgs.writeText "cert-manager-issuer.yaml" ''
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
    ''}"
    "L+ /var/lib/rancher/k3s/server/manifests/cert-manager-webhook-hetzner.yaml - - - - ${pkgs.writeText "cert-manager-webhook-hetzner.yaml" ''
      apiVersion: helm.cattle.io/v1
      kind: HelmChart
      metadata:
        name: cert-manager-webhook-hetzner
        namespace: kube-system
      spec:
        repo: https://charts.hetzner.cloud
        chart: cert-manager-webhook-hetzner
        targetNamespace: cert-manager
        valuesContent: |-
          groupName: acme.hetzner.com
    ''}"
    "L+ /var/lib/rancher/k3s/server/manifests/cert-manager-webhook-hetzner-rbac.yaml - - - - ${pkgs.writeText "cert-manager-webhook-hetzner-rbac.yaml" ''
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRole
      metadata:
        name: cert-manager-webhook-hetzner
      rules:
        - apiGroups:
            - acme.m11s.de
          resources:
            - "*"
          verbs:
            - create
      ---
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: cert-manager-webhook-hetzner
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: cert-manager-webhook-hetzner
      subjects:
        - apiGroup: ""
          kind: ServiceAccount
          name: cert-manager
          namespace: cert-manager
      ---
      apiVersion: rbac.authorization.k8s.io/v1
      kind: Role
      metadata:
        name: cert-manager-webhook-hetzner-secret
        namespace: cert-manager
      rules:
        - apiGroups: [""]
          resources: ["secrets"]
          verbs: ["get", "watch", "list"]
      ---
      apiVersion: rbac.authorization.k8s.io/v1
      kind: RoleBinding
      metadata:
        name: cert-manager-webhook-hetzner-secret
        namespace: cert-manager
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: Role
        name: cert-manager-webhook-hetzner-secret
      subjects:
        - apiGroup: ""
          kind: ServiceAccount
          name: cert-manager-webhook-hetzner
          namespace: cert-manager
    ''}"
    "L+ /var/lib/rancher/k3s/server/manifests/cert-manager-issuer-internal.yaml - - - - ${pkgs.writeText "cert-manager-issuer-internal.yaml" ''
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-internal
      spec:
        acme:
          server: https://acme-v02.api.letsencrypt.org/directory
          email: "sascha.teske@microprojects.de"
          privateKeySecretRef:
            name: letsencrypt-internal
          solvers:
            - dns01:
                webhook:
                  groupName: acme.hetzner.com
                  solverName: hetzner
                  config:
                    tokenSecretKeyRef:
                      name: hetzner-dns-token
                      key: token
    ''}"
    "L+ /var/lib/rancher/k3s/server/manifests/gitea.yaml - - - - ${pkgs.writeText "gitea-helmchart.yaml" ''
      apiVersion: helm.cattle.io/v1
      kind: HelmChart
      metadata:
        name: gitea
        namespace: kube-system
      spec:
        repo: https://dl.gitea.com/charts/
        chart: gitea
        version: "11.0.0"
        targetNamespace: gitea
        createNamespace: true
        valuesContent: |-
          ingress:
            enabled: true
            ingressClassName: traefik
            hosts:
              - host: gitea.int.m11s.de
                paths:
                  - path: /
                    pathType: Prefix
            tls:
              - secretName: gitea-tls
                hosts:
                  - gitea.int.m11s.de
            annotations:
              cert-manager.io/cluster-issuer: "letsencrypt-internal"
              traefik.ingress.kubernetes.io/router.middlewares: traefik-wireguard-only@kubernetescrd
          gitea:
            admin:
              existingSecret: gitea-admin
            config:
              server:
                DOMAIN: gitea.int.m11s.de
                ROOT_URL: https://gitea.int.m11s.de
                SSH_DOMAIN: gitea.int.m11s.de
                SSH_PORT: 22
                START_SSH_SERVER: true
              database:
                DB_TYPE: sqlite3
              session:
                PROVIDER: memory
              cache:
                ADAPTER: memory
              queue:
                TYPE: level
          service:
            ssh:
              type: LoadBalancer
              port: 22
              externalIPs:
                - "10.13.0.1"
          postgresql:
            enabled: false
          postgresql-ha:
            enabled: false
          redis-cluster:
            enabled: false
          persistence:
            enabled: true
            size: 10Gi
    ''}"
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
