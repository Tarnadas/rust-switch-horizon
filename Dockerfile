FROM debian:bullseye-slim

WORKDIR /workdir

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
    pkg-config

# Install devkitPro Pacman
RUN wget https://github.com/devkitPro/pacman/releases/download/devkitpro-pacman-1.0.1/devkitpro-pacman.deb
RUN dpkg -i devkitpro-pacman.deb

ENV DEVKITPRO=/opt/devkitpro
ENV PATH=$DEVKITPRO/pacman/bin:$DEVKITPRO/devkitA64/bin:$DEVKITPRO/tools/bin:$PATH
ENV CXX_aarch64_unknown_horizon_libnx=/opt/devkitpro/devkitA64/bin/aarch64-none-elf-gcc              
ENV CC_aarch64_unknown_horizon_libnx=/opt/devkitpro/devkitA64/bin/aarch64-none-elf-gcc

RUN pacman -Sy
RUN yes | pacman -S \
    switch-tools \
    libnx \
    devkitA64 \
    devkit-env

RUN curl https://sh.rustup.rs -sSf > rust-init.rs
RUN chmod +x rust-init.rs
RUN ./rust-init.rs -y --default-toolchain nightly-2020-03-13 --profile minimal
RUN rm rust-init.rs
ENV PATH=/root/.cargo/bin:$PATH

COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /horizon/rust/build/x86_64-unknown-linux-gnu /horizon/rust

RUN rustup toolchain link horizon /horizon/rust/stage1
RUN rustup default horizon
