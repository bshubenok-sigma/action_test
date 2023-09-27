#!/bin/bash
set -e

OPENSSL_DIR=$1
INSTALL_DIR=$2
TARGET=$3

cd $OPENSSL_DIR

case $TARGET in
    android-*)
        unameOut="$(uname -s)"
        case "${unameOut}" in
            Linux*)
                HOST="linux-x86_64"
            ;;
            Darwin*)
                HOST="darwin-x86_64"
            ;;
            *)
                echo "Unsuported HOST: ${unameOut}"
                exit 1
        esac
        export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT}
        PATH=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${HOST}/bin:$PATH
    ;;
    *)
esac

case $TARGET in
    ios-x86-64)
        PLATFORM=iossimulator-xcrun
        ;;
    ios-arm64)
        PLATFORM=ios64-xcrun
        ;;
    android-arm64-v8a)
        PLATFORM=android-arm64
        ;;
    android-aarmeabi-v7a)
        PLATFORM=android-arm
        ;;
    android-x86_64)
        PLATFORM=android-x86_64
        ;;
    *)
        echo "Unknown target: $TARGET"
        exit 1
        ;;
esac

./Configure $PLATFORM $EXTRA no-ssl2 no-shared --prefix=$INSTALL_DIR --openssldir=$INSTALL_DIR
make -j4
make install_sw