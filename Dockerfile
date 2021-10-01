ARG ZIG_VERSION=0.8.1
ARG RELEASE=2

FROM ubuntu:focal as prereqs
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
RUN wget -O zig.tar.xz https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz && \
    tar xf zig.tar.xz --strip-components 1
COPY install.sh .
RUN echo "zig language compiler" > description-pak \
  && checkinstall -D --install=no -y --pkgname=zig --pkgversion=${ZIG_VERSION} --pkgrelease=${RELEASE} --pkglicense="See upstream" \
    --pakdir=/ --maintainer="compscidr" --nodoc ./install.sh
RUN dpkg -i /zig_${ZIG_VERSION}-${RELEASE}_amd64.deb

## starts from a fresh ubuntu image and tries to install the deb we just created and then checks the version
FROM ubuntu:focal as test
ARG ZIG_VERSION
ARG RELEASE
COPY --from=build /zig_${ZIG_VERSION}-${RELEASE}_amd64.deb /tmp
RUN dpkg-deb -c /tmp/zig_${ZIG_VERSION}-${RELEASE}_amd64.deb
RUN dpkg -i /tmp/zig_${ZIG_VERSION}-${RELEASE}_amd64.deb
RUN zig version

# deploys the deb package to gemfury
FROM ubuntu:focal as deploy
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     curl \
     gnupg2 \
     software-properties-common \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ARG ZIG_VERSION
ARG RELEASE
COPY --from=build /zig_${ZIG_VERSION}-${RELEASE}_amd64.deb /tmp
ARG GFKEY_PUSH
RUN test -n "${GFKEY_PUSH}" || (>&2 echo "GFKEY_PUSH build arg not set" && false)
RUN curl -F package=@/tmp/zig_${ZIG_VERSION}-${RELEASE}_amd64.deb https://${GFKEY_PUSH}@push.fury.io/compscidr/