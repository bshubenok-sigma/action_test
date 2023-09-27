#!/bin/bash -x

set -e

# Source the ffmpeg configuration from the configuration file
source ffmpeg_configuration

# Settings
FFMPEG_DIR=$1
OPENSSL_DIR=$2
PREFIX=$3
TARGET=$4

IOS_DEPLOYMENT_TARGET="11.0"
ANDROID_LEVEL="29"

case $TARGET in
    ios-*)
        case $TARGET in
            ios-x86-64)
                PLATFORM=iphonesimulator
                ARCH="x86_64"
                CFLAGS="$CFLAGS -mios-simulator-version-min=$IOS_DEPLOYMENT_TARGET"
            ;;
            ios-arm64)
                PLATFORM=iphoneos
                ARCH="arm64"
                CFLAGS="$CFLAGS -mios-version-min=$IOS_DEPLOYMENT_TARGET -fembed-bitcode"
            ;;
        esac
        SYSROOT=$(xcrun --sdk $PLATFORM --show-sdk-path)
        CC="$(xcrun --sdk $PLATFORM --find clang) -isysroot=${SYSROOT} -arch ${ARCH}"
        LDFLAGS="$CFLAGS"
        AS="gas-preprocessor.pl -arch ${ARCH} -- $CC"
        ;;
    android-*)
        case $TARGET in
            android-arm64-v8a)
                ARCH="arm64"
                TARGET="aarch64-linux-android"
            ;;
            android-aarmeabi-v7a)
                ARCH="arm"
                TARGET="armv7a-linux-androideabi"
                EXTRA_CFLAGS="-mfpu=neon"
            ;;

            android-x86_64)
                ARCH="x86_64"
                TARGET="x86_64-linux-android"
                EXTRA_CFLAGS="-target x86_64-none-linux-androideabi -msse4.2 -mpopcnt -m64"
            ;;
        esac

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

        PLATFORM=android
        SYSROOT="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$HOST/sysroot"
        LLVM_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$HOST/bin"
        CC=${CC:-$LLVM_TOOLCHAIN/${TARGET}${ANDROID_LEVEL}-clang}
        CXX=${CXX:-$LLVM_TOOLCHAIN/${TARGET}${ANDROID_LEVEL}-clang++}
        AS=${AS:-$LLVM_TOOLCHAIN/${TARGET}${ANDROID_LEVEL}-clang}
        EXTRA_CFLAGS="${EXTRA_CFLAGS} -DANDROID_PLATFORM=android-${ANDROID_LEVEL} -I$SYSROOT/usr/include"
        EXTRA_LDFLAGS="-L$SYSROOT/usr/lib/$TARGET/$LEVEL"
        FFMPEG_EXTRA_ARGS="\
            --target-os=android \
            --strip=true \
        "
        TOOLCHAIN_FOLDER=$TARGET
        CONFIGURATION="$CONFIGURATION --disable-static"
        ;;
    *)
        echo "Unknown target: $TARGET"
        exit 1
        ;;
esac

pushd $FFMPEG_DIR
        ./configure $CONFIGURATION \
            --enable-cross-compile \
            --disable-stripping \
            --cc="$CC" \
            --as="$AS" \
            --arch="$ARCH" \
            --sysroot="$SYSROOT" \
            --prefix="$PREFIX" \
            --extra-cflags="-I$OPENSSL_DIR/include $EXTRA_CFLAGS" \
            --extra-ldflags="-L$OPENSSL_DIR/lib $EXTRA_LDFLAGS" \
            $FFMPEG_EXTRA_ARGS
        make -j4
        make install
popd
