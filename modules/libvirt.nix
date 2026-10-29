{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    virter
    virtnbdbackup
    virt-manager
    OVMF
  ];

  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        # package = pkgs.qemu_full.override { cephSupport = false; };
        # package = pkgs.qemu;
        swtpm.enable = true;
      };
    };
  };

  systemd.services.libvirt-network-k8s = {
    description = "Define and start libvirt network 'k8s-net'";
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script =
      let
        networkXml = pkgs.writeText "k8s-net.xml" ''
          				<network>
          					<name>k8s-net</name>
          					<bridge name="virbr-k8s"/>
          					<forward mode="nat"/>
          					<ip address="192.168.123.1" netmask="255.255.255.0">
          						<dhcp>
          							<range start="192.168.123.10" end="192.168.123.50"/>
          						</dhcp>
          					</ip>
          				</network>
          			'';
      in
      ''
        virsh() { ${pkgs.libvirt}/bin/virsh -c qemu:///system "$@"; }
        has_net() { virsh net-list "$@" --name | ${pkgs.gnugrep}/bin/grep -qx k8s-net; }
        if ! has_net --all; then
          virsh net-define ${networkXml}
        fi
        if ! has_net; then
          virsh net-start k8s-net
        fi
        virsh net-autostart k8s-net
      '';

  };

}
