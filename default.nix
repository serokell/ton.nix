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
    hash = if version == "ae5c072" then
      "sha256-6sKA3CPcMkkzLpMJULqGWcLg/INLOK5pVaNbljSIwIs=" else
      "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    fetchSubmodules = true;
  };
in

{
  ton = self.callPackage ./pkgs/all.nix { inherit src version; };
}
