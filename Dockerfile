FROM debian:bullseye-slim as build

WORKDIR /horizon

# Update distro and install dependencies
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    gcc \
    libc6-dev \
    wget \
    python \
    libssl-dev \
    curl \
    cmake \
    pkg-config \
    clang \
    llvm-9-dev \
    llvm-9-tools \
    zlib1g-dev \
    gcc-multilib \
    g++-multilib

# Install devkitPro Pacman
RUN wget https://github.com/devkitPro/pacman/releases/download/devkitpro-pacman-1.0.1/devkitpro-pacman.deb
RUN dpkg -i devkitpro-pacman.deb

ENV DEVKITPRO=/opt/devkitpro
ENV PATH=$DEVKITPRO/pacman/bin:$DEVKITPRO/devkitA64/bin:$DEVKITPRO/tools/bin:$PATH
ENV CXX_aarch64_unknown_horizon_libnx=/opt/devkitpro/devkitA64/bin/aarch64-none-elf-gcc              
ENV CC_aarch64_unknown_horizon_libnx=/opt/devkitpro/devkitA64/bin/aarch64-none-elf-gcc               
ENV CPATH=/usr/include 

RUN pacman -Sy
RUN yes | pacman -S \
    switch-tools \
    libnx \
    devkitA64 \
    devkit-env

RUN git clone --depth=1 --branch=horizon https://github.com/leo60228/rust.git
RUN cd rust && git submodule update --init src/tools/rust-installer
RUN cd rust && git submodule update --init src/stdarch
RUN cd rust && git submodule update --init src/tools/cargo
RUN cd rust && git submodule update --init src/tools/clippy
RUN cd rust && git submodule update --init src/tools/rls
RUN cd rust && git submodule update --init src/tools/rustfmt
RUN cd rust && git submodule update --init src/tools/miri
RUN cd rust && git submodule update --init src/llvm-project
# RUN cd rust/src/llvm-project && git fetch origin # && git reset --hard 027e428197f
# src/doc/nomicon \
# src/doc/reference \
# src/doc/book \
# src/doc/rust-by-example \
# src/stdarch \
# src/doc/rustc-dev-guide \
# src/doc/edition-guide \
# src/doc/embedded-book

# RUN find / -name llvm-config
# RUN find / -name FileCheck
# RUN ls /usr/lib/llvm-7/bin

RUN curl https://sh.rustup.rs -sSf > rust-init.rs
RUN chmod +x rust-init.rs
RUN ./rust-init.rs -y --default-toolchain nightly-2020-03-13 --profile minimal
RUN rm rust-init.rs
ENV PATH=/root/.cargo/bin:$PATH

COPY config.toml ./rust/config.toml
RUN cd rust && ./x.py build -i --stage 1 src/libstd

RUN cargo install du-dust
RUN dust -n 30 /

RUN rustup toolchain link horizon ./rust/build/x86_64-unknown-linux-gnu/stage1
RUN rustup default horizon

# FROM devkitpro/devkita64
# ENV PATH=$DEVKITPRO/devkitA64/bin:$PATH

# # Install GCC for the CC link
# RUN sudo apt-get update
# RUN sudo apt-get install -y build-essential

# # Install Rust
# RUN curl https://sh.rustup.rs -sSf > rust-init.rs
# RUN chmod +x rust-init.rs
# RUN ./rust-init.rs -y --default-toolchain nightly-2020-06-04 --profile minimal
# RUN rm rust-init.rs
# ENV PATH=/root/.cargo/bin:$PATH
# RUN rustup component add rust-src

# # Install dependencies
# RUN cargo install xargo
# RUN wget https://github.com/MegatonHammer/linkle/releases/download/v0.2.7/linkle-v0.2.7-x86_64-unknown-linux-musl.tar.gz && tar -xf linkle-*.tar.gz -C /usr/bin/
# RUN cargo install --git https://github.com/rusty-horizon/aarch64-horizon-nro-ld.git

# # Update devkitA64
# RUN (ln -s /proc/mounts /etc/mtab || true); dkp-pacman --noconfirm -Syyu

# # Add targets
# COPY aarch64-horizon-elf.json /etc/rust-targets/
# COPY aarch64-horizon-nro.json /etc/rust-targets/
# ENV RUST_TARGET_PATH=/etc/rust-targets/

# # Build sysroot
# COPY sysroot-builder/ /tmp/sysroot-builder/

# RUN cd /tmp/sysroot-builder/ && \
#     xargo fetch

# # aarch64-horizon-elf
# RUN cd /tmp/sysroot-builder/ && \
#     xargo build --target aarch64-horizon-elf -vv # rerun

# # aarch64-horizon-nro
# RUN cd /tmp/sysroot-builder/ && \
#     xargo build --target aarch64-horizon-nro -vv # rerun

# # Cleanup
# RUN rm -rf /tmp/sysroot-builder/
# RUN rm -rf ~/.cargo/registry

# # Set CC
# ENV CC_aarch64-none-elf=aarch64-none-elf-gcc
# ENV CC_aarch64-horizon-elf=aarch64-none-elf-gcc
# ENV CC_aarch64-horizon-nro=aarch64-none-elf-gcc

# # Mount the work directory
# WORKDIR workdir
# VOLUME workdir
