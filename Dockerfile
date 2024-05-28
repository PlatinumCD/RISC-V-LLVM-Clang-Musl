FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Build Args
ARG BUILD_SRC
ARG BUILD_DEST
ARG NUM_THREADS

# RISCV Args
ARG RISCV_GIT
ARG RISCV_BRANCH

# LLVM Args
ARG LLVM_GIT
ARG LLVM_BRANCH

# Install Dependencies
RUN apt-get update -y && \
    apt-get install -y autoconf automake autotools-dev curl \
            python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev \
            gawk build-essential bison flex texinfo gperf libtool \
            patchutils bc zlib1g-dev libexpat-dev ninja-build git \
            cmake libglib2.0-dev libslirp-dev ca-certificates \
            gnupg make wget subversion unzip && \
    rm -rf /var/lib/apt/lists/*


# RISC-V
ADD ./gitmodules ${BUILD_SRC}/.gitmodules
RUN git clone -b ${RISCV_BRANCH} ${RISCV_GIT} ${BUILD_SRC}/riscv && \
    cd ${BUILD_SRC}/riscv && \
    mv ${BUILD_SRC}/.gitmodules ${BUILD_SRC}/riscv/.gitmodules && \
    ./configure --prefix=${BUILD_DEST}/riscv && \
    make -j ${NUM_THREADS} musl

# Add RISC-V binaries to $PATH
ENV PATH="${PATH}:${BUILD_DEST}/riscv/bin"

# LLVM
RUN git clone -b ${LLVM_BRANCH} ${LLVM_GIT} ${BUILD_SRC}/llvm-project && \
    mkdir ${BUILD_SRC}/llvm-project/build && \
    cd $BUILD_SRC/llvm-project/build && \
    cmake -S ../llvm -G Ninja -DCMAKE_INSTALL_PREFIX="${BUILD_DEST}/llvm"  \
        -DCMAKE_BUILD_TYPE=Release  -DLLVM_ENABLE_PROJECTS=clang           \
        -DBUILD_SHARED_LIBS=True -DLLVM_OPTIMIZED_TABLEGEN=ON              \
        -DLLVM_BUILD_TESTS=False -DLLVM_TARGETS_TO_BUILD="RISCV"           \
        -DDEFAULT_SYSROOT="${BUILD_DEST}/riscv/sysroot"                    \
        -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-linux-musl" && \
    cmake --build . --target install -- -j ${NUM_THREADS}

# Add LLVM binaries to $PATH
ENV PATH="${PATH}:${BUILD_DEST}/llvm/bin"
