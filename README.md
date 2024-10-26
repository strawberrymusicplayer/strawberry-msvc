:hammer_and_wrench: Strawberry - Build with Visual Studio 2022
================================================================

This guide uses Visual Studio 2022 to build Strawberry as well all required libraries.

These instructions are provided as-is, they are primarily intended for developers working on Strawberry on Windows.

We do not offer support to users for building Strawberry on Windows.

Build tools (Git, CMake, Meson, Perl, Python, etc) versions are not regulary updated, so make sure you bump the versions in versions.bat before you run install.bat.

### Requirements

There is an install.bat batch file to install most of these automatically.

* [Git for Windows](https://gitforwindows.org/)
* [Visual Studio 2022](https://visualstudio.microsoft.com/vs/)
* [Qt Visual Studio Tools](https://marketplace.visualstudio.com/items?itemName=TheQtCompany.QtVisualStudioTools2022)
* [CMake](https://cmake.org/)
* [Meson](https://mesonbuild.com/)
* [NASM](https://www.nasm.us/)
* [Strawberry Perl](https://strawberryperl.com/)
* [Python](https://www.python.org/downloads/windows/)
* [7-Zip](https://www.7-zip.org/download.html)
* [Win Flex/Bison](https://sourceforge.net/projects/winflexbison/)
* [NSIS](https://nsis.sourceforge.io/)
* [NSIS LockedList Plugin](https://nsis.sourceforge.io/LockedList_plug-in)
* [NSIS Inetc Plugin](https://nsis.sourceforge.io/Inetc_plug-in)
* [NSIS Registry Plugin](https://nsis.sourceforge.io/Registry_plug-in)


### Preparing system for building

 - Remove "C:\Strawberry\c\bin" from PATH.
 - Make sure no pkg-config utility is in PATH, this will cause conflicts with Strawberry's own pkg-config.
   (del c:\strawberry\perl\bin\pkg-config.bat).
 - Make sure no MinGW-W64 (gcc, g++, etc) installation is in PATH, as this can cause those to be picked up as compiler instead of MSVC.
 - You need the sed and patch utility, add C:\Program Files\Git\usr\bin to PATH.


### Installing NSIS plugins

To create the Strawberry installer, you need 3 NSIS plugins (LockedList, Inetc and Registry).

Those need to be manually extracted, and copied to C:\Program Files (x86)\NSIS\Plugins

Specifically, the following files need to exist:

    C:\Program Files (x86)\NSIS\Plugins\LockedList64.dll
    C:\Program Files (x86)\NSIS\Plugins\Registry.dll
    C:\Program Files (x86)\NSIS\Plugins\x86-unicode\LockedList.dll
    C:\Program Files (x86)\NSIS\Plugins\x86-unicode\Registry.dll
    C:\Program Files (x86)\NSIS\Plugins\x86-unicode\INetC.dll


### Building all dependencies from source

This guide provides a "download.bat" and "build.bat" file to automatically build all dependencies.

Start "x64 Native Tools Command Prompt for VS 2022"

Run download.bat

This should download all necessary sources.


#### Build for debug

    build.bat "debug"


#### Build for release

    build.bat "release"


### Building strawberry

Add "c:\strawberry_msvc_x86_64_debug\bin" for the debug version, or "c:\strawberry_msvc_x86_64_release\bin" for the release version to PATH.

Open the strawberry git source directory in Visual Studio 2022.

Add the following extra CMake arguments:

For debug:

    -DARCH=x86_64 -DICU_ROOT=c:\\strawberry_msvc_x86_64_debug


For release:

    -DARCH=x86_64 -DICU_ROOT=c:\\strawberry_msvc_x86_64_release
