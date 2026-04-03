ARG CUDA_DEVEL=ghcr.io/chameleoncloud/l4t-cuda-devel:36.4-12.6
ARG CUDA_BASE=ghcr.io/chameleoncloud/l4t-cuda-base:36.4-12.6

FROM ${CUDA_DEVEL} AS build

ARG COMPUTE
COPY src/gpu-burn /src
WORKDIR /src
RUN make COMPUTE=${COMPUTE} IS_JETSON=true CUDAPATH=${CUDA_HOME} \
    && mkdir -p /out && cp gpu_burn compare.ptx /out/

FROM ${CUDA_BASE}
WORKDIR /gpu-burn
COPY --from=build /out/ ./
