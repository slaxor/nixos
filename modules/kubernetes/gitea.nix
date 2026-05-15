{ pkgs, ... }:
let
  fqdn = "git.int.m11s.de";
in
{
  systemd.tmpfiles.rules = [
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
              - host: ${fqdn}
                paths:
                  - path: /
                    pathType: Prefix
            tls:
              - secretName: gitea-tls
                hosts:
                  - ${fqdn}
            annotations:
              cert-manager.io/cluster-issuer: "letsencrypt-internal"
              traefik.ingress.kubernetes.io/router.middlewares: traefik-wireguard-only@kubernetescrd
          gitea:
            admin:
              existingSecret: gitea-admin
            config:
              server:
                DOMAIN: ${fqdn}
                ROOT_URL: https://${fqdn}
                SSH_DOMAIN: ${fqdn}
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
              repository:
                DEFAULT_PRIVATE: false
              packages:
                DEFAULT_PRIVATE: false
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
}
