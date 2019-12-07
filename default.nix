# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

self: super:

let
  sources = import ./nix/sources.nix;
  src = self.fetchFromGitHub {
    inherit (sources.ton) owner repo rev;
    # sadly, not the one niv comes up with
    sha256 = "1znikk7l2pv5mdl9rh59dljdrqkbwnazlpdjr4yfc87bcynb1rbz";
    fetchSubmodules = true;
  };
  version = builtins.substring 0 7 sources.ton.rev;
in

{
  ton = self.callPackage ./pkgs/all.nix { inherit src version; };
}
