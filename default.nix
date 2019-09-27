# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

self: super:

let
  src = super.fetchFromGitHub {
    owner = "ton-blockchain";
    repo = "ton";
    rev = "ac3eb1a7b86b4a5351210c4e2670e470f721b7df";
    sha256 = "1cbv14c60xmy4fanhmf9cdhj845kx6r54b8i0pljkhpv1sy74awd";
    fetchSubmodules = true;
  };

  version = "2019-09-25";

  callPackage = super.newScope { inherit src version; };
in

{
  ton = callPackage ./pkgs/all.nix {};
}
