# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

{ src, version

, stdenv, lib
, cmake, pkgconfig
, openssl, readline, zlib
}:

stdenv.mkDerivation rec {
  pname = "ton";
  inherit version;
  name = "${pname}-${version}";

  inherit src;

  patches = [ ./patches/tonlib-cmake-config.patch ];

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ openssl readline zlib ];
}
