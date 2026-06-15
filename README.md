# CLBlast Android Toolchain
## Introduction
A streamlined toolchain to cross-compile the [CLBlast](https://github.com/CNugteren/CLBlast) OpenCL BLAS library for Android. This script automatically handles fetching OpenCL headers, building an OpenCL stub library, and compiling CLBlast against the Android NDK.

## Prerequisites
### 1. Android NDK r27d (27.3.13750724)

First, you need to download the [Android NDK](https://github.com/android/ndk/wiki) in your environment to cross-compile for Android targets.

You can install any version of the Android NDK you want, but **NDK r27d (27.3.13750724)** is highly recommended.

**Recommanded installation instructions:**
1. Download the [Android Command Line Tools](https://developer.android.com/studio#command-line-tools-only)
2. Install them and set `ANDROID_HOME` and `sdkmanager`to your bash path:
```bash
   # Put default Android Studio path 
   # or wherever you installed it
   echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc  
   echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.bashrc
   source ~/.bashrc #reload bash configuration
```
3. Download your preferred version of the NDK using the `sdkmanager`:
```bash
sdkmanager --install "ndk;27.3.13750724"
```


## Usage

By default, running the script will compile CLBlast `1.7.0` for `arm64-v8a` targeting `android-21` using android NDK `27.3.13750724`.

```bash
./build.sh
```

### Advanced Examples: Customizing the Build

The `build.sh` script is configured via environment variables. You can easily override the defaults by passing the variables before the command.

#### Variable 1 - Change the Target Android Platform:

```bash
# e.g. Set the target platform to android-22
PLATFORM=android-22 ./build.sh
```

#### Variable 2 - Change the Architecture (ABI) 
```bash
# e.g. Set the ABI to armeabi-v7a for 32-bit ARM
ABI=armeabi-v7a ./build.sh
```

#### Variable 3 - Change the NDK Version
```bash
# e.g. Use older NDK r25 (25.1.8937393)
NDK_VERSION=25.1.8937393 ./build.sh
```

#### Variable 4 - Change OpenCL Headers Version
```bash
# e.g. Use older OpenCL headers from v2025.07.22
OPENCL_TAG=v2025.07.22 ./build.sh
```

#### Variable 5 - Change CLBlast Version
```bash
# e.g. Use older CLBLAST version 1.6.3
VCLBLAST_TAG=1.6.3 ./build.sh
```

#### Variable 6 - Custom CMake Toolchain Path
```bash
# e.g. Override the default NDK toolchain with a completely custom toolchain file
CMAKE_TOOLCHAIN=/opt/custom-toolchains/android.toolchain.cmake ./build.sh
```

#### Full Customization Example (Multiple Variables)
You can chain multiple variables together to completely customize the environment, target hardware, and library versions in a single line. 

For example, to build a 32-bit ARM version targeting Android API 22 using an older NDK version, older OpenCL headers, and a custom CLBlast tag:

```bash
ABI=armeabi-v7a PLATFORM=android-22 NDK_VERSION=25.1.8937393 OPENCL_TAG=v2025.07.22 VCLBLAST_TAG=1.6.3 ./build.sh
```

#### Cleaning Up the Workspace
The script includes an automated cleanup routine to restore your repository to its pristine state. This will wipe the build directories, downloaded components, and cached files:

```bash
./build.sh clean
```

---

## What the Script Does

1. **Downloads OpenCL Headers**: Runs `./get_opencl_headers.sh` to download OpenCL header.
2. **Clones CLBlast**: Fetches the targeted release tag (default `1.7.0`) from the official repository.
3. **Builds the OpenCL Stub (via CMake)**: Configures and compiles a dummy `libOpenCL.so` in `./build_stub` using the NDK toolchain. This allows linking OpenCL at compile time without needing a physical Android device.
4. **Cross-Compiles CLBlast**: Configures a separate `./build` directory using the NDK toolchain file. It builds CLBlast as a static library matching your selected `$ABI` and `$PLATFORM`, links it to the local stub.