# Release Args
RELEASE?=1.0.0
PLATFORM?=linux/amd64,linux/arm64
DOCKERHUB_USER?=platinumcd
LLVM_RISCV_MUSL_IMAGE_NAME?=llvm-riscv-musl

# Build Args
BUILD_SRC?=/src
BUILD_DEST?=/opt
NUM_THREADS?=32

# RISC-V
RISCV_GIT?=https://github.com/riscv-collab/riscv-gnu-toolchain.git
RISCV_BRANCH?=master

# LLVM Args
LLVM_GIT?=https://github.com/llvm/llvm-project.git
LLVM_BRANCH?=release/18.x

all: image

image:
	docker build \
		--build-arg BUILD_SRC=$(BUILD_SRC) \
		--build-arg BUILD_DEST=$(BUILD_DEST) \
		--build-arg NUM_THREADS=$(NUM_THREADS) \
		--build-arg RISCV_GIT=$(RISCV_GIT) \
		--build-arg RISCV_BRANCH=$(RISCV_BRANCH) \
		--build-arg LLVM_GIT=$(LLVM_GIT) \
		--build-arg LLVM_BRANCH=$(LLVM_BRANCH) \
		-t "$(DOCKERHUB_USER)/$(LLVM_RISCV_MUSL_IMAGE_NAME):$(RELEASE)" \
		.

push:
	docker build \
		--build-arg BUILD_SRC=$(BUILD_SRC) \
		--build-arg BUILD_DEST=$(BUILD_DEST) \
		--build-arg NUM_THREADS=$(NUM_THREADS) \
		--build-arg RISCV_GIT=$(RISCV_GIT) \
		--build-arg RISCV_BRANCH=$(RISCV_BRANCH) \
		--build-arg LLVM_GIT=$(LLVM_GIT) \
		--build-arg LLVM_BRANCH=$(LLVM_BRANCH) \
		-t "$(DOCKERHUB_USER)/$(LLVM_RISCV_MUSL_IMAGE_NAME):$(RELEASE)" \
		--platform "$(PLATFORM)" --push \
		.
