#!/bin/bash -x

set -e

# Source the ffmpeg configuration from the configuration file
source ffmpeg_configuration

# Settings
FFMPEG_DIR=$1
OPENSSL_DIR=$2
PREFIX=$3
TARGET=$4

DEPLOYMENT_TARGET="8.0"

mkdir -p ./build

case $TARGET in
    ios-x86-64)
        PLATFORM=iphonesimulator
        ARCH="x86_64"
        SYSROOT=$(xcrun --sdk $PLATFORM --show-sdk-path)
        CC="$(xcrun --sdk $PLATFORM --find clang) -isysroot=${SYSROOT} -arch ${ARCH}"
        CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
        AS="gas-preprocessor.pl -- $CC"
        ;;
    ios-arm64)
        PLATFORM=iphoneos
        ARCH="arm64"
        SYSROOT=$(xcrun --sdk $PLATFORM --show-sdk-path)
        CC="$(xcrun --sdk $PLATFORM --find clang) -isysroot=${SYSROOT} -arch ${ARCH}"
        CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
        AS="gas-preprocessor.pl -arch aarch64 -- $CC"
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

CXXFLAGS="$CFLAGS"
LDFLAGS="$CFLAGS"

# cd into ffmpeg root directory and build ffmpeg
pushd $FFMPEG_DIR
        ./configure $CONFIGURATION \
                --enable-cross-compile \
                --cc="$CC" \
                --as="$AS" \
                --arch="$ARCH" \
                --sysroot="$SYSROOT" \
                --prefix="$PREFIX" \
                --extra-cflags="-I$OPENSSL_DIR/include" \
                --extra-ldflags="-L$OPENSSL_DIR/lib" || cat ffbuild/config.log ; exit
        make -j3
        make install
popd
