#!/bin/bash
set -ex

export ROOT_DIR=`pwd`
export CACHE_DIR=`pwd`/cache

cd ${CACHE_DIR}

if [ ! -f cmake-3.6.1-Linux-x86_64.tar.gz ]; then
    wget -q https://cmake.org/files/v3.6/cmake-3.6.1-Linux-x86_64.tar.gz
fi

if [ ! -f clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz ]; then
    wget -q http://llvm.org/releases/3.8.0/clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz
fi

cd ${ROOT_DIR}

sudo apt-get update -q
sudo apt-get install libssl-dev libsqlite3-dev sqlite3 libuv-dev unzip -y

cd /opt
sudo tar xf $CACHE_DIR/cmake-3.6.1-Linux-x86_64.tar.gz

export PATH="/opt/cmake-3.6.1-Linux-x86_64/bin:${PATH}"
export LD_LIBRARY_PATH="/opt/cmake-3.6.1-Linux-x86_64/lib"

if [ "$CXX" == "clang++" ]; then
    cd /opt
    sudo tar xf $CACHE_DIR/clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz
    export PATH="/opt/clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04/bin:${PATH}"
    export LD_LIBRARY_PATH="/opt/clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04/lib:${LD_LIBRARY_PATH}"
fi

cd ${ROOT_DIR}

export CC="${COMPILER_CC}"
export CXX="${COMPILER_CXX}"

export GENERATOR="Unix Makefiles"

mkdir -p build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${ROOT_DIR}/build/install" -DBUILD_OPTIMIZED=OFF -G "${GENERATOR}" ..
cmake --build .
cmake --build . --target package

mv external-0.1.1-Linux.tar.bz2 "${ROOT_DIR}/external-0.1.1-${PLATFORM}.tar.bz2"
