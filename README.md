# zig-deb
Package zig into an apt package for installing on debian / ubuntu

Currently, existing instructions for installing zig via apt are out of date:
https://techviewleo.com/install-zig-programming-language-ubuntu-debian/

According to this issue: https://github.com/ziglang/zig/issues/8623, Bintray
shutdown which caused the hosting of the apt package to no longer work.

Additionally, it appears the maintainer of the repo that was packaging zig
was no longer maintaining it.

## Goals:
This repo has only a couple of goals
- Product an apt package from Zig releases
- Publish to a public repository
- Ideally be as automated as possible
