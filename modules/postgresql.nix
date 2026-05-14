{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    postgresql
    plan-exporter
  ];

  # services = {
  # };
}
