#!/bin/bash
ZIG_VERSION=0.8.1
DEB_EMAIL=ernstjason1@gmail.com
wget -O zig_${ZIG_VERSION}.orig.tar.gz https://github.com/ziglang/zig/archive/refs/tags/${ZIG_VERSION}.tar.gz
tar xvf zig_${ZIG_VERSION}.orig.tar.gz
cd zig-${ZIG_VERSION}
dh_make --single --copyright mit --yes --email $DEB_EMAIL
cd /tmp
mk-build-deps --install --tool='apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes' /usr/src/zig-${ZIG_VERSION}/debian/control
cd /usr/src/zig-${ZIG_VERSION}/debian
