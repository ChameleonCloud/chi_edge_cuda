variable "REGISTRY" {
  default = "ghcr.io/chameleoncloud"
}

variable "SOURCE_REPO" {
  default = "https://github.com/ChameleonCloud/chi_edge_cuda"
}

// Build order:
//   docker buildx bake jetson-base --push
//   docker buildx bake cuda-devel --push
//   docker buildx bake gpu-burn --push
group "default" {
  targets = ["jetson-base"]
}

group "jetson-base" {
  targets = ["jetson-base-t210", "jetson-base-t194", "jetson-base-t234"]
}

group "cuda-devel" {
  targets = ["cuda-devel-10", "cuda-devel-12"]
}

group "gpu-burn" {
  targets = ["gpu-burn-sm53", "gpu-burn-sm72", "gpu-burn-sm87"]
}

target "_common" {
  labels = {
    "org.opencontainers.image.source" = "${SOURCE_REPO}"
  }
}

target "jetson-base-t210" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.jetson-base"
  platforms  = ["linux/arm64"]
  args = {
    UBUNTU       = "18.04"
    SOC          = "t210"
    L4T_VERSION  = "r32.7"
    CUDA         = "10-2"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/jetson-base:t210-r32.7"]
}

target "jetson-base-t194" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.jetson-base"
  platforms  = ["linux/arm64"]
  args = {
    UBUNTU       = "18.04"
    SOC          = "t194"
    L4T_VERSION  = "r32.7"
    CUDA         = "10-2"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/jetson-base:t194-r32.7"]
}

target "jetson-base-t234" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.jetson-base"
  platforms  = ["linux/arm64"]
  args = {
    UBUNTU       = "22.04"
    SOC          = "t234"
    L4T_VERSION  = "r36.4"
    CUDA         = "12-6"
    CUDA_VERSION = "12.6"
  }
  tags = ["${REGISTRY}/jetson-base:t234-r36.4"]
}

target "cuda-devel-10" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.cuda-devel"
  platforms  = ["linux/arm64"]
  args = {
    BASE_IMAGE   = "${REGISTRY}/jetson-base:t210-r32.7"
    CUDA         = "10-2"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/cuda-devel:l4t-r32.7-cuda10.2"]
}

target "cuda-devel-12" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.cuda-devel"
  platforms  = ["linux/arm64"]
  args = {
    BASE_IMAGE   = "${REGISTRY}/jetson-base:t234-r36.4"
    CUDA         = "12-6"
    CUDA_VERSION = "12.6"
  }
  tags = ["${REGISTRY}/cuda-devel:l4t-r36.4-cuda12.6"]
}

target "gpu-burn-sm53" {
  inherits  = ["_common"]
  platforms = ["linux/arm64"]
  args = {
    CUDA_DEVEL   = "${REGISTRY}/cuda-devel:l4t-r32.7-cuda10.2"
    COMPUTE      = "53"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/gpu-burn:sm53-nano"]
}

target "gpu-burn-sm72" {
  inherits  = ["_common"]
  platforms = ["linux/arm64"]
  args = {
    CUDA_DEVEL   = "${REGISTRY}/cuda-devel:l4t-r32.7-cuda10.2"
    COMPUTE      = "72"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/gpu-burn:sm72-xavier"]
}

target "gpu-burn-sm87" {
  inherits  = ["_common"]
  platforms = ["linux/arm64"]
  args = {
    CUDA_DEVEL   = "${REGISTRY}/cuda-devel:l4t-r36.4-cuda12.6"
    COMPUTE      = "87"
    CUDA_VERSION = "12.6"
  }
  tags = ["${REGISTRY}/gpu-burn:sm87-orin"]
}
