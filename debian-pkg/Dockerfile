# note: this is assumed to be run on an amd64 arch
ARG ZIG_VERSION=0.8.1
# currently can't bulid in bullseye because llvm-12-dev is not in there
FROM debian:sid as prereqs
ENV DEBEMAIL="ernstjason1@gmail.com"
ENV DEBFULLNAME="Jason Ernst"
RUN echo "deb-src http://deb.debian.org/debian sid main" >> /etc/apt/sources.list
RUN dpkg --add-architecture i386
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    crossbuild-essential-i386 \
    wget \
    ca-certificates \
    dh-make \
    devscripts \
    debhelper \
    equivs \
    gpg \
    dput \
    pbuilder \
    qemu-user-static \
    debian-archive-keyring \
    && apt-get update -qq && apt-get clean
WORKDIR /usr/src
ARG ZIG_VERSION
RUN wget -O zig_${ZIG_VERSION}.orig.tar.gz https://github.com/ziglang/zig/archive/refs/tags/${ZIG_VERSION}.tar.gz
RUN tar xvf zig_${ZIG_VERSION}.orig.tar.gz
WORKDIR /usr/src/zig-${ZIG_VERSION}
RUN dh_make --single --copyright expat --yes --email $DEBEMAIL
COPY debian debian
WORKDIR /tmp
RUN mk-build-deps --install --tool='apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes' /usr/src/zig-${ZIG_VERSION}/debian/control
ARG GPG_KEY
ARG GPG_PASS
RUN --mount=type=secret,id=mysecret,target=/tmp/key.txt gpg -v --batch --passphrase "${GPG_PASS}" --import /tmp/key.txt
WORKDIR /usr/src/zig-${ZIG_VERSION}/debian
RUN GPG_TTY=$(tty) debuild -p"gpg --batch --passphrase ${GPG_PASS} --pinentry-mode loopback"

#COPY .pbuilderrc /root/
#RUN OS=debian DIST=sid ARCH=i386 pbuilder --create
#WORKDIR /usr/src
#COPY .dput.cf /root/
#RUN cat zig_0.8.1-0_amd64.changes
# only uncomment this when ready to publish
# dput mentors zig_0.8.1-0_amd64.changes