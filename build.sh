#!/bin/bash
set -e  # Exit immediately if any command fails

# --- working toolchain (tested with android ndk r27d) ---
ABI=${ABI:-arm64-v8a}        # 32 or 64 bit
PLATFORM=${PLATFORM:-android-21}  # android 5

NDK_VERSION=${NDK_VERSION:-27.3.13750724}  # 27.3.13750724 (NDK r27d)
NDK_ROOT=$ANDROID_HOME/ndk/$NDK_VERSION    #standart android home root

AUTO_CMAKE_TOOLCHAIN=$NDK_ROOT/build/cmake/android.toolchain.cmake
AUTO_CLANG=$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang

CMAKE_TOOLCHAIN=${TOOLCHAIN_ROOT:-$AUTO_CMAKE_TOOLCHAIN}
CLANG=${CLANG_ROOT:-$AUTO_CLANG}

# --- working CLBLAST release ---
CLBLAST_VERSION=${VCLBLAST:-"1.7.0"} #last realeased

echo "Downloading all the dependency..."

# --- Download the opencl headers ---
./get_opencl_headers.sh

# (tested on CLBlast 1.7.0)
# --- Download the latest CLBLAST library ---
if [ ! -d "./CLBlast" ]; then
    git clone -b "$CLBLAST_VERSION" --depth 1 -c advice.detachedHead=false https://github.com/CNugteren/CLBlast.git ./CLBlast
fi
# dev branch
# git clone git@github.com:CNugteren/CLBlast.git    # fix the  error : DCMAKE_CXX_FLAGS="-Wno-error=format-security"

echo "Compilation ..."
rm -rf CMakeCache.txt CMakeFiles/ #make clear

# --- Compile the stub ---
$CLANG  -shared -fPIC ./opencl_headers/lib/opencl_stub.c   -o ./opencl_headers/lib/libOpenCL.so

mkdir -p ./build
cd ./build
rm -rf ./*

# --- Compile CLBlast ---
cmake ../CLBlast \
 -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
 -DANDROID_ABI=$ABI\
 -DANDROID_PLATFORM=$PLATFORM \
 -DANDROID_STL=c++_static \
 -DBUILD_SHARED_LIBS=OFF \
 -DOPENCL_INCLUDE_DIRS=../opencl_headers/ \
 -DOPENCL_LIBRARIES=../opencl_headers/lib/libOpenCL.so \
 -DCMAKE_CXX_FLAGS="-Wno-error=format-security"     # This flag solve a bug in the latest CLBlast Release

make -j$(nproc)

cd ..



# --- (Bonus) Line command  ---
#rm -rf CMakeCache.txt CMakeFiles/ #make clear



# cmake . \
#  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_HOME/ndk/27.3.13750724/build/cmake/android.toolchain.cmake \
#  -DANDROID_ABI=arm64-v8a \
#  -DANDROID_PLATFORM=android-21 \
#  -DANDROID_STL=c++_static \
#  -DBUILD_SHARED_LIBS=OFF \
#  -DOPENCL_INCLUDE_DIRS=../opencl_headers/ \
#  -DOPENCL_LIBRARIES=../opencl_headers/lib/libOpenCL.so

# make -j$(nproc)