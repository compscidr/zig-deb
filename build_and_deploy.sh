#!/bin/bash
# takes inspiration from: https://github.com/jayschwa/snapcraft-zig/blob/master/update_edge.sh

for pair in "aarch64 arm64" "armv7a armhf" "i386 i386" "x86_64 amd64"; do
	zig_arch=$(echo $pair | awk '{print $1}')
	deb_arch=$(echo $pair | awk '{print $2}')
	githash=$(git rev-parse --short HEAD)
	docker build -f Dockerfile --target deploy --build-arg GFKEY_PUSH=$GFKEY_PUSH --build-arg ZIG_ARCH=$zig_arch --build-arg  DEB_ARCH=$deb_arch -t zig:$githash .
done