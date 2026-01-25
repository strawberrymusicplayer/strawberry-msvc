# :hammer_and_wrench: Strawberry - Build with Visual Studio 2022/2026

This guide uses Visual Studio 2022/2026 to build Strawberry Music Player as well as required dependencies.

These instructions are provided as-is, they are primarily intended for developers working on Strawberry on Windows.

We do not offer support to users for building Strawberry on Windows.

### Requirements

* [Git for Windows](https://gitforwindows.org/)
* [Powershell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows)
* [Visual Studio 2022 or 2026](https://visualstudio.microsoft.com/vs/)
* [Qt Visual Studio Tools](https://marketplace.visualstudio.com/items?itemName=TheQtCompany.QtVisualStudioTools2022)
* [CMake](https://cmake.org/)
* [Meson](https://mesonbuild.com/)
* [NASM](https://www.nasm.us/)
* [Strawberry Perl](https://strawberryperl.com/)
* [Python](https://www.python.org/downloads/windows/)
* [7-Zip](https://www.7-zip.org/download.html)
* [Win Flex/Bison](https://sourceforge.net/projects/winflexbison/)
* [Rust compiler MSVC](https://www.rust-lang.org)
* [NSIS](https://nsis.sourceforge.io/)
* [NSIS LockedList Plugin](https://nsis.sourceforge.io/LockedList_plug-in)
* [NSIS Inetc Plugin](https://nsis.sourceforge.io/Inetc_plug-in)
* [NSIS Registry Plugin](https://nsis.sourceforge.io/Registry_plug-in)

## Windows setup

### Manual installation on Windows

Download and install manually:
- [Git](https://git-scm.com/downloads)
    - Default settings can be used
- [Visual Studio 2022/2026 Community](https://visualstudio.microsoft.com/vs/)
    - Select `Desktop development with C++`

### Clone repositories and download tools/dependencies

Open a `PowerShell 7` shell and type:

```powershell
mkdir C:\data\projects\strawberry
cd C:\data\projects\strawberry
git clone https://github.com/strawberrymusicplayer/strawberry.git
git clone https://github.com/strawberrymusicplayer/strawberry-msvc.git
cd strawberry-msvc
```

### Installation

Install manually from `C:\data\projects\strawberry\msvc_\downloads`:
- **Required**:
    - Install `7z<VERSION>-x64.exe`
    - Install `cmake-<VERSION>-windows-x86_64.msi`
    - Install `python-<VERSION>-amd64.exe`
        - In first dialog:
            - Check: `Add python.exe to PATH`
            - Click `Install Now` (to use defaults)
        - In dialog `Setup was successful`:
            - Click: `Disable path length limit`
    - Install `strawberry-perl-<VERSION>-64bit.msi`
    - Extract `win_flex_bison-<VERSION>.zip` to `C:\win_flex_bison`
    - Install `rustup-init.exe`
        - Type in a Command Prompt: `cargo install cargo-c`
	- Install `VSYASM`
	    - Clone VSYASM from https://github.com/ShiftMediaProject/VSYASM
		- Run `install_script.bat`, or manually copy `yasm.props`, `yasm.targets` and `yasm.xml`
		  to `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Microsoft\VC\v180\BuildCustomizations` for Visual Studio 2026
		  or `C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Microsoft\VC\v170\BuildCustomizations` for Visual Studio 2022.
		- Delete `yasm.exe` from `C:\Program Files\Microsoft Visual Studio\18\Community\VC` (or `C:\Program Files\Microsoft Visual Studio\2022\Community\VC`),
		  the current latest version (1.3.0) crashes.
- **Recommended: When building dependencies from source**:
    - Install `nasm-<VERSION>-installer-x64.exe`
        - Run as `Administrator` and install into `C:\Program Files\NASM`.
- **Recommended: When creating NSIS Windows installer**:
    - Install NSIS: `nsis-<NSIS_VERSION>-setup.exe`
    - Extract NSIS `LockedList.zip` plugin:
        - Copy `LockedList\Plugins\LockedList64.dll` to `C:\Program Files (x86)\NSIS\Plugins\LockedList64.dll`
        - Copy `LockedList\Plugins\x86-unicode\LockedList.dll` to `C:\Program Files (x86)\NSIS\Plugins\x86-unicode\LockedList.dll`
    - Extract NSIS `Inetc.zip` plugin:
        - Copy `Inetc\Plugins\x86-unicode\INetC.dll` to `C:\Program Files (x86)\NSIS\Plugins\x86-unicode\INetC.dll`
    - Extract NSIS `Registry.zip` plugin:
        - Copy `Registry\Desktop\Plugin\registry.dll` to `C:\Program Files (x86)\NSIS\Plugins\registry.dll`
        - Copy `Registry\Desktop\Plugin\registry.dll` to `C:\Program Files (x86)\NSIS\Plugins\x86-unicode\registry.dll`

### Configure PATH environment variable

Delete `pkg-config` files to prevent conflicts with Strawberry's own `pkg-config`:
- Delete `C:\strawberry\perl\bin\pkg-config`
- Delete `C:\strawberry\perl\bin\pkg-config.bat`

Windows Settings | System | About | Advanced system settings | Tab Advanced | Environment Variables:
- System variables | Path | Edit:
    - Delete: `C:\Strawberry\c\bin` (To prevent conflicts with other utilities)
    - Add: `C:\Program Files\Git\bin` (This is for `sed` and `patch` utilities)
    - Add: `C:\Program Files (x86)\NSIS`
    - Make sure no MinGW-W64 (gcc, g++, etc) installation is in `PATH`, as this can cause those to be picked up as compiler instead of MSVC.

### Meson installation

Building with Meson 1.6.0 installation results in build issues
[meson: error: unrecognized arguments:](https://github.com/strawberrymusicplayer/strawberry-msvc/issues/6).

A temporary solution is to remove Meson via Windows Settings | `Apps or remove programs`.
Then install Meson via Python PIP system wide. Start | `PowerShell 7` and type:

```
pip install meson
```

### Optional: Prebuilt binary dependencies

Prebuilt MSVC binaries can be optionally used to speed-up the build process. When this step is skipped, all libraries and dependencies are build from source.

To use prebuilds, download the following `tar.xz` files from Github [strawberry-msvc-dependencies/releases](https://github.com/strawberrymusicplayer/strawberry-msvc-dependencies/releases):
- For debug, extract `strawberry-msvc-x86_64-debug.tar.xz` to `C:\strawberry_msvc_x86_64_debug`
- For release, extract `strawberry-msvc-x86_64-release.tar.xz` to `C:\strawberry_msvc_x86_64_release`

## Build Strawberry from source including dependencies

- Set one debug or release in `PATH` environment variable:
    - For debug: `C:\strawberry_msvc_x86_64_debug\bin`, or:
    - For release: `C:\strawberry_msvc_x86_64_release\bin`

- Start | `PowerShell 7`

```powershell
cd C:\data\projects\strawberry\strawberry-msvc

rem For debug build:
.\StrawberryMSVCBuild.ps1 -build_type debug -arch x86_64

rem For release build:
.\StrawberryMSVCBuild.ps1 -build_type release -arch x86_64
```

Strawberry and Windows installer executables are generated in:
- For debug: `C:\data\projects\strawberry\msvc_\build_debug\strawberry\build\`
- For release: `C:\data\projects\strawberry\msvc_\build_release\strawberry\build\`

## Setting up Strawberry for development in Visual Studio 2022 or 2026

Optional `Qt Visual Studio Tools` can be installed via the toolbar `Extensions | Manage Extensions` and search for `Qt Visual Studio Tools`. Then click `Install`.

Debug build:
- Make sure the path `C:\strawberry_msvc_x86_64_debug\bin` is added to the `PATH` environment variable before starting Visual Studio 2022 or 2026.
- Start | Visual Studio 2022 or 2026
- Open a local folder `C:\data\projects\strawberry\strawberry`
- Toolbar Project | CMake Settings:
    - Select Configurations `x64-Debug`
    - Add `CMake command arguments`: `-DARCH=x86_64 -DICU_ROOT=c:\\strawberry_msvc_x86_64_debug -DBUILD_WERROR=ON -DENABLE_WIN32_CONSOLE=ON -DENABLE_AUDIOCD=OFF -DENABLE_MTP=OFF -DENABLE_GPOD=OFF`
- Select in the toolbar `x64-Debug`
- Toolbar: Build | Build All

Release build:
- Make sure the path `C:\strawberry_msvc_x86_64_release\bin` is added to the `PATH` environment variable before starting Visual Studio 2022 or 2026.
- Start | Visual Studio 2022 or 2026
- Open a local folder `C:\data\projects\strawberry\strawberry`
- Toolbar Project | CMake Settings:
    - Create new `x64-Release`
    - Select Configurations `x64-Release`
    - Add `CMake command arguments`: `-DARCH=x86_64 -DICU_ROOT=c:\\strawberry_msvc_x86_64_release -DBUILD_WERROR=ON -DENABLE_WIN32_CONSOLE=OFF -DENABLE_AUDIOCD=OFF -DENABLE_MTP=OFF -DENABLE_GPOD=OFF`
    - Save the changes
    - In the toolbar select `x64-Release`
    - Project | Delete Cache and Reconfigure
- Toolbar: Build | Build All

Set breakpoint and press F5 to start debugging and use F10 to step into and F11 to step over.
