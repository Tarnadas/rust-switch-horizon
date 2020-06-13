FROM debian:bullseye-slim

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
    clang

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

ADD https://api.github.com/repos/tarnadas/rust/git/refs/heads/horizon version.json
RUN git clone --depth=1 --branch=horizon https://github.com/Tarnadas/rust.git
RUN cd rust && git submodule update --init --recursive

ADD https://api.github.com/repos/tarnadas/backtrace-rs/git/refs/heads/horizon version.json
RUN git clone --depth=1 --branch=horizon https://github.com/Tarnadas/backtrace-rs.git
RUN cd backtrace-rs && git submodule update --init crates/backtrace-sys/src/libbacktrace

COPY config.toml ./rust/config.toml
RUN cd rust && ./x.py build -i --stage 1 src/libstd
# RUN cd rust && ./x.py dist
# RUN cd rust && ./x.py install

RUN curl https://sh.rustup.rs -sSf > rust-init.rs
RUN chmod +x rust-init.rs
RUN ./rust-init.rs -y --default-toolchain nightly-2020-03-13 --profile minimal
RUN rm rust-init.rs
ENV PATH=/root/.cargo/bin:$PATH

RUN cargo install du-dust
RUN dust -n 30 /
RUN dust -n 30 /horizon/rust/build
RUN find -name cargo /horizon/rust/build

# RUN rustup toolchain link horizon ./rust/build/x86_64-unknown-linux-gnu/stage1
# RUN rustup default horizon
