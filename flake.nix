# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

{
  edition = 201909;

  description = "Nix tools for the TON blockchain";

  outputs = { self, nixpkgs }:

    let
      supportedSystems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

    in {

      overlay = import ./.;

      defaultPackage = forAllSystems (system:
        (import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        }).ton);

      checks =
        forAllSystems (system: { build = self.defaultPackage.${system}; });

      nixosModules.ton = {
        nixpkgs.overlays = [ self.overlay ];
        imports = [ ./modules/ton.nix ];
      };
    };
}
