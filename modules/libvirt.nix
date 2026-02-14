{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    virter
    virtnbdbackup
    virt-manager
    OVMFFull
  ];
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_full;
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
          					<ip address="192.168.122.1" netmask="255.255.255.0">
          						<dhcp>
          							<range start="192.168.122.10" end="192.168.122.50"/>
          						</dhcp>
          					</ip>
          				</network>
          			'';
      in
      ''
        				if ! ${pkgs.libvirt}/bin/virsh -c qemu:///system net-info k8s-net >/dev/null 2>&1; then
        					${pkgs.libvirt}/bin/virsh -c qemu:///system net-define ${networkXml}
        				fi
        				${pkgs.libvirt}/bin/virsh -c qemu:///system net-start k8s-net || true
        				${pkgs.libvirt}/bin/virsh -c qemu:///system net-autostart k8s-net || true
        			'';
  };

}
