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
    libclang-dev \
    llvm-dev

# Install devkitPro Pacman
# COPY --from=devkitpro/toolchain-base /opt/devkitpro/pacman /opt/devkitpro/pacman

ENV DEVKITPRO=/opt/devkitpro
ENV PATH=$DEVKITPRO/pacman/bin:$DEVKITPRO/devkitA64/bin:$DEVKITPRO/tools/bin:$DEVKITPRO/portlibs/switch/bin:$PATH
ENV CXX_aarch64_unknown_horizon_libnx=/opt/devkitpro/devkitA64/bin/aarch64-none-elf-gcc              
ENV CC_aarch64_unknown_horizon_libnx=/opt/devkitpro/devkitA64/bin/aarch64-none-elf-gcc

# RUN pacman -Sy
# RUN yes | pacman -S \
#     switch-tools \
#     libnx \
#     devkitA64 \
#     devkit-env

COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /horizon/rust/build/x86_64-unknown-linux-gnu/stage2 /root/.cargo
COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /horizon/rust/build/x86_64-unknown-linux-gnu/stage2-tools-bin /root/.cargo/bin
COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /root/.cargo/bin/cargo-nro /root/.cargo/bin/cargo-nro
COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /root/.cargo/bin/cargo-watch /root/.cargo/bin/cargo-watch
COPY --from=docker.pkg.github.com/tarnadas/rust-switch-horizon/toolchain /root/.cargo/bin/linkle /root/.cargo/bin/linkle
# COPY --from=tarnadas/rust-switch-horizon:5770bc3557dbcfcd59b65becea2df65a191afcb5 /opt/devkitpro /opt/devkitpro
# COPY --from=rustyhorizon/docker /opt/devkitpro/devkitA64/lib/gcc/aarch64-none-elf/8.3.0 /opt/devkitpro/devkitA64/lib/gcc/aarch64-none-elf/8.3.0
COPY --from=rustyhorizon/docker /opt/devkitpro /opt/devkitpro

# COPY config-horizon /root/.cargo/config-horizon
# COPY switch.specs /root/.cargo/switch.specs
# COPY switch.ld /root/.cargo/switch.ld
# COPY cargo /root/.cargo/cargo

ENV PATH=/root/.cargo:/root/.cargo/bin:$PATH
