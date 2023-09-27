#!/bin/bash -x
set -e

# Settings
TARGET=$1

IOS_DEPLOYMENT_TARGET="11.0"
ANDROID_LEVEL="29"

case $TARGET in
    ios-*)
        PLATFORM=iphonesimulator
        ARCH="x86_64"
        SYSROOT=$(xcrun --sdk $PLATFORM --show-sdk-path)
        CC="$(xcrun --sdk $PLATFORM --find clang) -isysroot=${SYSROOT} -arch ${ARCH}"
        CFLAGS="$CFLAGS -mios-simulator-version-min=$IOS_DEPLOYMENT_TARGET"
        LDFLAGS="$CFLAGS"
        AS="gas-preprocessor.pl -arch ${ARCH} -- $CC"
        ;;
    android)
        if [ -z "$ANDROID_NDK_ROOT" ]; then
            echo "Please make sure to set ANDROID_NDK_ROOT"
            exit 1
        fi

        foreach arch ("arm64-v8a" "armeabi-v7a" "x86_64")
            build_libs "android"-${arch}
        end
    ;;
    android-*)
        if [ -z "$ANDROID_NDK_ROOT" ]; then
            echo "Please make sure to set ANDROID_NDK_ROOT"
            exit 1
        fi
        build_libs $TARGET
    ;;
    *)
        echo "Unknown target: $TARGET"
        exit 1
        ;;
esac

build_libs() {
    arch=$1
    LIBS_INSTALL_PATH=`pwd`/install/${arch}
    mkdir -p ${LIBS_INSTALL_PATH}
    bash -x build_openssl.sh `pwd`/openssl ${LIBS_INSTALL_PATH}
    bash -x build_ffmpeg.sh `pwd`/FFmpeg ${LIBS_INSTALL_PATH} ${LIBS_INSTALL_PATH}

    tar -C ${LIBS_INSTALL_PATH} -czf libs-${arch}.tar.gz .

}