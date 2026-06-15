#!/bin/bash
set -e # Exit immediately if any command fails

# --- Tested on v2026.05.29 ---
# Change this tag if you need a newer OpenCL specifications
OPENCL_RELEASE_TAG=${OPENCL_TAG:-"v2026.05.29"} #last realeased


# --- Download OpenCL C Headers ---
if [ ! -d "./opencl_headers/CL" ]; then
    git clone -b "$OPENCL_RELEASE_TAG" --depth 1 -c advice.detachedHead=false https://github.com/KhronosGroup/OpenCL-Headers.git ./tmp
    
    # Structure the target directory
    rm -rf ./opencl_headers/CL && mkdir -p ./opencl_headers/CL && mv ./tmp/CL/* ./opencl_headers/CL  && rm -rf ./tmp
fi

# --- Download opencl.hpp c++ Header ---
if [ ! -f "./opencl_headers/CL/opencl.hpp" ]; then
    curl -o ./opencl_headers/CL/opencl.hpp https://raw.githubusercontent.com/KhronosGroup/OpenCL-CLHPP/${OPENCL_RELEASE_TAG}/include/CL/opencl.hpp
fi

#For the older version of openCL :
#curl -o ./opencl/opencl_headers/CL/cl2.hpp https://raw.githubusercontent.com/#KhronosGroup/OpenCL-CLHPP/${OPENCL_RELEASE_TAG}/include/CL/cl2.hpp

