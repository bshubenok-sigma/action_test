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
FFMPEG_EXTRA_ARGS=""

case $TARGET in
    ios-x86-64)
        PLATFORM=iphonesimulator
        ARCH="x86_64"
        SYSROOT=$(xcrun --sdk $PLATFORM --show-sdk-path)
        CC="$(xcrun --sdk $PLATFORM --find clang) -isysroot=${SYSROOT} -arch ${ARCH}"
        CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
        AS="gas-preprocessor.pl -arch ${ARCH} -- $CC"
        ;;
    ios-arm64)
        PLATFORM=iphoneos
        ARCH="arm64"
        SYSROOT=$(xcrun --sdk $PLATFORM --show-sdk-path)
        CC="$(xcrun --sdk $PLATFORM --find clang) -isysroot=${SYSROOT} -arch ${ARCH}"
        CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
        AS="gas-preprocessor.pl -arch ${ARCH} -- $CC"
        ;;
    android-arm64)
        PLATFORM=android
        ARCH="arm64"
        TARGET="aarch64-linux-android"
        LEVEL="21"
        HOST="linux-x86_64"
        SYSROOT="$ANDROID_NDK_ROOT/sysroot"
        LLVM_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$HOST/bin"
        ls -lA "$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt"
        CC=${CC:-$LLVM_TOOLCHAIN/${TARGET}${LEVEL}-clang}
        CXX=${CXX:-$LLVM_TOOLCHAIN/${TARGET}${LEVEL}-clang++}
        AS=$LLVM_TOOLCHAIN/$TARGET-as
        CFLAGS="$CFLAGS -mfpu=neon -fPIC"
        FFMPEG_EXTRA_ARGS="\
        --target-os=linux \
        --cross-prefix=arm-linux-androideabi- \
        "
        TOOLCHAIN_FOLDER=$TARGET
        CONFIGURATION="$CONFIGURATION --disable-static"
        ;;
    android-armeabi)
        ;;
    android-x86-64)
        ;;
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
                --disable-stripping \
                --cc="$CC" \
                --as="$AS" \
                --arch="$ARCH" \
                --sysroot="$SYSROOT" \
                --prefix="$PREFIX" \
                --extra-cflags="-I$OPENSSL_DIR/include -I$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include $CFLAGS -D__ANDROID_API__=$LEVEL" \
                --extra-ldflags="-L$OPENSSL_DIR/lib -L$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/$TARGET/$LEVEL $LDFLAGS" \
                $FFMPEG_EXTRA_ARGS
        make -j4
        make install
popd
