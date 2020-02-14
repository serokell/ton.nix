{ nixos, lib, path, writeShellScriptBin, config, key, ports ? [ ] }:
let hostfwd = lib.concatMapStrings (a: ",hostfwd=tcp::${toString a}-:${toString a}") ports;
in (nixos {
  imports = [ "${path}/nixos/modules/virtualisation/qemu-vm.nix" config ];
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = ports;
  # install the vm-ssh.key.pub for ssh access
  users.users.root.openssh.authorizedKeys.keyFiles = [ "${toString key}.pub" ];
  services.mingetty = {
    autologinUser = "root";
    helpLine = ''
      ssh access:
        ./result/bin/ssh
      update running system (does not survive reboot):
        nix-build -A vm && ./result/bin/switch-running-vm
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
        "-netdev user,id=user.0,hostfwd=tcp::2222-:22${hostfwd}\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
      ];
    };
  };

}).config.system.build.vm.overrideAttrs (old:
  let
    # add switch-running-vm, ssh scripts
    ssh = writeShellScriptBin "ssh" ''
      set -e
      ssh -o StrictHostKeyChecking=no -i ${
        toString key
      } root@localhost -p 2222 "$@"
    '';
    switch-running-vm = writeShellScriptBin "switch-running-vm" ''
      set -e
      $(dirname "$0")/ssh $(realpath $(dirname "$0"))/../system/bin/switch-to-configuration test
    '';
  in {
    buildCommand = old.buildCommand + ''
      ln -s ${switch-running-vm}/bin/* $out/bin/
      ln -s ${ssh}/bin/* $out/bin/
    '';
  })

