#!/bin/bash
set -e  # Exit immediately if any command fails

# --- ./bash.sh clean ---
if [[ "$1" == "clean" ]]; then
    echo "Cleaning up all build directories and downloaded dependencies..."
    rm -rf ./build ./build_stub ./CLBlast ./opencl_headers/CL
    echo "Clean complete."
    exit 0
fi


# --- working toolchain (tested with android ndk r27d) ---
ABI=${ABI:-arm64-v8a}        # 32 or 64 bit
PLATFORM=${PLATFORM:-android-21}  # android 5
NDK_VERSION=${NDK_VERSION:-27.3.13750724}  # 27.3.13750724 (NDK r27d)

NDK_ROOT=$ANDROID_HOME/ndk/$NDK_VERSION    #standard android home root
CMAKE_TOOLCHAIN=${CMAKE_TOOLCHAIN:-$NDK_ROOT/build/cmake/android.toolchain.cmake}

# --- working openCL Headers released ---
OPENCL_RELEASE_TAG=${OPENCL_TAG:-"v2026.05.29"} #last realeased
# --- working CLBLAST released ---
CLBLAST_VERSION=${VCLBLAST_TAG:-"1.7.0"} #last realeased


echo "Downloading all the dependency..."

# --- Download the opencl headers ---
./get_opencl_headers.sh $OPENCL_RELEASE_TAG

# (tested on CLBlast 1.7.0)
# --- Download the latest CLBLAST library ---
if [ ! -d "./CLBlast" ]; then
    git clone -b "$CLBLAST_VERSION" --depth 1 -c advice.detachedHead=false \
        https://github.com/CNugteren/CLBlast.git ./CLBlast
fi
# dev branch :
# git clone git@github.com:CNugteren/CLBlast.git    # fix the  error : DCMAKE_CXX_FLAGS="-Wno-error=format-security"


echo "Compilation ..."
# --- Compile Stub ---
mkdir -p ./build_stub
cd ./build_stub
rm -rf ./*
cmake ../opencl_headers/lib \
    -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
    -DANDROID_ABI=$ABI \
    -DANDROID_PLATFORM=$PLATFORM
make -j$(nproc)
cd ..

if [[ -n "${OPENCL_STUB_ONLY}" ]]; then
    echo "Successful! You can find your file at /build_stub/libOpenCL.so ."
    exit 0 #stop de script here
fi

# --- Compile CLBlast ---
mkdir -p ./build
cd ./build
rm -rf ./* #make clean

cmake ../CLBlast \
 -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
 -DANDROID_ABI=$ABI\
 -DANDROID_PLATFORM=$PLATFORM \
 -DANDROID_STL=c++_static \
 -DBUILD_SHARED_LIBS=OFF \
 -DOPENCL_INCLUDE_DIRS=../opencl_headers/ \
 -DOPENCL_LIBRARIES=../build_stub/libOpenCL.so \
 -DCMAKE_CXX_FLAGS="-Wno-error=format-security"     # This flag solve a bug in the CLBlast 1.7.0 Release

make -j$(nproc)

cd ..

echo "Successful! You can find your files at ./build/libclblast.a and ./build_stub/libOpenCL.so ."

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


