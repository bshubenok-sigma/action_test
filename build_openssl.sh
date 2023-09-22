#!/bin/bash
set -e

OPENSSL_DIR=$1
TARGET=$2

cd $OPENSSL_DIR

case $TARGET in
    ios-x86-64)
        ./Configure iossimulator-xcrun no-ssl2 no-shared
        ;;
    ios-arm64)
        ./Configure ios64-xcrun no-ssl2 no-shared
        ;;
    # android-arm64-v8a)
    #     ./Configure ios64-xcrun no-ssl2 no-shared
    #     ;;
    # android-armeabi-v7a)
    #     ./Configure ios64-xcrun no-ssl2 no-shared
    #     ;;
    # android-x86-64)
    #     ./Configure android-x86_64 no-ssl2 no-shared
    #     ;;
    *)
        echo "Unknown target: $TARGET"
        exit 1
        ;;
esac

MAKEFLAGS=silent make -j2