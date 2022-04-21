ARG ZIG_VERSION=0.8.1
ARG RELEASE=2
ARG ZIG_ARCH=x86_64
ARG DEB_ARCH=amd64

FROM ubuntu:jammy as prereqs
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    xz-utils \
    checkinstall \
    && apt-get update -qq && apt-get clean

FROM prereqs as build
WORKDIR /usr/src/zig
ARG ZIG_VERSION
ARG RELEASE
ARG DEB_ARCH
ARG ZIG_ARCH
RUN wget -O zig.tar.xz https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz && \
    tar xf zig.tar.xz --strip-components 1
COPY install.sh .
RUN echo "zig language compiler" > description-pak \
  && checkinstall -D --install=no -y --pkgname=zig --pkgversion=${ZIG_VERSION} --pkgrelease=${RELEASE} \
    --pkgarch=${DEB_ARCH} --pkglicense="See upstream" \
    --pakdir=/ --maintainer="compscidr" --nodoc ./install.sh
# RUN dpkg -i /zig_${ZIG_VERSION}-${RELEASE}_${DEB_ARCH}.deb
# can't actually do this step ^^ if the arch of the system doesn't match the arch of the deb

# deploys the deb package to gemfury
FROM ubuntu:jammy as deploy
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     curl \
     gnupg2 \
     software-properties-common \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ARG ZIG_VERSION
ARG RELEASE
ARG DEB_ARCH
COPY --from=build /zig_${ZIG_VERSION}-${RELEASE}_${DEB_ARCH}.deb /tmp
ARG GFKEY_PUSH
RUN test -n "${GFKEY_PUSH}" || (>&2 echo "GFKEY_PUSH build arg not set" && false)
RUN curl -F package=@/tmp/zig_${ZIG_VERSION}-${RELEASE}_${DEB_ARCH}.deb https://${GFKEY_PUSH}@push.fury.io/compscidr/