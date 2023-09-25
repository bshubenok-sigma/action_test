#!/bin/bash
set -e

OPENSSL_DIR=$1
INSTALL_DIR=$2
TARGET=$3


mkdir -p $INSTALL_DIR
cd $OPENSSL_DIR

case $TARGET in
    ios-x86-64)
        PLATFORM=iossimulator-xcrun
        EXTRA=""
        ;;
    ios-arm64)
        PLATFORM=ios64-xcrun
        EXTRA=""
        ;;
    android-arm64)
        PLATFORM=android-arm64
        # Build for android 10
        EXTRA="-D__ANDROID_API__=29"
        ;;
    android-armeabi)
        PLATFORM=android-arm
        EXTRA="-D__ANDROID_API__=29"
        ;;
    android-x86-64)
        PLATFORM=android-x86_64
        EXTRA="-D__ANDROID_API__=29"
        ;;
    *)
        echo "Unknown target: $TARGET"
        exit 1
        ;;
esac

./Configure $PLATFORM $EXTRA no-ssl2 no-shared --prefix=$INSTALL_DIR --openssldir=$INSTALL_DIR
make -j4
make install