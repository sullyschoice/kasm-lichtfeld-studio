#!/usr/bin/env bash
# Combination of instructions from https://github.com/MrNeRF/LichtFeld-Studio/wiki/Build-Instructions-%E2%80%90-Linux and https://github.com/MrNeRF/LichtFeld-Studio/blob/master/docker/Dockerfile
set -ex
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

apt-get update
apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        ca-certificates \
        gnupg2 \
        lsb-release \
        locales \
        python3 \
        python3-pip \
        python3-full \
        python3-dev \
        sudo \
        x11-apps \
        zenity \
        openssh-client \
        wget \
        unzip \
        pkg-config \
        zip \
        libxinerama-dev \
        libxcursor-dev \
        xorg-dev \
        libglu1-mesa-dev \
        vim \
        nano \
        htop \
        ninja-build \
        software-properties-common

add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install -y \
        gcc-14 \
        g++-14 \
        gfortran-14

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 60
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 60
update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-14 60
update-alternatives --set gcc /usr/bin/gcc-14
update-alternatives --set g++ /usr/bin/g++-14
update-alternatives --set gfortran /usr/bin/gfortran-14

wget https://github.com/Kitware/CMake/releases/download/v4.0.3/cmake-4.0.3-linux-x86_64.sh && \
    chmod +x cmake-4.0.3-linux-x86_64.sh && \
    ./cmake-4.0.3-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-4.0.3-linux-x86_64.sh

mkdir -p /opt/
cd /opt
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg && ./bootstrap-vcpkg.sh -disableMetrics && cd ..
export VCPKG_ROOT=/opt/vcpkg
export PATH=$VCPKG_ROOT:$PATH
echo 'VCPKG_ROOT=/opt/vcpkg' >> $HOME/.bashrc
echo 'export PATH=$VCPKG_ROOT:$PATH' >> $HOME/.bashrc
cd /opt/
git clone https://github.com/MrNeRF/LichtFeld-Studio
cd LichtFeld-Studio
wget https://download.pytorch.org/libtorch/cu128/libtorch-cxx11-abi-shared-with-deps-2.7.0%2Bcu128.zip
unzip libtorch-cxx11-abi-shared-with-deps-2.7.0+cu128.zip -d external/
rm libtorch-cxx11-abi-shared-with-deps-2.7.0+cu128.zip


wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt update
apt install -y cuda-toolkit-12-8

export PATH=/usr/local/cuda-12.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH
export CUDACXX=/usr/local/cuda-12.8/bin/nvcc
echo 'PATH=/usr/local/cuda-12.8/bin:$PATH' >> $HOME/.bashrc
echo 'LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH' >> $HOME/.bashrc
echo 'CUDACXX=/usr/local/cuda-12.8/bin/nvcc' >> $HOME/.bashrc

cmake -B build -DCMAKE_BUILD_TYPE=Release -G Ninja -DCMAKE_CUDA_COMPILER=/usr/local/cuda-12.8/bin/nvcc -DCMAKE_LIBRARY_PATH="/usr/local/cuda/lib64;/usr/local/cuda/lib64/stubs"  -DCUDACXX=/usr/local/cuda-12.8/bin/nvcc
cmake --build build -- -j$(nproc)
chown -R 1000:1000 /opt/LichtFeld-Studio