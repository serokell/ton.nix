# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

self: super:

let
  sources = import ./nix/sources.nix;
  version = builtins.substring 0 7 sources.ton.rev;
  src = self.fetchFromGitHub {
    inherit (sources.ton) owner repo rev;
    # sadly, not the one niv comes up with. add this check
    # to make sure people update the hash
    sha256 = if version == "ceaed40" then
      "1znikk7l2pv5mdl9rh59dljdrqkbwnazlpdjr4yfc87bcynb1rbz" else
      "0000000000000000000000000000000000000000000000000000";
    fetchSubmodules = true;
  };
in

{
  ton = self.callPackage ./pkgs/all.nix { inherit src version; };
  ton-vm = self.callPackage ./pkgs/vm.nix {
    key = ./modules/vm/vm-ssh.key;
    ports = [ 29108 29109 29110 ];
    config.imports = [ ./modules/ton.nix ];
    config.services.ton = {
      enable = true;
      ports.main = 29108;
      ports.console = 29109;
      ports.lite = 29110;
      allowed_clients = { "jLl01+sOhXSANIe7kGtI/1mEYZTOf9YdzhzyDBnspVo=" = 15; };
    };
  };
}
