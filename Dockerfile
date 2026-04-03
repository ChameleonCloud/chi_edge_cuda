FROM nvcr.io/nvidia/l4t-cuda:12.2.12-devel AS build

COPY src/gpu-burn gpu-burn
WORKDIR /gpu-burn
RUN make

FROM ubuntu:22.04
WORKDIR /gpu-burn
COPY --from=build /gpu-burn/compare.ptx .
COPY --from=build /gpu-burn/gpu_burn .
ENTRYPOINT ["./gpu_burn"]
CMD ["10"]
