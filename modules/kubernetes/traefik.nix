{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [
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
            externalTrafficPolicy: Local
            spec:
              externalIPs:
                - "144.76.195.142"
                - "10.13.0.1"
                - "2a01:4f8:200:7181::1"
          ports:
            web:
              http:
                redirections:
                  entryPoint:
                    to: websecure
                    scheme: https
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
  ];
}
