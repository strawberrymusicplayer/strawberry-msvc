:hammer_and_wrench: Strawberry - Compile with Visual Studio 2019
================================================================

This guide uses Visual Studio 2019 to compile Strawberry as well all required libraries.


### Requirements

* [Git for Windows](https://gitforwindows.org/)
* [Visual Studio 2019](https://visualstudio.microsoft.com/vs/)
* [Qt Visual Studio Tools](https://marketplace.visualstudio.com/items?itemName=TheQtCompany.QtVisualStudioTools2019)
* [CMake](https://cmake.org/)
* [Meson](https://mesonbuild.com/)
* [Strawberry Perl](https://strawberryperl.com/)
* [Python](https://www.python.org/downloads/windows/)
* [NASM](https://www.nasm.us/)
* [Bison](https://www.gnu.org/software/bison/)
* [Flex](https://github.com/westes/flex)
* [7-Zip](https://www.7-zip.org/download.html)
* [NSIS](https://nsis.sourceforge.io/)
* [NSIS LockedList Plugin](https://nsis.sourceforge.io/LockedList_plug-in)


### Prepare build environment

    MKDIR c:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources


### Download binaries (MinGW Shell)

    mkdir -p /c/Data/Projects/strawberry/strawberry-dependencies/msvc/binaries
    cd /c/Data/Projects/strawberry/strawberry-dependencies/msvc/binaries

    curl -O -L http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe
    curl -O -L https://github.com/mesonbuild/meson/releases/download/0.61.2/meson-0.61.2-64.msi
    curl -O -L https://www.python.org/ftp/python/3.10.2/python-3.10.2-amd64.exe
    curl -O -L https://github.com/lexxmark/winflexbison/releases/download/v2.5.25/win_flex_bison-2.5.25.zip
    curl -O -L https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit.msi
    curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-installer-x64.exe
    curl -O -L https://github.com/ShiftMediaProject/gnutls/releases/download/3.7.3/libgnutls_3.7.3_msvc16.zip


### Download sources (MinGW Shell)

Open Git Bash

    mkdir -p /c/Data/Projects/strawberry

    cd /c/Data/Projects/strawberry
    git clone https://github.com/jonaski/strawberry

    mkdir -p /c/Data/Projects/strawberry/strawberry-dependencies/msvc/sources
    cd /c/Data/Projects/strawberry/strawberry-dependencies/msvc/sources

    curl -O -L https://boostorg.jfrog.io/artifactory/main/release/1.79.0/source/boost_1_79_0.tar.bz2
    curl -O -L https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-1.8.0.tar.gz
    curl -O -L https://zlib.net/zlib-1.2.12.tar.gz
    curl -O -L https://www.openssl.org/source/openssl-3.0.2.tar.gz
    curl -O -L https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.xz
    curl -O -L https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39/pcre2-10.39.tar.bz2
    curl -O -L https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
    curl -O -L https://tukaani.org/xz/xz-5.2.5.tar.xz
    curl -O -L https://github.com/google/brotli/archive/refs/tags/v1.0.9.tar.gz
    curl -O -L https://www.cairographics.org/releases/pixman-0.40.0.tar.gz
    curl -O -L https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.9.13/libxml2-v2.9.13.tar.bz2
    curl -O -L https://github.com/nghttp2/nghttp2/releases/download/v1.47.0/nghttp2-1.47.0.tar.xz
    curl -O -L https://sqlite.org/2022/sqlite-autoconf-3380200.tar.gz
    curl -O -L https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.xz
    curl -O -L https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.xz
    curl -O -L https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.4.tar.xz
    curl -O -L https://www.wavpack.com/wavpack-5.4.0.tar.bz2
    curl -O -L https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
    curl -O -L https://ftp.osuosl.org/pub/xiph/releases/opus/opusfile-0.12.tar.gz
    curl -O -L https://downloads.sourceforge.net/project/mpg123/mpg123/1.29.3/mpg123-1.29.3.tar.bz2
    curl -O -L https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
    curl -O -L https://taglib.org/releases/taglib-1.12.tar.gz
    curl -O -L https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/v1.3.0.tar.gz
    curl -O -L https://www.fftw.org/fftw-3.3.10.tar.gz
    curl -O -L https://github.com/acoustid/chromaprint/releases/download/v1.5.1/chromaprint-1.5.1.tar.gz
    curl -O -L https://download.gnome.org/sources/glib/2.72/glib-2.72.1.tar.xz
    curl -O -L https://download.gnome.org/sources/glib-networking/2.72/glib-networking-2.72.0.tar.xz
    curl -O -L https://github.com/rockdaboot/libpsl/releases/download/0.21.1/libpsl-0.21.1.tar.gz
    curl -O -L https://download.gnome.org/sources/libsoup/2.74/libsoup-2.74.2.tar.xz
    curl -O -L https://gstreamer.freedesktop.org/src/orc/orc-0.4.32.tar.xz
    curl -O -L https://files.musepack.net/source/musepack_src_r475.tar.gz
    curl -O -L https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-0.6.2+release.msvc.zip
    curl -O -L https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-2.0.2.tar.gz
    curl -O -L https://downloads.sourceforge.net/project/bs2b/libbs2b/3.1.0/libbs2b-3.1.0.tar.bz2
    curl -O -L http://ffmpeg.org/releases/ffmpeg-5.0.tar.xz
    curl -O -L https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.20.1.tar.xz
    curl -O -L https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.20.1.tar.xz
    curl -O -L https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.20.1.tar.xz
    curl -O -L https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.20.1.tar.xz
    curl -O -L https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-1.20.1.tar.xz
    curl -O -L https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-cpp-3.19.4.zip
    curl -O -L https://jztkft.dl.sourceforge.net/project/expat/expat/2.4.8/expat-2.4.8.tar.bz2
    curl -O -L https://netix.dl.sourceforge.net/project/freetype/freetype2/2.12.0/freetype-2.12.0.tar.xz
    curl -O -L https://github.com/unicode-org/icu/archive/release-70-1.tar.gz
    curl -O -L https://cairographics.org/releases/cairo-1.16.0.tar.xz
    curl -O -L https://github.com/harfbuzz/harfbuzz/releases/download/4.2.0/harfbuzz-4.2.0.tar.xz
    curl -O -L https://download.qt.io/official_releases/qt/6.3/6.3.0/submodules/qtbase-everywhere-src-6.3.0.tar.xz
    curl -O -L https://download.qt.io/official_releases/qt/6.3/6.3.0/submodules/qttools-everywhere-src-6.3.0.tar.xz

    git clone https://github.com/xiph/speex
    git clone https://github.com/knik0/faad2
    git clone https://github.com/knik0/faac
    git clone https://github.com/pffang/libiconv-for-Windows
    git clone https://github.com/davidsansome/qtsparkle


    curl -O -L https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/qtbase-pcre2.patch


    tar -xvf boost_1_79_0.tar.bz2
    tar -xvf pkgconf-1.8.0.tar.gz
    tar -xvf zlib-1.2.12.tar.gz
    tar -xvf openssl-3.0.2.tar.gz
    tar -xvf libpng-1.6.37.tar.xz
    tar -xvf pcre2-10.39.tar.bz2
    tar -xvf bzip2-1.0.8.tar.gz
    tar -xvf xz-5.2.5.tar.xz
    tar -xvf v1.0.9.tar.gz
    tar -xvf pixman-0.40.0.tar.gz
    tar -xvf libxml2-v2.9.13.tar.bz2
    tar -xvf nghttp2-1.47.0.tar.xz
    tar -xvf sqlite-autoconf-3380200.tar.gz
    tar -xvf libogg-1.3.5.tar.xz
    tar -xvf libvorbis-1.3.7.tar.xz
    tar -xvf flac-1.3.4.tar.xz
    tar -xvf wavpack-5.4.0.tar.bz2
    tar -xvf opus-1.3.1.tar.gz
    tar -xvf opusfile-0.12.tar.gz
    tar -xvf mpg123-1.29.3.tar.bz2
    tar -xvf lame-3.100.tar.gz
    tar -xvf taglib-1.12.tar.gz
    tar -xvf v1.3.0.tar.gz
    tar -xvf fftw-3.3.10.tar.gz
    tar -xvf chromaprint-1.5.1.tar.gz
    tar -xvf glib-2.72.1.tar.xz
    tar -xvf glib-networking-2.72.0.tar.xz
    tar -xvf musepack_src_r475.tar.gz
    tar -xvf fdk-aac-2.0.2.tar.gz
    tar -xvf libpsl-0.21.1.tar.gz
    tar -xvf libsoup-2.74.2.tar.xz
    tar -xvf orc-0.4.32.tar.xz
    tar -xvf libbs2b-3.1.0.tar.bz2
    tar -xvf ffmpeg-5.0.tar.xz
    tar -xvf gstreamer-1.20.1.tar.xz
    tar -xvf gst-plugins-base-1.20.1.tar.xz
    tar -xvf gst-plugins-good-1.20.1.tar.xz
    tar -xvf gst-plugins-bad-1.20.1.tar.xz
    tar -xvf gst-plugins-ugly-1.20.1.tar.xz
    tar -xvf expat-2.4.8.tar.bz2
    tar -xvf freetype-2.12.0.tar.xz
    tar -xvf release-70-1.tar.gz
    tar -xvf cairo-1.16.0.tar.xz
    tar- xvf harfbuzz-4.2.0.tar.xz
    tar -xvf qtbase-everywhere-src-6.3.0.tar.xz
    tar -xvf qttools-everywhere-src-6.3.0.tar.xz
    unzip libopenmpt-0.6.2+release.msvc.zip

    cd qtbase-everywhere-src-6.3.0
    patch -p1 < qtbase-pcre2.patch


### Install boost (MinGW Shell)

    mkdir -p /c/strawberry_msvc_x86_64_debug/include/
    cp -r /c/data/projects/strawberry/strawberry-dependencies/msvc/sources/boost_1_79_0/boost /c/strawberry_msvc_x86_64_debug/include/


### Compile pkgconf

    cd c:\data\projects\strawberry\strawberry-dependencies\msvc\sources\pkgconf
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug -Dtests=false build
    cd build
    ninja
    ninja install
    copy c:\strawberry_msvc_x86_64_debug\bin\pkgconf.exe c:\strawberry_msvc_x86_64_debug\bin\pkg-config.exe


### Set environment variables

    SET PKG_CONFIG_EXECUTABLE=c:\strawberry_msvc_x86_64_debug\bin\pkgconf.exe
    SET PKG_CONFIG_PATH=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig
    SET PATH=c:\strawberry_msvc_x86_64_debug\bin;%PATH%;C:\Program Files\7-Zip
    SET CL="/MP"
    SET CFLAGS=-Ic:/strawberry_msvc_x86_64_debug/include -Ic:/strawberry_msvc_x86_64_debug/include/opus
    SET LDFLAGS=-Lc:/strawberry_msvc_x86_64_debug/lib


### Compile zlib

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\zlib-1.2.12
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug"
    cmake --build .
    cmake --install .
    copy c:\strawberry_msvc_x86_64_debug\lib\zlib.lib c:\strawberry_msvc_x86_64_debug\lib\z.lib


### Compile openssl

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\openssl-3.0.1
    perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix=c:\strawberry_msvc_x86_64_debug --libdir=lib --openssldir=c:\strawberry_msvc_x86_64_debug\ssl --release --with-zlib-include=c:\strawberry_msvc_x86_64_debug\include --with-zlib-lib=c:\strawberry_msvc_x86_64_debug\lib\zlib.lib
    nmake
    nmake install


### Install gnutls

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\binaries
    mkdir gnutls
    cd gnutls
    7z x ..\libgnutls_3.7.3_msvc16.zip
    xcopy /s /y bin\x64\*.* c:\strawberry_msvc_x86_64_debug\bin\
    xcopy /s /y lib\x64\*.* c:\strawberry_msvc_x86_64_debug\lib\
    mkdir c:\strawberry_msvc_x86_64_debug\include\gnutls\
    xcopy /s /y include\gnutls\*.h c:\strawberry_msvc_x86_64_debug\include\gnutls\


### Compile libpng

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\libpng-1.6.37
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug"
    cmake --build .
    cmake --install .


### Compile pcre2

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\pcre2-10.39
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DPCRE2_BUILD_PCRE2_16=ON -DPCRE2_BUILD_PCRE2_32=ON -DPCRE2_BUILD_PCRE2_8=ON -DPCRE2_BUILD_TESTS=OFF -DPCRE2_SUPPORT_UNICODE=ON
    cmake --build .
    cmake --install .


### Compile bzip2

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\bzip2-1.0.8
    mkdir build2
    cd build2
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug"
    cmake --build .
    cmake --install .


### Compile xz

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\xz-5.2.5\windows\vs2019
    msbuild xz_win.sln /property:Configuration=Release
    copy release\x64\liblzma_dll\*.lib c:\strawberry_msvc_x86_64_debug\lib\
    copy release\x64\liblzma_dll\*.dll c:\strawberry_msvc_x86_64_debug\bin\
    copy ..\..\src\liblzma\api\*.h c:\strawberry_msvc_x86_64_debug\include\
    mkdir c:\strawberry_msvc_x86_64_debug\include\lzma
    copy ..\..\src\liblzma\api\lzma\*.* c:\strawberry_msvc_x86_64_debug\include\lzma\


### Compile brotli

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\brotli-1.0.9
    mkdir build2
    cd build2
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_TESTING=OFF
    cmake --build .
    cmake --install .


### Compile libiconv

    cd libiconv-for-Windows
    git checkout 9b7aba8da6e125ef33912fa4412779279f204003
    msbuild libiconv.sln /property:Configuration=Release
    copy lib64\*.lib c:\strawberry_msvc_x86_64_debug\lib\
    copy lib64\*.dll c:\strawberry_msvc_x86_64_debug\bin\
    copy include\*.h c:\strawberry_msvc_x86_64_debug\include\


### Compile pixman

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\pixman-0.40.0
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig -Dgtk=disabled -Dlibpng=enabled build
    cd build
    ninja
    ninja install


### Compile libxml2

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\libxml2-v2.9.13
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DLIBXML2_WITH_PYTHON=OFF -DLIBXML2_WITH_ZLIB=ON
    cmake --build .
    cmake --install .


### Compile nghttp2

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\nghttp2-1.47.0
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DENABLE_SHARED_LIB=ON
    cmake --build .
    cmake --install .


### Compile sqlite

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\sqlite-autoconf-3380200
    cl -DSQLITE_API="__declspec(dllexport)" -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_COLUMN_METADATA sqlite3.c -link -dll -out:sqlite3.dll
    cl shell.c sqlite3.c -Fe:sqlite3.exe
    copy *.h c:\strawberry_msvc_x86_64_debug\include\
    copy *.lib c:\strawberry_msvc_x86_64_debug\lib\
    copy *.dll c:\strawberry_msvc_x86_64_debug\bin\
    copy *.exe c:\strawberry_msvc_x86_64_debug\bin\


### Compile libogg

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\libogg-1.3.5
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DINSTALL_DOCS=OFF
    cmake --build .
    cmake --install .


### Compile libvorbis

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\libvorbis-1.3.7
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DINSTALL_DOCS=OFF
    cmake --build .
    cmake --install .


### Compile flac

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\flac-1.3.4
    mkdir build2
    cd build2
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DBUILD_DOCS=OFF -DBUILD_EXAMPLES=OFF -DINSTALL_MANPAGES=OFF -DBUILD_TESTING=OFF -DBUILD_PROGRAMS=OFF
    cmake --build .
    cmake --install .


### Compile wavpack

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\wavpack-5.4.0
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:/strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF -DWAVPACK_BUILD_DOCS=OFF -DWAVPACK_BUILD_PROGRAMS=OFF -DWAVPACK_ENABLE_ASM=OFF -DWAVPACK_ENABLE_LEGACY=OFF -DWAVPACK_BUILD_WINAMP_PLUGIN=OFF -DWAVPACK_BUILD_COOLEDIT_PLUGIN=OFF
    cmake --build .
    cmake --install .
    mkdir c:\strawberry_msvc_x86_64_debug\include\wavpack
    copy c:\strawberry_msvc_x86_64_debug\include\wavpack.h c:\strawberry_msvc_x86_64_debug\include\wavpack\
    copy c:\strawberry_msvc_x86_64_debug\lib\wavpackdll.lib c:\strawberry_msvc_x86_64_debug\lib\wavpack.lib
    copy c:\strawberry_msvc_x86_64_debug\bin\wavpackdll.dll c:\strawberry_msvc_x86_64_debug\bin\wavpack.dll


### Compile opus

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\opus-1.3.1
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .


### Compile opusfile

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\opusfile-0.12
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .


### Compile speex

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\speex
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .
    copy c:\strawberry_msvc_x86_64_debug\lib\libspeexd.lib c:\strawberry_msvc_x86_64_debug\lib\libspeex.lib
    copy c:\strawberry_msvc_x86_64_debug\bin\libspeexd.dll c:\strawberry_msvc_x86_64_debug\bin\libspeex.dll


### Compile mpg123

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\mpg123-1.29.3
    mkdir build2
    cd build2
    cmake ../ports/cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DBUILD_PROGRAMS=OFF -DBUILD_LIBOUT123=OFF
    cmake --build .
    cmake --install .


### Compile lame

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\lame-3.100
    nmake -f Makefile.MSVC MSVCVER=Win64 libmp3lame.dll
    copy include\*.h c:\strawberry_msvc_x86_64_debug\include\
    copy output\libmp3lame*.lib c:\strawberry_msvc_x86_64_debug\lib\
    copy output\libmp3lame*.dll c:\strawberry_msvc_x86_64_debug\bin\


### Create lame pc file

    echo "prefix=c:/strawberry_msvc_x86_64_debug" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "exec_prefix=c:/strawberry_msvc_x86_64_debug" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "libdir=c:/strawberry_msvc_x86_64_debug/lib" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "includedir=c:/strawberry_msvc_x86_64_debug/include" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "Name: lame" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "Description: encoder that converts audio to the MP3 file format." >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "URL: https://lame.sourceforge.io/" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "Version: 3.100" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "Libs: -Lc:/strawberry_msvc_x86_64_debug/lib -lmp3lame" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc
    echo "Cflags: -Ic:/strawberry_msvc_x86_64_debug/include" >>/c/strawberry_msvc_x86_64_debug/lib/pkgconfig/mp3lame.pc


### Compile taglib

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\taglib-1.12
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .


### Compile dlfcn-win32

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\v1.3.0
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .


### Install fftw3

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\fftw-3.3.10
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF -DENABLE_AVX=ON -DENABLE_AVX2=ON -DENABLE_SSE=ON -DENABLE_SSE2=ON -DENABLE_THREADS=ON -DWITH_COMBINED_THREADS=ON
    cmake --build .
    cmake --install .


### Compile glib

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\glib-2.72.1
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug -Dpkg_config_path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig build
    cd build
    ninja
    ninja install


### Patch glib-networking

    cd /c/data/projects/strawberry/strawberry-dependencies/msvc/sources/glib-networking-2.70.1
    curl -O -L https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-mxe/master/src/glib-networking-1-fixes.patch
    patch -p1 < glib-networking-1-fixes.patch


### Compile glib-networking

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\glib-networking-2.70.1
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig -Dgnutls=enabled -Dopenssl=enabled build
    cd build
    ninja
    ninja install


### Compile libpsl

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\libpsl-0.21.1
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig build
    cd build
    ninja
    ninja install


### Compile libsoup

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\libsoup-2.74.2
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig -Dtests=false -Dvapi=disabled -Dgssapi=disabled -Dintrospection=disabled -Dtests=false -Dsysprof=disabled -Dtls_check=false -Dgnome=false -Dgtk_doc=false build
    cd build
    ninja
    ninja install


### Compile orc

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\orc-0.4.32
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig build
    cd build
    ninja
    ninja install


### Compile musepack

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\musepack_src_r475
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=c:\strawberry_msvc_x86_64_debug -DBUILD_SHARED_LIBS=ON -DSHARED=ON
    cmake --build .
    cmake --install .
    copy libmpcdec\*.lib c:\strawberry_msvc_x86_64_debug\lib\
    copy libmpcdec\*.dll c:\strawberry_msvc_x86_64_debug\bin\


### Compile libopenmpt

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\libopenmpt
    mkdir build2
    cd build2
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=c:\strawberry_msvc_x86_64_debug -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .


### Compile fdk-aac

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\fdk-aac-2.0.2
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=c:\strawberry_msvc_x86_64_debug -DBUILD_SHARED_LIBS=ON -DBUILD_PROGRAMS=OFF
    cmake --build .
    cmake --install .


### Compile faad2

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\faad2
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=c:\strawberry_msvc_x86_64_debug -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .
    copy ..\include\*.h c:\strawberry_msvc_x86_64_debug\include\


### Compile faac

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\faac
    mkdir build
    cd build
    msbuild faac.sln /property:Configuration=release
    copy ..\..\include\*.h c:\strawberry_msvc_x86_64_debug\include\
    copy bin\Release\libfaac_dll.lib c:\strawberry_msvc_x86_64_debug\lib\libfaac.lib
    copy bin\Release\*.dll c:\strawberry_msvc_x86_64_debug\bin\


### Compile libbs2b

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\libbs2b-3.1.0
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=c:\strawberry_msvc_x86_64_debug -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .


### Compile ffmpeg

    cd c:\data\projects\strawberry\strawberry-dependencies\msvc\sources\ffmpeg
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig -Dtests=disabled -Dgpl=enabled build
    cd build
    ninja
    ninja install


### Compile chromaprint

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\chromaprint-1.5.1
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DFFMPEG_ROOT="c:\strawberry_msvc_x86_64_debug" -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug"
    nmake
    cmake --install .


### Compile GStreamer

    cd c:\data\projects\strawberry\strawberry-dependencies\msvc\sources\gstreamer-1.20.1
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig build
    cd build
    ninja
    ninja install


### Compile gst-plugins-base

    cd c:\data\projects\strawberry\strawberry-dependencies\msvc\sources\gst-plugins-base-1.20.1
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig -Dexamples=disabled -Dtests=disabled -Dtools=enabled -Ddoc=disabled -Dorc=enabled -Dadder=enabled -Dapp=enabled -Daudioconvert=enabled -Daudiomixer=enabled -Daudiorate=enabled -Daudioresample=enabled -Daudiotestsrc=enabled -Dcompositor=disabled -Dencoding=disabled -Dgio=enabled -Dgio-typefinder=enabled -Doverlaycomposition=disabled -Dpbtypes=enabled -Dplayback=enabled -Drawparse=disabled -Dsubparse=disabled -Dtcp=enabled -Dtypefind=enabled -Dvideoconvert=disabled -Dvideorate=disabled -Dvideoscale=disabled -Dvideotestsrc=disabled -Dvolume=enabled -Dalsa=disabled -Dcdparanoia=disabled -Dlibvisual=disabled -Dogg=enabled -Dopus=enabled -Dpango=disabled -Dtheora=disabled -Dtremor=disabled -Dvorbis=enabled -Dx11=disabled -Dxshm=disabled -Dxvideo=disabled -Dgl=disabled -Dgl-graphene=disabled -Dgl-jpeg=disabled -Dgl-png=disabled build
    cd build
    ninja
    ninja install


### Compile gst-plugins-good

    cd c:\data\projects\strawberry\strawberry-dependencies\msvc\sources\gst-plugins-good-1.20.1
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig -Dexamples=disabled -Dtests=disabled -Ddoc=disabled -Dorc=enabled -Dalpha=disabled -Dapetag=enabled -Daudiofx=enabled -Daudioparsers=enabled -Dauparse=disabled -Dautodetect=enabled -Davi=disabled -Dcutter=disabled -Ddebugutils=disabled -Ddeinterlace=disabled -Ddtmf=disabled -Deffectv=disabled -Dequalizer=enabled -Dflv=disabled -Dflx=disabled -Dgoom=disabled -Dgoom2k1=disabled -Dicydemux=enabled -Did3demux=enabled -Dimagefreeze=disabled -Dinterleave=disabled -Disomp4=enabled -Dlaw=disabled -Dlevel=disabled -Dmatroska=disabled -Dmonoscope=disabled -Dmultifile=disabled -Dmultipart=disabled -Dreplaygain=enabled -Drtp=enabled -Drtpmanager=disabled -Drtsp=enabled -Dshapewipe=disabled -Dsmpte=disabled -Dspectrum=enabled -Dudp=enabled -Dvideobox=disabled -Dvideocrop=disabled -Dvideofilter=disabled -Dvideomixer=disabled -Dwavenc=enabled -Dwavparse=enabled -Dy4m=disabled -Daalib=disabled -Dbz2=disabled -Dcairo=disabled -Ddirectsound=enabled -Ddv=disabled -Ddv1394=disabled -Dflac=enabled -Dgdk-pixbuf=disabled -Dgtk3=disabled -Djack=disabled -Djpeg=disabled -Dlame=enabled -Dlibcaca=disabled -Dmpg123=enabled -Doss=disabled -Doss4=disabled -Dosxaudio=disabled -Dosxvideo=disabled -Dpng=disabled -Dpulse=disabled -Dqt5=disabled -Dshout2=disabled -Dsoup=enabled -Dspeex=enabled -Dtaglib=enabled -Dtwolame=disabled -Dvpx=disabled -Dwaveform=enabled -Dwavpack=enabled -Dximagesrc=disabled -Dv4l2=disabled -Dv4l2-libv4l2=disabled -Dv4l2-gudev=disabled build
    cd build
    ninja
    ninja install


### Compile gst-plugins-bad

    cd c:\data\projects\strawberry\strawberry-dependencies\msvc\sources\gst-plugins-bad-1.20.1
     meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig  -Dexamples=disabled -Dtests=disabled -Dexamples=disabled -Dgpl=enabled -Dorc=enabled -Daccurip=disabled -Dadpcmdec=disabled -Dadpcmenc=disabled -Daiff=enabled -Dasfmux=enabled -Daudiobuffersplit=disabled -Daudiofxbad=disabled -Daudiolatency=disabled -Daudiomixmatrix=disabled -Daudiovisualizers=disabled -Dautoconvert=disabled -Dbayer=disabled -Dcamerabin2=disabled -Dcodecalpha=disabled -Dcoloreffects=disabled -Ddebugutils=disabled -Ddvbsubenc=disabled -Ddvbsuboverlay=disabled -Ddvdspu=disabled -Dfaceoverlay=disabled -Dfestival=disabled -Dfieldanalysis=disabled -Dfreeverb=disabled -Dfrei0r=disabled -Dgaudieffects=disabled -Dgdp=disabled -Dgeometrictransform=disabled -Did3tag=enabled -Dinter=disabled -Dinterlace=disabled -Divfparse=disabled -Divtc=disabled -Djp2kdecimator=disabled -Djpegformat=disabled -Dlibrfb=disabled -Dmidi=disabled -Dmpegdemux=disabled -Dmpegpsmux=disabled -Dmpegtsdemux=disabled -Dmpegtsmux=disabled -Dmxf=disabled -Dnetsim=disabled -Donvif=disabled -Dpcapparse=disabled -Dpnm=disabled -Dproxy=disabled -Dqroverlay=disabled -Drawparse=disabled -Dremovesilence=enabled -Drist=disabled -Drtmp2=disabled -Drtp=disabled -Dsdp=disabled -Dsegmentclip=disabled -Dsiren=disabled -Dsmooth=disabled -Dspeed=disabled -Dsubenc=disabled -Dswitchbin=disabled -Dtimecode=disabled -Dvideofilters=disabled -Dvideoframe_audiolevel=disabled -Dvideoparsers=disabled -Dvideosignal=disabled -Dvmnc=disabled -Dy4m=disabled -Dopencv=disabled -Dwayland=disabled -Dx11=disabled -Daes=enabled -Daom=disabled -Davtp=disabled -Dandroidmedia=disabled -Dapplemedia=disabled -Dasio=disabled -Dassrender=disabled -Dbluez=enabled -Dbs2b=enabled -Dbz2=disabled -Dchromaprint=enabled -Dclosedcaption=disabled -Dcolormanagement=disabled -Dcurl=disabled -Dcurl-ssh2=disabled -Dd3dvideosink=disabled -Dd3d11=disabled -Ddash=enabled -Ddc1394=disabled -Ddecklink=disabled -Ddirectfb=disabled -Ddirectsound=enabled -Ddtls=disabled -Ddts=disabled -Ddvb=disabled -Dfaac=enabled -Dfaad=enabled -Dfbdev=disabled -Dfdkaac=enabled -Dflite=disabled -Dfluidsynth=disabled -Dgl=disabled -Dgme=disabled -Dgs=disabled -Dgsm=disabled -Dipcpipeline=disabled -Diqa=disabled -Dkate=disabled -Dkms=disabled -Dladspa=disabled -Dldac=disabled -Dlibde265=disabled -Dopenaptx=disabled -Dlv2=disabled -Dmediafoundation=disabled -Dmicrodns=disabled -Dmodplug=disabled -Dmpeg2enc=disabled -Dmplex=disabled -Dmsdk=disabled -Dmusepack=enabled -Dneon=disabled -Dnvcodec=disabled -Donnx=disabled -Dopenal=disabled -Dopenexr=disabled -Dopenh264=disabled -Dopenjpeg=disabled -Dopenmpt=enabled -Dopenni2=disabled -Dopensles=disabled -Dopus=enabled -Dresindvd=disabled -Drsvg=disabled -Drtmp=disabled -Dsbc=disabled -Dsctp=disabled -Dshm=disabled -Dsmoothstreaming=disabled -Dsndfile=disabled -Dsoundtouch=disabled -Dspandsp=disabled -Dsrt=disabled -Dsrtp=disabled -Dsvthevcenc=disabled -Dteletext=disabled -Dtinyalsa=disabled -Dtranscode=disabled -Dttml=disabled -Duvch264=disabled -Dva=disabled -Dvoaacenc=disabled -Dvoamrwbenc=disabled -Dvulkan=disabled -Dwasapi=enabled -Dwasapi2=enabled -Dwebp=disabled -Dwebrtc=disabled -Dwebrtcdsp=disabled -Dwildmidi=disabled -Dwinks=disabled -Dwinscreencap=disabled -Dx265=disabled -Dzbar=disabled -Dzxing=disabled -Dwpe=disabled -Dmagicleap=disabled -Dv4l2codecs=disabled -Disac=disabled -Dhls=enabled -Dhls-crypto=openssl build
    cd build
    ninja
    ninja install


### Compile gst-plugins-ugly

    cd c:\data\projects\strawberry\strawberry-dependencies\msvc\sources\gst-plugins-ugly-1.20.1
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig -Dtests=disabled -Ddoc=disabled -Dgpl=enabled -Dorc=enabled -Dasfdemux=enabled -Ddvdlpcmdec=disabled -Ddvdsub=disabled -Drealmedia=disabled -Dxingmux=enabled -Da52dec=disabled -Damrnb=disabled -Damrwbdec=disabled -Dcdio=disabled -Ddvdread=disabled -Dmpeg2dec=disabled -Dsidplay=disabled -Dx264=disabled build
    cd build
    ninja
    ninja install


### Compile gst-libav

    cd c:\data\projects\strawberry\strawberry-dependencies\msvc\sources\gst-libav-1.20.1
    meson --buildtype=release --prefix=c:\strawberry_msvc_x86_64_debug --pkg-config-path=c:\strawberry_msvc_x86_64_debug\lib\pkgconfig -Dtests=disabled build
    cd build
    ninja
    ninja install


### Compile protobuf

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\protobuf-3.19.4\cmake
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -Dprotobuf_BUILD_SHARED_LIBS=ON -Dprotobuf_BUILD_TESTS=OFF
    cmake --build .
    cmake --install .
    copy protobuf.pc c:\strawberry_msvc_x86_64_debug\lib\pkgconfig\


### Compile expat

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\expat
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DEXPAT_SHARED_LIBS=ON -DEXPAT_BUILD_DOCS=OFF -DEXPAT_BUILD_EXAMPLES=OFF -DEXPAT_BUILD_FUZZERS=OFF -DEXPAT_BUILD_TESTS=OFF -DEXPAT_BUILD_TOOLS=OFF -DEXPAT_BUILD_PKGCONFIG=ON
    cmake --build .
    cmake --install .
    copy protobuf.pc c:\strawberry_msvc_x86_64_debug\lib\pkgconfig\


### Compile freetype

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\freetype-2.12.0
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .


### Compile harfbuzz

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\harfbuzz-4.2.0
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON
    cmake --build .
    cmake --install .


### Compile qtbase

     cd c:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\qtbase-everywhere-src-6.3.0
     mkdir build
     cd build
     cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="c:\strawberry_msvc_x86_64_debug" -DBUILD_SHARED_LIBS=ON -DPKG_CONFIG_EXECUTABLE="c:\strawberry_msvc_x86_64_debug\bin\pkgconf.exe" -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_BENCHMARKS=OFF -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF -DQT_BUILD_TOOLS_BY_DEFAULT=ON -DQT_WILL_BUILD_TOOLS=ON -DBUILD_WITH_PCH=OFF -DFEATURE_rpath=OFF -DFEATURE_pkg_config=ON -DFEATURE_accessibility=ON -DFEATURE_fontconfig=OFF -DFEATURE_harfbuzz=ON -DFEATURE_pcre2=ON -DFEATURE_openssl=ON -DFEATURE_openssl_linked=ON -DFEATURE_opengl=ON -DFEATURE_opengl_dynamic=ON -DFEATURE_use_gold_linker_alias=OFF -DFEATURE_glib=ON -DFEATURE_icu=OFF -DFEATURE_directfb=OFF -DFEATURE_dbus=OFF -DFEATURE_sql=ON -DFEATURE_sql_sqlite=ON -DFEATURE_sql_odbc=OFF -DFEATURE_jpeg=ON -DFEATURE_png=ON -DFEATURE_gif=ON -DFEATURE_style_windows=ON -DFEATURE_style_windowsvista=ON -DFEATURE_system_zlib=ON -DFEATURE_system_png=ON -DFEATURE_system_jpeg=OFF -DFEATURE_system_pcre2=ON -DFEATURE_system_harfbuzz=OFF -DFEATURE_system_sqlite=ON
     cmake --build .
     cmake --install .


### Compile qttools

     cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\qttools-everywhere-src-6.3.0
     mkdir build
     cd build
     c:\strawberry_msvc_x86_64_debug\bin\qt-configure-module.bat ..
     cmake --build .
     cmake --install .


### Compile qtsparkle

    cd C:\Data\Projects\strawberry\strawberry-dependencies\msvc\sources\qtsparkle
    mkdir build
    cd build
    cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DBUILD_WITH_QT6=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_PREFIX_PATH=c:\strawberry_msvc_x86_64_debug\lib\cmake -DCMAKE_INSTALL_PREFIX="c:/strawberry_msvc_x86_64_debug"
    cmake --build .
    cmake --install .


### Compile strawberry

Import strawberry in Visual Studio 2019. Add the following extra CMake arguments (this should already be configured in CMakeSettings.json).

When configuring CMake in Visual Studio you need to use backslashes in paths without quotes as Visual Studio automatically converts them to forward slashes when running CMake.

    mkdir C:\Data\Projects\strawberry\build
    cd C:\Data\Projects\strawberry\build

Configure for debug:

    cmake ..\strawberry -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Debug

Configure for release:

    cmake ..\strawberry -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release

    nmake


### Copy dependencies (MSYS2 Shell)

Run the batch file in C:\Data\Projects\strawberry\strawberry\dist\scripts to copy dependencies over to the build directory.

    pacman -Syu binutils
    cd /c/Data/Projects/strawberry/strawberry/out/build/x64-Debug/Debug
    wget https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-mxe/master/tools/copydlldeps.sh
    chmod u+x copydlldeps.sh
    ./copydlldeps.sh -c -d . -F . -F ./platforms -F ./styles -F ./tls -F ./sqldrivers -F ./imageformats -F ./gio-modules -F ./gstreamer-plugins -R /c/strawberry_msvc_x86_64_debug/bin -R /c/strawberry_msvc_x86_64_debug


To create the NSIS installer open MakeNSIS and drag strawberry.nsi over in the MakeNSIS window.
