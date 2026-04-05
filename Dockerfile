ARG CUDA_DEVEL=ghcr.io/chameleoncloud/l4t-cuda-devel:36.4-12.6
ARG RUNTIME=ubuntu:22.04

FROM ${CUDA_DEVEL} AS build

ARG COMPUTE
COPY src/gpu-burn /src
WORKDIR /src
RUN make COMPUTE=${COMPUTE} IS_JETSON=true CUDAPATH=${CUDA_HOME} \
    && mkdir -p /out && cp gpu_burn compare.ptx /out/

FROM ${RUNTIME}
WORKDIR /gpu-burn
COPY --from=build /out/ ./
