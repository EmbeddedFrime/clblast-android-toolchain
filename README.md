# CLBlast Android Toolchain

A streamlined toolchain to cross-compile the [CLBlast](https://github.com/CNugteren/CLBlast) OpenCL BLAS library for Android. This script automatically handles fetching OpenCL headers, building an OpenCL stub library, and compiling CLBlast against the Android NDK.

## Dependencies

### 1. Android NDK r27d (27.3.13750724)

First, you need to download the [Android NDK](https://github.com/android/ndk/wiki) in your environment to cross-compile for Android targets. Ensure that the `NDK_ROOT` environment variable points to the directory of your NDK installation.

You can install any version of the Android NDK you want, but **NDK r27d (27.3.13750724)** is highly recommended.

**Installation Instructions:**
1. Download the [Android Command Line Tools](https://developer.android.com/studio) and install them at `~/Android/Sdk` as recommended by Google.
2. Set your `ANDROID_HOME` variable:
   ```bash
   export ANDROID_HOME=$HOME/Android/Sdk
   ```
3. Download your preferred version of the NDK (e.g., r27d) using the `sdkmanager`:
   ```bash
   sdkmanager --install "ndk;27.3.13750724"
   ```



## Usage

By default, running the script will compile CLBlast `1.7.0` for `arm64-v8a` targeting `android-21` using NDK `27.3.13750724`.

```bash
./build.sh
```

### Advanced Examples: Customizing the Build

The `build.sh` script is configured via environment variables. You can easily override the defaults by passing the variables before the command.

#### Change the Target Platform
To compile for a different Android API level (e.g., API 22):
```bash
PLATFORM=android-22 ./build.sh
```

#### Change the Architecture (ABI)
To build for 32-bit ARM devices:
```bash
ABI=armeabi-v7a ./build.sh
```

#### Change the NDK Version
If you have a different version of the NDK installed, update `NDK_VERSION`:
```bash
NDK_VERSION=26.3.11579264 ./build.sh
```

#### Full Customization Example (Platform & Clang Toolchain)
If you update the target platform, you may also want to manually point to the specific Clang compiler for that API level. 

*(Ensure `NDK_ROOT` is exported first so it evaluates properly in the shell)*

```bash
export NDK_ROOT=$ANDROID_HOME/ndk/27.3.13750724

PLATFORM=android-22 CLANG_ROOT=$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android22-clang ./build.sh
```

---

## What the Script Does

1. **Downloads OpenCL Headers**: Runs `./get_opencl_headers.sh`.
2. **Clones CLBlast**: Fetches the tagged release (default `1.7.0`).
3. **Builds an OpenCL Stub**: Uses Clang to compile `libOpenCL.so` as a shared stub library. This allows linking OpenCL at compile time without needing a physical Android device's proprietary drivers.
4. **Compiles CLBlast**: Runs CMake configured for Android cross-compilation (`c++_static` STL, no shared libs).