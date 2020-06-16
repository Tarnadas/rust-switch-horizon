# Rust Switch Horizon

Dockerized Rust toolchain for building homebrew apps for Nintendo Switch with your favorite programming language.

## How-To

- **Pull image**

Pull image from official [Docker Hub](https://hub.docker.com/repository/docker/tarnadas/rust-switch-horizon):

```bash
docker pull tarnadas/rust-switch-horizon
```

Pulling from Github Docker Registry currently requires authentication even for publicly available containers,
so unfortunately you will have to add an auth token to your account, if you want to use Github Docker Registry instead.

Please upvote this issue:

https://github.community/t/docker-pull-from-public-github-package-registry-fail-with-no-basic-auth-credentials-error/16358

- **Create your Rust project**

Use [Leo's awesome LibNX.rs bindings](https://github.com/leo60228/libnx.rs) as a template.

In file `switch.specs`, you will have to change the path accordingly.

- **Bash into container**

`cd` to the directory with the Rust code you want to compile. Then bash into container:

```bash
docker run -v $PWD:/workdir -it tarnadas/rust-switch-horizon /bin/bash
```

- **Run compiler via cargo**

```bash
cargo build
```

- **Install [Linkle](https://github.com/MegatonHammer/linkle) and run it (outside Docker container)**

```bash
cargo install --features=binaries linkle
linkle nro target/aarch64-unknown-horizon-libnx/(debug|release)/$projectName output.nro
```
