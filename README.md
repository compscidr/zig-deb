# zig-deb
Package [zig](https://github.com/ziglang/zig) from the release into an apt package for installing on debian / ubuntu.
Uses the binary build from the zig release page.

To use, add the following to `/etc/apt/sources.list.d/zig.list`:
```
deb [trusted=yes] https://apt.fury.io/compscidr/ /
```

Then run:
```
sudo apt update
sudo apt install zig
```

# todo
- [ ] Automate deploy when a new release has come out
