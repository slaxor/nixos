{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [
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
          email: "sascha.teske@microprojects.de"
          privateKeySecretRef:
            name: letsencrypt-prod
          solvers:
            - dns01:
                webhook:
                  groupName: acme.hetzner.com
                  solverName: hetzner
                  config:
                    tokenSecretKeyRef:
                      name: hetzner-dns-token
                      key: token
              selector:
                dnsZones:
                  - "m11s.de"
                  - "slaxor.de"
                  - "slaxor.com"
    ''}"

    "L+ /var/lib/rancher/k3s/server/manifests/cert-manager-issuer-internal.yaml - - - - ${pkgs.writeText "cert-manager-issuer-internal.yaml" ''
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
              selector:
                dnsZones:
                  - "int.m11s.de"
                  - "int.slaxor.de"
                  - "int.slaxor.com"
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
  ];
}
