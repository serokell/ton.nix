# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

{
  services.openssh.enable = true;
  # install the vm-ssh.key.pub for ssh access
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../vm-ssh.key.pub ];
  services.mingetty = {
    autologinUser = "root";
    helpLine = ''
      ssh access:
        ./result/bin/ssh
      update running system (does not survive reboot):
        nix-build -A vm && ./result/bin/switch-running-vm
      website:
        http://localhost:8080/
      to get out:
        poweroff
    '';
  };
  # qemu settings:
  virtualisation = {
    memorySize = 1024;
    diskSize = 1024;
    # set up serial console
    graphics = false;
    qemu = {
      options = [ "-serial mon:stdio" ];
      # forward port 22 to 2222 and port 80 to 8080
      # based on the default in nixpkgs
      networkingOptions = [
        "-net nic,netdev=user.0,model=virtio"
        "-netdev user,id=user.0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
      ];
    };
  };
}
