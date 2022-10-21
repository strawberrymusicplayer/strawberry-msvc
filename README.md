:hammer_and_wrench: Strawberry - Compile with Visual Studio 2022
================================================================

This guide uses Visual Studio 2022 to compile Strawberry as well all required libraries.


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
 - Make sure no MinGW-W64 (gcc, g++, etc) installation is in PATH, as this can cause those to be picked up as compiler instead of MSVC.
 - You need the sed and patch utility, it can be copied from ie.: MSYS2 and put in ie.: C:\Data\Tools and added to PATH.


### Installing NSIS plugins

To create the Strawberry installer, you need 3 NSIS plugins (LockedList, Inetc and Registry).

Those need to be manually extracted, and copied to C:\Program Files (x86)\NSIS\Plugins

Specifcally, the following files need to exist:

    C:\Program Files (x86)\NSIS\Plugins\LockedList64.dll
    C:\Program Files (x86)\NSIS\Plugins\Registry.dll
    C:\Program Files (x86)\NSIS\Plugins\x86-unicode\LockedList.dll
    C:\Program Files (x86)\NSIS\Plugins\x86-unicode\Registry.dll
    C:\Program Files (x86)\NSIS\Plugins\x86-unicode\INetC.dll


### Alternative 1: Installing dependencies

Download the latest dependencies from https://github.com/strawberrymusicplayer/strawberry-msvc-dependencies/releases

Extract them to ie.: "c:\strawberry_msvc_x86_64_debug" for the debug version, or "c:\strawberry_msvc_x86_64_release" for the release version.


### Alternative 2: Building all dependencies from source

This guide provides a "download.bat" and "compile.bat" file to automatically build all dependencies.

Start "x64 Native Tools Command Prompt for VS 2022"

Run download.bat

This should download all necessary sources.


#### Compile for debug

    compile.bat "debug"


#### Compile for release

    compile.bat "release"


### Building strawberry

Add "c:\strawberry_msvc_x86_64_debug\bin" for the debug version, or "c:\strawberry_msvc_x86_64_release\bin" for the release version to PATH.

Open the strawberry git source directory in Visual Studio 2022.

Add the following extra CMake arguments:

For debug:

    -DARCH=x86_64 -DICU_ROOT=c:\\strawberry_msvc_x86_64_debug


For release:

    -DARCH=x86_64 -DICU_ROOT=c:\\strawberry_msvc_x86_64_release


### Copy dependencies (MSYS2 Shell)

Run the "copy-deps-msvc-x64-debug-qt6.bat" or "copy-deps-msvc-x64-release-qt6.bat" batch file first to copy all plugins to the build directory.
After that, you can use the copydlldeps.sh shell script to copy all the dependencies to the build directory.

Install MSYS (https://www.msys2.org/)

    pacman -Syu binutils
    cd /c/Data/Projects/strawberry/strawberry/out/build/x64-Debug/Debug
    wget https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-mxe/master/tools/copydlldeps.sh
    chmod u+x copydlldeps.sh
    ./copydlldeps.sh -c -d . -F . -F ./platforms -F ./styles -F ./tls -F ./sqldrivers -F ./imageformats -F ./gio-modules -F ./gstreamer-plugins -R /c/strawberry_msvc_x86_64_debug/bin -R /c/strawberry_msvc_x86_64_debug

To create the NSIS installer open MakeNSIS and drag strawberry.nsi over in the MakeNSIS window.
