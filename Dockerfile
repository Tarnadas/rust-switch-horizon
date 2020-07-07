FROM debian:bullseye-slim

WORKDIR /workdir

# Update distro and install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
    gnupg \
    libclang-dev \
    llvm-dev

# Install devkitPro Pacman
RUN wget https://github.com/devkitPro/pacman/releases/download/v1.0.2/devkitpro-pacman.amd64.deb
RUN dpkg -i devkitpro-pacman.amd64.deb

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

COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /horizon/rust/build/x86_64-unknown-linux-gnu/stage2 /root/.cargo
COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /horizon/rust/build/x86_64-unknown-linux-gnu/stage2-tools-bin /root/.cargo/bin
COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /root/.cargo/bin/cargo-nro /root/.cargo/bin/cargo-nro
COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /root/.cargo/bin/cargo-watch /root/.cargo/bin/cargo-watch
COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /root/.cargo/bin/linkle /root/.cargo/bin/linkle
COPY --from=rustyhorizon/docker /opt/devkitpro/devkitA64/lib/gcc/aarch64-none-elf/8.3.0 /opt/devkitpro/devkitA64/lib/gcc/aarch64-none-elf/8.3.0

ENV PATH=/root/.cargo/bin:$PATH
