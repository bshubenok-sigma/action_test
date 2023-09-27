#!/bin/bash -x
set -e

build_libs() {
    arch=$1
    LIBS_INSTALL_PATH=`pwd`/install/${arch}
    mkdir -p ${LIBS_INSTALL_PATH}
    bash -x build_openssl.sh `pwd`/openssl ${LIBS_INSTALL_PATH} ${arch}
    bash -x build_ffmpeg.sh `pwd`/FFmpeg ${LIBS_INSTALL_PATH} ${LIBS_INSTALL_PATH} ${arch}

    tar -C ${LIBS_INSTALL_PATH} -czf libs-${arch}.tar.gz .
}


# Settings
TARGET=$1

IOS_DEPLOYMENT_TARGET="11.0"
ANDROID_LEVEL="29"

case $TARGET in
    ios)
        for arch in [ "arm64", "x86-64" ]; do
            build_libs "ios"-${arch}
        done
    ;;

    ios-*)
        build_libs $TARGET
    ;;

    android)
        if [ -z "$ANDROID_NDK_ROOT" ]; then
            echo "Please make sure to set ANDROID_NDK_ROOT"
            exit 1
        fi

        for arch in ["arm64-v8a" "armeabi-v7a" "x86_64"]; do
            build_libs "android"-${arch}
        done

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
