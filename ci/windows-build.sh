#!/bin/bash
set -ex

export ROOT_DIR="${TRAVIS_BUILD_DIR}"
export CACHE_DIR="${TRAVIS_BUILD_DIR}/cache"

export DOXYGEN_VERSION=1.8.14
export DOXYGEN_EXTERNAL_RELEASE=external-25

export OPENSSL_VERSION=1_1_1c

export EXTERNAL_RELEASE=external-38
export EXTERNAL_VERSION=0.1.1

if [ "$TRAVIS_OS_NAME" == "windows" ]; then
    export CONFIGURATION="RelWithDebInfo"

    if [ "$PLATFORM" != "win32" ]; then
        export GENERATOR="Visual Studio 15 2017 Win64"
        export MSPLATFORM="x64"
        export OPENSSL_ROOT_DIR="C:/Program Files/OpenSSL-Win64"
    else
        export GENERATOR="Visual Studio 15 2017"
        export MSPLATFORM="Win32"
        export OPENSSL_ROOT_DIR="C:/Program Files (x86)/OpenSSL-Win32"
    fi

    echo "Platform      = $PLATFORM"
    echo "MS Platform   = $MSPLATFORM"
    echo "Configuration = $CONFIGURATION"
    echo "Generator     = $GENERATOR"
fi

cd "${CACHE_DIR}"

# OpenSSL for Windows (only needed for the full build)
echo "Downloading OpenSSL"
if [ "$PLATFORM" == "win32" ]; then
    if [ ! -f "OpenSSL-${OPENSSL_VERSION}-${PLATFORM}.msi" ]; then
        curl -Lo "OpenSSL-${OPENSSL_VERSION}-${PLATFORM}.msi" "https://github.com/comphack/external/releases/download/${DOXYGEN_EXTERNAL_RELEASE}/Win32OpenSSL-${OPENSSL_VERSION}.msi"
    fi
else
    if [ ! -f "OpenSSL-${OPENSSL_VERSION}-${PLATFORM}.msi" ]; then
        curl -Lo "OpenSSL-${OPENSSL_VERSION}-${PLATFORM}.msi" "https://github.com/comphack/external/releases/download/${DOXYGEN_EXTERNAL_RELEASE}/Win64OpenSSL-${OPENSSL_VERSION}.msi"
    fi
fi

cd "${ROOT_DIR}"

mkdir build
cd build

echo "Installing OpenSSL"
cp "${CACHE_DIR}/OpenSSL-${OPENSSL_VERSION}-${PLATFORM}.msi" OpenSSL.msi
powershell -Command "Start-Process msiexec.exe -Wait -ArgumentList '/i OpenSSL.msi /l OpenSSL-install.log /qn'"
rm -f OpenSSL.msi OpenSSL-install.log
echo "Installed OpenSSL"

cmake -DCMAKE_INSTALL_PREFIX="${ROOT_DIR}/build/install" \
    -DCMAKE_CUSTOM_CONFIGURATION_TYPES="$CONFIGURATION" \
    -DOPENSSL_ROOT_DIR="$OPENSSL_ROOT_DIR" \
    -DUSE_SYSTEM_OPENSSL=ON -G"$GENERATOR" ..
cmake --build . --config $CONFIGURATION || (cat googletest/src/googletest-stamp/googletest-build-*.log && exit 1)
cmake --build . --config $CONFIGURATION --target package

mv external-0.1.1-*.zip "${ROOT_DIR}/external-0.1.1-${PLATFORM}.zip"
