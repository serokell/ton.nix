# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

{ src, version

, stdenv, lib
, cmake, pkgconfig
, openssl, readline, zlib
, git
, libmicrohttpd
}:

stdenv.mkDerivation rec {
  pname = "ton";
  inherit version src;

  patches =
    [ ./patches/tonlib-cmake-config.patch ./patches/install-binaries.patch ];

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ openssl readline zlib libmicrohttpd git ];
}
