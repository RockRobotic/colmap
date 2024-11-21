ARG UBUNTU_VERSION=22.04
ARG NVIDIA_CUDA_VERSION=12.6.1

#
# Docker builder stage.
#
FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} as builder

ARG COLMAP_GIT_COMMIT=main
ARG CUDA_ARCHITECTURES=native
ENV QT_XCB_GL_INTEGRATION=xcb_egl

# Prevent stop building ubuntu at time zone selection.
ENV DEBIAN_FRONTEND=noninteractive

# Prepare and empty machine for building.
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        git \
        cmake \
        ninja-build \
        build-essential \
        libboost-program-options-dev \
        libboost-graph-dev \
        libboost-system-dev \
        libeigen3-dev \
        libflann-dev \
        libfreeimage-dev \
        libmetis-dev \
        libgoogle-glog-dev \
        libgtest-dev \
        libgmock-dev \
        libsqlite3-dev \
        libglew-dev \
        qtbase5-dev \
        libqt5opengl5-dev \
        libcgal-dev 
        # libceres-dev

RUN apt-get install libatlas-base-dev libsuitesparse-dev wget -y
RUN git clone --recurse-submodules https://ceres-solver.googlesource.com/ceres-solver
RUN wget https://developer.download.nvidia.com/compute/cudss/redist/libcudss/linux-x86_64/libcudss-linux-x86_64-0.3.0.9_cuda12-archive.tar.xz && tar -xf libcudss-linux-x86_64-0.3.0.9_cuda12-archive.tar.xz && mkdir /cudss-install && cp -r libcudss-linux-x86_64-0.3.0.9_cuda12-archive/* /cudss-install
ENV cudss_DIR=/cudss-install
#RUN cd ceres-solver && mkdir build && cd build && cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} -DCMAKE_INSTALL_PREFIX=/ceres-install -DUSE_CUDA=ON && ninja install
RUN cd ceres-solver && mkdir build && cd build && \
    cmake .. -GNinja \
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} \
        -DCMAKE_INSTALL_PREFIX=/ceres-install \
        -DUSE_CUDA=ON \
        -DBUILD_TESTING=OFF \
        -DBUILD_EXAMPLES=OFF \
    && ninja install

# in /ceres-install/lib/cmake/Ceres/CeresConfig.cmake, replace find_dependency(cudss 0.3.0) with find_dependency(cudss)
RUN sed -i 's/find_dependency(cudss 0.3.0)/find_dependency(cudss)/g' /ceres-install/lib/cmake/Ceres/CeresConfig.cmake
# RUN cat /cudss-install/lib/cmake/cudss/cudss-config.cmake
# RUN echo 'set(PACKAGE_VERSION "0.3.0")' >> /cudss-install/lib/cmake/cudss/cudss-config-version.cmake
# RUN cat /cudss-install/lib/cmake/cudss/cudss-config-version.cmake
# RUN cat /ceres-install/lib/cmake/Ceres/CeresConfig.cmake

# Build and install COLMAP.
COPY colmap /colmap
COPY colmap_build_docker /colmap/build_docker
RUN cd colmap && \
    mkdir -p build_docker && \
    cd build_docker && \
    cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} \
        -DCMAKE_INSTALL_PREFIX=/colmap-install && \
    ninja install

# RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.1/cmake-3.30.1.tar.gz && tar xfvz cmake-3.30.1.tar.gz
# RUN cd cmake-3.30.1 && ./bootstrap --parallel=64 --generator=Ninja && ninja && ninja install
# RUN git clone https://github.com/colmap/glomap.git
# #RUN ls /colmap-install/share && false
# RUN apt install libboost-filesystem-dev -y
# RUN cd glomap && mkdir build && cd build && cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} -DCMAKE_INSTALL_PREFIX=/glomap-install \
#     && ninja install

#
# Docker runtime stage.
#
FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION} as runtime

# Minimal dependencies to run COLMAP binary compiled in the builder stage.
# Note: this reduces the size of the final image considerably, since all the
# build dependencies are not needed.
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        libboost-program-options1.74.0 \
        libc6 \
        libfreeimage3 \
        libgcc-s1 \
        libgl1 \
        libglew2.2 \
        libgoogle-glog0v5 \
        libqt5core5a \
        libqt5gui5 \
        libboost-filesystem-dev \
        libmetis-dev libatlas-base-dev libsuitesparse-dev \
        libqt5widgets5
        # libceres2 \

RUN apt-get install -y wget
# download vocab tree to /root
RUN wget https://demuc.de/colmap/vocab_tree_flickr100K_words256K.bin -O /root/vocab_tree_flickr100K_words256K.bin

# Copy all files from /colmap-install/ in the builder stage to /usr/local/ in
# the runtime stage. This simulates installing COLMAP in the default location
# (/usr/local/), which simplifies environment variables. It also allows the user
# of this Docker image to use it as a base image for compiling against COLMAP as
# a library. For instance, CMake will be able to find COLMAP easily with the
# command: find_package(COLMAP REQUIRED).
COPY --from=builder /colmap-install/ /usr/local/
# COPY --from=builder /glomap-install/ /usr/local/
COPY --from=builder /ceres-install/ /usr/local/
COPY --from=builder /cudss-install/ /usr/local/
COPY --from=builder /colmap/build_docker/ /colmap/build_docker/
ENTRYPOINT ["/usr/bin/env"]
