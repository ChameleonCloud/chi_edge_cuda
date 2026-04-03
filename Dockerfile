ARG CUDA_DEVEL=ghcr.io/chameleoncloud/cuda-devel:l4t-r36.4-cuda12.6
FROM ${CUDA_DEVEL} AS build

ARG COMPUTE
ARG CUDA_VERSION=12.6
COPY src/gpu-burn /src
WORKDIR /src
RUN make COMPUTE=${COMPUTE} IS_JETSON=true \
    && mkdir -p /out && cp gpu_burn compare.ptx /out/

FROM ubuntu:22.04
WORKDIR /gpu-burn
COPY --from=build /out/ ./
ARG CUDA_VERSION
ENV LD_LIBRARY_PATH=/usr/local/cuda-${CUDA_VERSION}/lib64
