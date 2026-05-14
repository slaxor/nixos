{ pkgs, ... }:
{
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
  ];
}
