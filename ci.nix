# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

let
  sources = import nix/sources.nix;
  overlay = import ./.;
  nixpkgs = import sources.nixpkgs { overlays = [ overlay ]; };
in with nixpkgs;
lib.filterAttrs (n: _: lib.hasAttr n (overlay {} {})) nixpkgs
