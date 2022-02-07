:hammer_and_wrench: Strawberry - Compile with Visual Studio 2019
================================================================

This guide uses Visual Studio 2019 to compile Strawberry as well all required libraries.


### Requirements

* [Git for Windows](https://gitforwindows.org/)
* [Visual Studio 2019](https://visualstudio.microsoft.com/vs/)
* [Qt installer](https://www.qt.io/download-thank-you)
* [Qt Visual Studio Tools](https://marketplace.visualstudio.com/items?itemName=TheQtCompany.QtVisualStudioTools2019)
* [Strawberry Perl](https://strawberryperl.com/)
* [Python](https://www.python.org/downloads/windows/)
* [NSIS](https://nsis.sourceforge.io/)
* [NSIS LockedList Plugin](https://nsis.sourceforge.io/LockedList_plug-in)
* [7-Zip](https://www.7-zip.org/download.html)



### Prepare build environment

    SET PATH=%PATH%;C:\Program Files\7-Zip

    MKDIR c:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources


### Download sources (MinGW Shell)

Open Git Bash

    mkdir -p /c/Data/Projects/strawberry

    cd /c/Data/Projects/strawberry
    git clone https://github.com/jonaski/strawberry

    mkdir -p /c/Data/Projects/strawberry/strawberry-dependencies/msvc/sources
    cd /c/Data/Projects/strawberry/strawberry-dependencies/msvc/sources

    curl -O -L https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.zip
    curl -O -L https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-cpp-3.19.4.zip
    curl -O -L https://sqlite.org/2022/sqlite-autoconf-3370200.tar.gz
    curl -O -L https://download.gnome.org/sources/glib-networking/2.62/glib-networking-2.62.4.tar.xz
    curl -O -L https://taglib.org/releases/taglib-1.12.tar.gz
    curl -O -L https://github.com/acoustid/chromaprint/releases/download/v1.5.1/chromaprint-1.5.1.tar.gz
    git clone https://github.com/davidsansome/qtsparkle
    
    unzip boost_1_78_0.zip
    tar -xvf sqlite-autoconf-3370200.tar.gz
    tar -xvf taglib-1.12.tar.gz
    tar -xvf chromaprint-1.5.1.tar.gz
    tar -xvf glib-networking-2.62.4.tar.xz
    unzip protobuf-cpp-3.19.4.zip
    
    mkdir -p /c/Data/Projects/strawberry/strawberry-dependencies/msvc/binaries
    cd /c/Data/Projects/strawberry/strawberry-dependencies/msvc/binaries

    curl -O -L https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/qt-unified-windows-x86-4.2.0-online.exe
    curl -O -L https://github.com/ShiftMediaProject/gnutls/releases/download/3.7.2/libgnutls_3.7.2_msvc14.zip
    curl -O -L https://fftw.org/pub/fftw/fftw-3.3.5-dll64.zip
    curl -O -L https://gstreamer.freedesktop.org/data/pkg/windows/1.20.0/msvc/gstreamer-1.0-msvc-x86_64-1.20.0.msi
    curl -O -L https://gstreamer.freedesktop.org/data/pkg/windows/1.20.0/msvc/gstreamer-1.0-devel-msvc-x86_64-1.20.0.msi


### Install Qt

Run the installer.
When installing Qt, select MSVC for the latest Qt 6 release, CMake 32-bit, Ninja and "openSSL Toolkit" under Qt / "Developer and Designer Tools".


### Install gstreamer

Run both installers "gstreamer-1.0-msvc-x86_64" and "gstreamer-1.0-devel-msvc-x86_64".
Select complete installation.


### Install boost (MinGW Shell)

    cp -r /c/data/projects/strawberry/strawberry-dependencies/msvc/sources/boost_1_78_0/boost /c/gstreamer/1.0/msvc_x86_64/include/


### Install gnutls (Command Prompt)

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\binaries
    mkdir gnutls
    cd gnutls
    7z x ..\libgnutls_3.7.2_msvc14.zip
    xcopy /s /y bin\x64\*.* c:\gstreamer\1.0\msvc_x86_64\bin\
    xcopy /s /y lib\x64\*.* c:\gstreamer\1.0\msvc_x86_64\lib\
    xcopy /s /y include\* c:\gstreamer\1.0\msvc_x86_64\include\


### Install fftw3 (Command Prompt)

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\binaries
    mkdir fftw
    cd fftw
    7z x ..\fftw-3.3.5-dll64.zip
    lib /def:libfftw3-3.def
    lib /def:libfftw3f-3.def
    lib /def:libfftw3l-3.def
    xcopy /s /y *.dll c:\gstreamer\1.0\msvc_x86_64\bin\
    xcopy /s /y *.lib c:\gstreamer\1.0\msvc_x86_64\lib\
    xcopy /s /y *.h c:\gstreamer\1.0\msvc_x86_64\include\


### Compile sqlite3 (x64 Native Tools Command Prompt for VS 2019)

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\sqlite-autoconf-3370200
    cl -DSQLITE_API="__declspec(dllexport)" sqlite3.c -link -dll -out:sqlite3.dll
    copy *.h c:\gstreamer\1.0\msvc_x86_64\include\
    copy *.lib c:\gstreamer\1.0\msvc_x86_64\lib\
    copy *.dll c:\gstreamer\1.0\msvc_x86_64\bin\


### Compile TagLib (x64 Native Tools Command Prompt for VS 2019)

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\taglib-1.12
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\gstreamer\1.0\msvc_x86_64" -DBUILD_SHARED_LIBS=ON
    nmake
    cmake --install .


### Compile chromaprint (x64 Native Tools Command Prompt for VS 2019)

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\chromaprint-1.5.1
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DFFMPEG_ROOT=C:\gstreamer\1.0\msvc_x86_64 -DCMAKE_INSTALL_PREFIX=C:\gstreamer\1.0\msvc_x86_64
    nmake
    cmake --install .


### Compile glib-networking (x64 Native Tools Command Prompt for VS 2019)

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\glib-networking-2.62.4
    pip3 install meson
    SET PATH=c:\gstreamer\1.0\msvc_x86_64\bin;%PATH%
    meson -Dgnutls=enabled -Dpkg_config_path=c:\gstreamer\1.0\msvc_x86_64\lib\pkgconfig build
    cd build
    ninja


### Compile qtsparkle (x64 Native Tools Command Prompt for VS 2019)

    SET CL=/MP
    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\qtsparkle
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Debug -DBUILD_WITH_QT6=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_PREFIX_PATH=c:\qt\6.2.3\msvc2019_64\lib\cmake -DCMAKE_INSTALL_PREFIX="C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\qtsparkle"
    nmake
    nmake install
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Debug -DBUILD_WITH_QT6=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_PREFIX_PATH=c:\qt\6.2.3\msvc2019_64\lib\cmake -DCMAKE_INSTALL_PREFIX="C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\qtsparkle"
    nmake
    nmake install


### Compile protobuf

    SET CL=/MP
    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\protobuf-3.19.4\cmake
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -Dprotobuf_BUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX="C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\protobuf" -Dprotobuf_BUILD_TESTS=OFF
    nmake
    nmake install


### Compile strawberry

Import strawberry in Visual Studio 2019. Add the following extra CMake arguments (this should already be configured in CMakeSettings.json).

When configuring CMake in Visual Studio you need to use backslashes in paths without quotes as Visual Studio automatically converts them to forward slashes when running CMake.

    SET CL=/MP
    mkdir C:\Data\Projects\strawberry\build
    cd C:\Data\Projects\strawberry\build

Configure for debug:

    cmake ..\strawberry -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Debug  -DPKG_CONFIG_EXECUTABLE=C:\gstreamer\1.0\msvc_x86_64\bin\pkg-config.exe -DBUILD_WITH_QT6=ON -DCMAKE_PREFIX_PATH=c:\qt\6.2.3\msvc2019_64\lib\cmake -DARCH=x86_64 -DENABLE_WIN32_CONSOLE=ON -DENABLE_TRANSLATIONS=OFF -DBoost_INCLUDE_DIR=C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\boost_1_78_0 -DFFTW3_DIR=C:\gstreamer\1.0\msvc_x86_64 -DGNUTLS_LIBRARY=c:\gstreamer\1.0\msvc_x86_64\lib\gnutls.lib -DGNUTLS_INCLUDE_DIR=c:\gstreamer\1.0\msvc_x86_64\include  -DProtobuf_LIBRARY=C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\protobuf\lib\libprotobufd.lib -DProtobuf_INCLUDE_DIR=C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\protobuf\include -DProtobuf_PROTOC_EXECUTABLE=C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\protobuf\bin\protoc.exe -DQTSPARKLE_INCLUDE_DIRS=c:\data\projects\strawberry\strawberry-dependencies\msvc\install\qtsparkle\include

Configure for release:

    cmake ..\strawberry -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release  -DPKG_CONFIG_EXECUTABLE=C:\gstreamer\1.0\msvc_x86_64\bin\pkg-config.exe -DBUILD_WITH_QT6=ON -DCMAKE_PREFIX_PATH=c:\qt\6.2.3\msvc2019_64\lib\cmake -DARCH=x86_64 -DENABLE_TRANSLATIONS=OFF -DBoost_INCLUDE_DIR=C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\boost_1_78_0 -DFFTW3_DIR=C:\gstreamer\1.0\msvc_x86_64 -DGNUTLS_LIBRARY=c:\gstreamer\1.0\msvc_x86_64\lib\gnutls.lib -DGNUTLS_INCLUDE_DIR=c:\gstreamer\1.0\msvc_x86_64\include  -DProtobuf_LIBRARY=C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\protobuf\lib\libprotobuf.lib -DProtobuf_INCLUDE_DIR=C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\protobuf\include -DProtobuf_PROTOC_EXECUTABLE=C:\Data\Projects\strawberry\strawberry-dependencies\msvc\install\protobuf\bin\protoc.exe -DQTSPARKLE_INCLUDE_DIRS=c:\data\projects\strawberry\strawberry-dependencies\msvc\install\qtsparkle\include

    nmake


### Copy dependencies (MinGW Shell)


Run the batch file in C:\Data\Projects\strawberry\strawberry\dist\scripts to copy dependencies over to the build directory.


    cd /c/Data/Projects/strawberry/strawberry/out/build/x64-Debug/Debug
    wget https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-mxe/master/tools/copydlldeps.sh
    chmod u+x copydlldeps.sh
    ./copydlldeps.sh -c -d . -F . -F ./platforms -F ./styles -F ./tls -F ./sqldrivers -F ./imageformats -F ./gio-modules -F ./gstreamer-plugins -R /c/qt/6.2.3/msvc2019_64/bin -R /c/gstreamer/1.0/msvc_x86_64 -R /c/Data/Projects/strawberry/strawberry-dependencies/msvc/install/protobuf/bin -R /c/Data/Projects/strawberry/strawberry-dependencies/msvc/install/qtsparkle/bin

To create the NSIS installer open MakeNSIS and drag strawberry.nsi over in the MakeNSIS window.
