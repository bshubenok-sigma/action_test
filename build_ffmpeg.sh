#!/bin/bash -x

set -e

# Source the ffmpeg configuration from the configuration file
source ffmpeg_configuration

# Settings
FFMPEG_DIR=$1
OPENSSL_DIR=$2
TARGET=$3


case $TARGET in
    ios-x86-64)
        PLATFORM=iphonesimulator
        ARCH="x86_64"
        CC="xcrun --sdk $PLATFORM clang"
        SYSROOT=$(xcrun --sdk $PLATFORM --show-sdk-path)
        ;;
    ios-arm64)
        PLATFORM=iphoneos
        ARCH="arm64"
        CC="xcrun --sdk $PLATFORM clang"
        SYSROOT=$(xcrun --sdk $PLATFORM --show-sdk-path)
        ;;
    # android-arm64-v8a)
    #     ;;
    # android-armeabi-v7a)
    #     ;;
    # android-x86-64)
    #     ;;
    *)
        echo "Unknown target: $TARGET"
        exit 1
        ;;
esac

# cd into ffmpeg root directory and build ffmpeg
pushd $FFMPEG_DIR
        ./configure $CONFIGURATION \
                --cc="$CC" \
                --arch="$ARCH" \
                --sysroot="$SYSROOT" \
                --prefix="build" \
                --extra-cflags="-I$OPENSSL_DIR/include" \
                --extra-ldflags="-L$OPENSSL_DIR" || cat ffbuild/config.log ; exit
        make -j3
        make install
popd
