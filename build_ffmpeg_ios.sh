#!/bin/bash

set -e

# Source the ffmpeg configuration from the configuration file
source ffmpeg_configuration

# Settings
TARGET=iphoneos
FFMPEG_DIR=./ffmpeg
OPENSSL_DIR=`pwd`/openssl
CC="xcrun --sdk $TARGET cc"
SYSROOT=$(xcrun --sdk $TARGET --show-sdk-path)

ARCH='arm64'

# cd into ffmpeg root directory and build ffmpeg
pushd $FFMPEG_DIR
        ./configure $CONFIGURATION \
                --cc="$CC" \
                --arch="$ARCH" \
                --sysroot="$SYSROOT" \
                --prefix="build" \
                --extra-cflags="-I$OPENSSL_DIR/include" \
                --extra-ldflags="-L$OPENSSL_DIR"
        make -j3
        make install
popd
