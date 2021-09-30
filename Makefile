# copied in after stage 2 is built to locate zig in the correct location
# otherwise running "make install" doesn't seem to actually move zig into a good spot where we can use it
install:
	cp -r bin/* /usr/bin
	cp -r lib/* /usr/lib