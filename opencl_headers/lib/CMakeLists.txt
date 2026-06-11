cmake_minimum_required(VERSION 3.10)
project(OpenCL_Stub C)
# Stub shared library — empty symbols for link-time only
# The real libOpenCL.so is provided by the GPU driver on the mobile device 
add_library(OpenCL SHARED ./opencl_stub.c)