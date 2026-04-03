# CUDA on CHI@Edge

Container images for building and running CUDA applications on Chameleon's Jetson edge devices.

## Image Tree

```
ubuntu:{18.04,22.04}
└── l4t-cuda-base            # NVIDIA common repo + CUDA runtime libraries
    ├── l4t-cuda-devel        # + nvcc, dev headers, make/g++ (user build image)
    └── jetson-infra          # + SOC-specific L4T BSP + nvidia-container-toolkit (chi@edge host)
```

### l4t-cuda-base

Ubuntu + NVIDIA Jetson `common` apt repo + `cuda-libraries`. Foundation for both
`l4t-cuda-devel` and `jetson-infra`. Not typically used directly by end users.

| Tag | Ubuntu | L4T | CUDA | Devices |
|-----|--------|-----|------|---------|
| `32.7-10.2` | 18.04 | r32.7 | 10.2 | Jetson Nano, Xavier NX |
| `36.4-12.6` | 22.04 | r36.4 | 12.6 | Orin Nano |

### l4t-cuda-devel

Build image for compiling CUDA code. Extends `l4t-cuda-base` with `cuda-nvcc`,
`cuda-cudart-dev`, `libcublas-dev`, `make`, and `g++`.

| Tag | Base |
|-----|------|
| `32.7-10.2` | `l4t-cuda-base:32.7-10.2` |
| `36.4-12.6` | `l4t-cuda-base:36.4-12.6` |

### jetson-infra

CHI@Edge host image. Extends `l4t-cuda-base` with SOC-specific L4T packages and
`nvidia-container-toolkit`. This image runs on the host and mounts CUDA libraries
into user containers via the NVIDIA container runtime. End users do not use this
image directly.

| Tag | SOC | Base |
|-----|-----|------|
| `t210-32.7` | t210 (Nano) | `l4t-cuda-base:32.7-10.2` |
| `t194-32.7` | t194 (Xavier NX) | `l4t-cuda-base:32.7-10.2` |
| `t234-36.4` | t234 (Orin Nano) | `l4t-cuda-base:36.4-12.6` |

## User Multi-Stage Build Pattern

Compile against `l4t-cuda-devel`, then copy your binary into a minimal runtime image.
CUDA libraries are mounted into the container at runtime by the NVIDIA container toolkit
on the host — your runtime image just needs to know where to find them.

```dockerfile
FROM ghcr.io/chameleoncloud/l4t-cuda-devel:36.4-12.6 AS build
COPY . /src
WORKDIR /src
RUN make

FROM ubuntu:22.04
COPY --from=build /src/my_app /app/my_app
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64
CMD ["/app/my_app"]
```

## Building

All images are built with `docker buildx bake`. Build order matters because each layer
depends on the one before it:

```sh
docker buildx bake l4t-cuda-base --push
docker buildx bake l4t-cuda-devel jetson-infra --push
docker buildx bake gpu-burn --push
```

Images are published to `ghcr.io/chameleoncloud/`.

## gpu-burn

Example CUDA stress test built using the multi-stage pattern above.

| Tag | Compute | Device |
|-----|---------|--------|
| `sm53-nano` | sm_53 | Jetson Nano |
| `sm72-xavier` | sm_72 | Xavier NX |
| `sm87-orin` | sm_87 | Orin Nano |
