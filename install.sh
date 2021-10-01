#!/bin/bash
cp zig /usr/bin
# default search path: https://github.com/ziglang/zig/blob/057a5d4898f70c6a8169c99375fbb8631e539051/std/build.zig#L383-L395
cp -r lib/* /usr/lib