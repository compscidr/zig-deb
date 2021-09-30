ARG ZIG_VERSION=0.8.1

FROM ubuntu:focal as prereqs
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    cmake \
    git \
    ninja-build \
    ca-certificates \
    python3 \
    && apt-get update -qq && apt-get clean

FROM prereqs as tools
WORKDIR /usr/src
RUN git clone --depth=1 --single-branch --branch release/12.x https://github.com/llvm/llvm-project llvm-project
WORKDIR /usr/src/llvm-project/llvm/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_LIBXML2=OFF -G Ninja -DLLVM_PARALLEL_LINK_JOBS=1
RUN ninja install
WORKDIR /usr/src/llvm-project/lld/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release  -G Ninja -DLLVM_PARALLEL_LINK_JOBS=1
RUN ninja install
WORKDIR /usr/src/llvm-project/clang/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release  -G Ninja -DLLVM_PARALLEL_LINK_JOBS=1
RUN ninja install

FROM tools as build
WORKDIR /usr/src
ARG ZIG_VERSION
RUN git clone --single-branch --branch ${ZIG_VERSION} https://github.com/ziglang/zig.git
WORKDIR /usr/src/zig/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && make -j `nproc`
RUN ./zig build --prefix $(pwd)/stage2 -Denable-llvm
WORKDIR /usr/src/zig/build/stage2
COPY Makefile .
RUN apt-get install checkinstall -y --no-install-recommends
RUN echo "Zig package" > description-pak \
  && checkinstall -D --install=no -y --pkgname=zig --pkgversion=${ZIG_VERSION} --pkglicense="See upstream" \
    --pakdir=/ --maintainer="Jason Ernst" --nodoc
RUN dpkg -i /zig_${ZIG_VERSION}-1_amd64.deb

FROM ubuntu:focal as test
ARG ZIG_VERSION
COPY --from=build /zig_${ZIG_VERSION}-1_amd64.deb /tmp
RUN dpkg-deb -c /tmp/zig_${ZIG_VERSION}-1_amd64.deb
RUN dpkg -i /tmp/zig_${ZIG_VERSION}-1_amd64.deb
RUN zig version