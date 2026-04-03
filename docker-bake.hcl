variable "REGISTRY" {
  default = "ghcr.io/chameleoncloud"
}

variable "SOURCE_REPO" {
  default = "https://github.com/ChameleonCloud/chi_edge_cuda"
}

// Build order:
//   docker buildx bake l4t-cuda-base --push
//   docker buildx bake l4t-cuda-devel jetson-infra --push
//   docker buildx bake gpu-burn --push
group "default" {
  targets = ["l4t-cuda-base"]
}

group "l4t-cuda-base" {
  targets = ["l4t-cuda-base-32", "l4t-cuda-base-36"]
}

group "l4t-cuda-devel" {
  targets = ["l4t-cuda-devel-32", "l4t-cuda-devel-36"]
}

group "jetson-infra" {
  targets = ["jetson-infra-t210", "jetson-infra-t194", "jetson-infra-t234"]
}

group "gpu-burn" {
  targets = ["gpu-burn-sm53", "gpu-burn-sm72", "gpu-burn-sm87"]
}

target "_common" {
  labels = {
    "org.opencontainers.image.source" = "${SOURCE_REPO}"
  }
}

// --- l4t-cuda-base ---

target "l4t-cuda-base-32" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.l4t-cuda-base"
  platforms  = ["linux/arm64"]
  args = {
    UBUNTU       = "18.04"
    L4T_VERSION  = "r32.7"
    CUDA         = "10-2"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/l4t-cuda-base:32.7-10.2"]
}

target "l4t-cuda-base-36" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.l4t-cuda-base"
  platforms  = ["linux/arm64"]
  args = {
    UBUNTU       = "22.04"
    L4T_VERSION  = "r36.4"
    CUDA         = "12-6"
    CUDA_VERSION = "12.6"
  }
  tags = ["${REGISTRY}/l4t-cuda-base:36.4-12.6"]
}

// --- l4t-cuda-devel ---

target "l4t-cuda-devel-32" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.l4t-cuda-devel"
  platforms  = ["linux/arm64"]
  args = {
    BASE_IMAGE   = "${REGISTRY}/l4t-cuda-base:32.7-10.2"
    CUDA         = "10-2"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/l4t-cuda-devel:32.7-10.2"]
}

target "l4t-cuda-devel-36" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.l4t-cuda-devel"
  platforms  = ["linux/arm64"]
  args = {
    BASE_IMAGE   = "${REGISTRY}/l4t-cuda-base:36.4-12.6"
    CUDA         = "12-6"
    CUDA_VERSION = "12.6"
  }
  tags = ["${REGISTRY}/l4t-cuda-devel:36.4-12.6"]
}

// --- jetson-infra ---

target "jetson-infra-t210" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.jetson-infra"
  platforms  = ["linux/arm64"]
  args = {
    BASE_IMAGE   = "${REGISTRY}/l4t-cuda-base:32.7-10.2"
    SOC          = "t210"
    L4T_VERSION  = "r32.7"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/jetson-infra:t210-32.7"]
}

target "jetson-infra-t194" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.jetson-infra"
  platforms  = ["linux/arm64"]
  args = {
    BASE_IMAGE   = "${REGISTRY}/l4t-cuda-base:32.7-10.2"
    SOC          = "t194"
    L4T_VERSION  = "r32.7"
    CUDA_VERSION = "10.2"
  }
  tags = ["${REGISTRY}/jetson-infra:t194-32.7"]
}

target "jetson-infra-t234" {
  inherits   = ["_common"]
  dockerfile = "Dockerfile.jetson-infra"
  platforms  = ["linux/arm64"]
  args = {
    BASE_IMAGE   = "${REGISTRY}/l4t-cuda-base:36.4-12.6"
    SOC          = "t234"
    L4T_VERSION  = "r36.4"
    CUDA_VERSION = "12.6"
  }
  tags = ["${REGISTRY}/jetson-infra:t234-36.4"]
}

// --- gpu-burn ---

target "gpu-burn-sm53" {
  inherits  = ["_common"]
  platforms = ["linux/arm64"]
  args = {
    CUDA_DEVEL = "${REGISTRY}/l4t-cuda-devel:32.7-10.2"
    CUDA_BASE  = "${REGISTRY}/l4t-cuda-base:32.7-10.2"
    COMPUTE    = "53"
  }
  tags = ["${REGISTRY}/gpu-burn:sm53-nano"]
}

target "gpu-burn-sm72" {
  inherits  = ["_common"]
  platforms = ["linux/arm64"]
  args = {
    CUDA_DEVEL = "${REGISTRY}/l4t-cuda-devel:32.7-10.2"
    CUDA_BASE  = "${REGISTRY}/l4t-cuda-base:32.7-10.2"
    COMPUTE    = "72"
  }
  tags = ["${REGISTRY}/gpu-burn:sm72-xavier"]
}

target "gpu-burn-sm87" {
  inherits  = ["_common"]
  platforms = ["linux/arm64"]
  args = {
    CUDA_DEVEL = "${REGISTRY}/l4t-cuda-devel:36.4-12.6"
    CUDA_BASE  = "${REGISTRY}/l4t-cuda-base:36.4-12.6"
    COMPUTE    = "87"
  }
  tags = ["${REGISTRY}/gpu-burn:sm87-orin"]
}
