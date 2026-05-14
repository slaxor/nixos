{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cloud-provider-kind
    cilium-cli
    gnutls
    k9s
    kubernetes-helm
    kind
    krew
    kubecolor
    kubectl
    kubectx
    kubelogin
    kubeswitch
    kubernetes-kcp
    kubie
    kustomize
  ];

  # Kubernetes aliases
  home.shellAliases = {
    k = "${pkgs.kubectl}/bin/kubectl";
    kctx = "${pkgs.kubectx}/bin/kubectx";
    kns = "${pkgs.kubectx}/bin/kubens";
    kpodfk = "kubectl delete pod --grace-period=0 --force";
    kconf = ''
      ${pkgs.gojq}/bin/gojq --yaml-input 'walk(
        if type == "object" and .["certificate-authority-data"] then
          .["certificate-authority-data"] = (
            .["certificate-authority-data"] |
            (.[0:8] + "..." + .[-8:])
          )
        else . end
      )'
    '';
    kra = ''
      kubectl api-resources --verbs=list --namespaced -o name | \
        xargs -n 1 kubectl get --show-kind --ignore-not-found -A
    ''; # k get (really)all
  };

  programs.bash.initExtra = ''
    source <(kubectl completion bash)
    complete -F __start_kubectl k
    # export KREW_ROOT="$HOME/.krew"
    export PATH="${"$"}{KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  '';

  # systemd.user = {
  # services."kcp" = {
  # Unit = {
  # Description = "KCP Service";
  # After = [ "network-online.target" ];
  # };
  # Service = {
  # ExecStart = "${pkgs.kubernetes-kcp}/bin/kcp start";
  # Restart = "always";
  # RestartSec = 5;
  # };
  # Install = {
  # WantedBy = [ "kind.target" ];
  # };
  # };

  # services."cloud-provider-kind" = {
  # Unit = {
  # Description = "Cloud Provider for Kind";
  # After = [ "network-online.target" ];
  # };
  # Service = {
  # ExecStart = "${pkgs.cloud-provider-kind}/bin/cloud-provider-kind -enable-lb-port-mapping -v 8";
  # Restart = "always";
  # RestartSec = 5;
  # };
  # Install = {
  # WantedBy = [ "kind.target" ];
  # };
  # };

  # targets."kind" = {
  # Unit = {
  # Description = "KCP and Cloud Provider Stack";
  # Wants = [
  # "kcp.service"
  # "cloud-provider-kind.service"
  # ];
  # After = [
  # "kcp.service"
  # "cloud-provider-kind.service"
  # ];
  # };
  # Install = {
  # WantedBy = [ "default.target" ];
  # };
  # };
  # };
}
