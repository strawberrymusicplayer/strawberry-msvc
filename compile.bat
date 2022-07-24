@echo on

@setlocal

@echo *** Strawberry MSVC compile script ***

@set BUILD_TYPE=%1%
@if "%BUILD_TYPE%" == "" set BUILD_TYPE=debug

@set DOWNLOADS_PATH=c:\data\projects\strawberry\msvc_\downloads
@set BUILD_PATH=c:\data\projects\strawberry\msvc_\build_%BUILD_TYPE%
@set PREFIX_PATH=c:\strawberry_msvc_x86_64_%BUILD_TYPE%
@set PREFIX_PATH_FORWARD=%PREFIX_PATH:\=/%
@set PREFIX_PATH_ESCAPE=%PREFIX_PATH:\=\\%

@echo Build type: %BUILD_TYPE%
@echo Build path: %BUILD_PATH%
@echo Prefix path: %PREFIX_PATH%

:create_directories

@echo Creating directories

@if not exist "%DOWNLOADS_PATH%" MKDIR "%DOWNLOADS_PATH%" || goto end
@if not exist "%BUILD_PATH%" MKDIR "%BUILD_PATH%" || goto end
@if not exist "%PREFIX_PATH%" MKDIR "%PREFIX_PATH%" || goto end
@if not exist "%PREFIX_PATH%\bin" MKDIR "%PREFIX_PATH%\bin" || goto end
@if not exist "%PREFIX_PATH%\lib" MKDIR "%PREFIX_PATH%\lib" || goto end
@if not exist "%PREFIX_PATH%\include" MKDIR "%PREFIX_PATH%\include" || goto end


:install

@if not exist "%PREFIX_PATH%\bin\yasm.exe" goto yasm
@if not exist "%PREFIX_PATH%\bin\sed.exe" goto sed

goto setup

:sed

copy /y "%DOWNLOADS_PATH%\sed.exe" "%PREFIX_PATH%\bin\" || goto end

@goto install

:yasm

copy /y "%DOWNLOADS_PATH%\yasm-1.3.0-win64.exe" "%PREFIX_PATH%\bin\yasm.exe" || goto end

@goto install


:setup

@echo Setting environment variables

@set PKG_CONFIG_EXECUTABLE=%PREFIX_PATH%\bin\pkgconf.exe
@set PKG_CONFIG_PATH=%PREFIX_PATH%\lib\pkgconfig

@set CL=/MP
@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include -I%PREFIX_PATH_FORWARD%/include/opus

@set PATH=%PREFIX_PATH%\bin;%PATH%


@goto check


:check

echo Checking requirements...

@patch --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Git\usr\bin
@patch --version >NUL 2>&1 || (
  @echo "Missing patch."
  @goto end
)

@sed --version >NUL 2>&1 || (
  @echo "Missing sed."
  @goto end
)

@nasm --version >NUL 2>&1 || set PATH=%PATH%;c:\Program Files\nasm
@nasm --version >NUL 2>&1 || (
  @echo "Missing nasm. Download nasm from https://www.nasm.us/"
  @goto end
)

@win_flex --version >NUL 2>&1 || set PATH=%PATH%;c:\win_flex_bison
@win_flex --version >NUL 2>&1 || (
  @echo "Missing win_flex. Download win_flex from https://sourceforge.net/projects/winflexbison/"
  @goto end
)

@win_bison --version >NUL 2>&1 || set PATH=%PATH%;c:\win_flex_bison
@win_bison --version >NUL 2>&1 || (
  @echo "Missing win_bison. Download win_bison from https://sourceforge.net/projects/winflexbison/"
  @goto end
)

@perl --version >NUL 2>&1 || set PATH=%PATH%;C:\Strawberry\perl\bin
@perl --version >NUL 2>&1 || (
  @echo "Missing perl. Download Strawberry Perl from https://strawberryperl.com/"
  @goto end
)

@python --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Python310
@python --version >NUL 2>&1 || (
  @echo "Missing python. Download Python from https://www.python.org/"
  @goto end
)

@tar --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Git\usr\bin
@tar --version >NUL 2>&1 || (
  @echo "Missing tar."
  @goto end
)

@bzip2 --help >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Git\usr\bin
@bzip2 --help >NUL 2>&1 || (
  @echo "Missing bzip2."
  @goto end
)

@7z --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\7-Zip
@7z i >NUL 2>&1 || (
  @echo "Missing 7z. Download 7-Zip from https://www.7-zip.org/download.html"
  @goto end
)

@cmake --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\CMake\bin
@cmake --version >NUL 2>&1 || (
  @echo "Missing cmake. Download CMake from https://cmake.org/"
  @goto end
)

@meson --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Meson
@meson --version >NUL 2>&1 || (
  @echo "Missing meson. Download Meson from https://mesonbuild.com/"
  @goto end
)

@nmake /help >NUL 2>&1 || (
  @echo "Missing nmake. Install Visual Studio 2019"
  @goto end
)


goto continue


:continue


@if not exist "%PREFIX_PATH%\include\boost\config.hpp" goto boost
@if not exist "%PREFIX_PATH%\bin\pkgconf.exe" goto pkgconf
@if not exist "%PREFIX_PATH%\lib\zlib*.lib" goto zlib
@if not exist "%PREFIX_PATH%\bin\libssl-3-x64.dll" goto openssl
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc" goto gnutls
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libpng.pc" goto libpng
@if not exist "%PREFIX_PATH%\lib\pkgconfig\bzip2.pc" goto bzip2
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libpcre2-16.pc" goto pcre2
@if not exist "%PREFIX_PATH%\lib\liblzma.lib" goto xz
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libbrotlicommon.pc" goto brotli
@if not exist "%PREFIX_PATH%\lib\libiconv.lib" goto libiconv
@if not exist "%PREFIX_PATH%\lib\pkgconfig\pixman-1.pc" goto pixman
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libxml-2.0.pc" goto libxml2
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libnghttp2.pc" goto nghttp2
@if not exist "%PREFIX_PATH%\lib\pkgconfig\sqlite3.pc" goto sqlite
@if not exist "%PREFIX_PATH%\lib\pkgconfig\ogg.pc" goto libogg
@if not exist "%PREFIX_PATH%\lib\pkgconfig\vorbis.pc" goto libvorbis
@if not exist "%PREFIX_PATH%\lib\pkgconfig\flac.pc" goto flac
@if not exist "%PREFIX_PATH%\lib\pkgconfig\wavpack.pc" goto wavpack
@if not exist "%PREFIX_PATH%\lib\pkgconfig\opus.pc" goto opus
@if not exist "%PREFIX_PATH%\bin\opusfile.dll" goto opusfile
@if not exist "%PREFIX_PATH%\lib\pkgconfig\speex.pc" goto speex
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libmpg123.pc" goto mpg123
@if not exist "%PREFIX_PATH%\lib\pkgconfig\mp3lame.pc" goto lame
@if not exist "%PREFIX_PATH%\lib\libtwolame_dll.lib" goto twolame
@if not exist "%PREFIX_PATH%\lib\pkgconfig\taglib.pc" goto taglib
@if not exist "%PREFIX_PATH%\include\dlfcn.h" goto dlfcn-win32
@if not exist "%PREFIX_PATH%\lib\libfftw3-3.lib" goto fftw3
@if not exist "%PREFIX_PATH%\lib\pkgconfig\glib-2.0.pc" goto glib
@if not exist "%PREFIX_PATH%\lib\gio\modules\gioopenssl.lib" goto glib-networking
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libpsl.pc" goto libpsl
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libsoup-2.4.pc" goto libsoup
@if not exist "%PREFIX_PATH%\lib\pkgconfig\orc-0.4.pc" goto orc
@if not exist "%PREFIX_PATH%\lib\mpcdec.lib" goto musepack
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libopenmpt.pc" goto libopenmpt
@if not exist "%PREFIX_PATH%\lib\pkgconfig\fdk-aac.pc" goto fdk-aac
@if not exist "%PREFIX_PATH%\lib\faad.lib" goto faad2
@if not exist "%PREFIX_PATH%\lib\libfaac.lib" goto faac
@if not exist "%PREFIX_PATH%\lib\libbs2b.lib" goto libbs2b
@if not exist "%PREFIX_PATH%\lib\avutil.lib" goto ffmpeg
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libchromaprint.pc" goto chromaprint
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gstreamer-1.0.pc" goto gstreamer
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gstreamer-plugins-base-1.0.pc" goto gst-plugins-base
@if not exist "%PREFIX_PATH%\lib\gstreamer-1.0\gstdirectsound.lib" goto gst-plugins-good
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gstreamer-plugins-bad-1.0.pc" goto gst-plugins-bad
@if not exist "%PREFIX_PATH%\lib\gstreamer-1.0\gstasf.lib" goto gst-plugins-ugly
@if not exist "%PREFIX_PATH%\lib\gstreamer-1.0\gstlibav.lib" goto gst-libav
@if not exist "%PREFIX_PATH%\lib\pkgconfig\protobuf.pc" goto protobuf
@if not exist "%PREFIX_PATH%\bin\qt-configure-module.bat" goto qtbase
@if not exist "%PREFIX_PATH%\bin\linguist.exe" goto qttools
@if not exist "%PREFIX_PATH%\lib\pkgconfig\qtsparkle-qt6.pc" goto qtsparkle
@if not exist "%BUILD_PATH%\strawberry\build\strawberrysetup*.exe" goto strawberry


@goto end



:boost

@echo Installing boost

cd "%BUILD_PATH%"
if not exist "boost_1_79_0" tar -xvf "%DOWNLOADS_PATH%\boost_1_79_0.tar.gz" || goto end
if not exist "%PREFIX_PATH%\include\boost" mkdir "%PREFIX_PATH%\include\boost"
xcopy /s /y /h "boost_1_79_0\boost" "%PREFIX_PATH%\include\boost\" || goto end

@goto continue


:pkgconf

@echo Compiling pkgconf

cd "%BUILD_PATH%"

if not exist "pkgconf-pkgconf-1.8.0" tar -xvf "%DOWNLOADS_PATH%\pkgconf-1.8.0.tar.gz" || goto end
cd "pkgconf-pkgconf-1.8.0" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% -Dtests=false build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end
copy /y "%PREFIX_PATH%\bin\pkgconf.exe" "%PREFIX_PATH%\bin\pkg-config.exe" || goto end

@goto continue



:zlib

@echo Compiling zlib

cd "%BUILD_PATH%" || goto end
if not exist "zlib-1.2.12" tar -xvf "%DOWNLOADS_PATH%\zlib-1.2.12.tar.gz" || goto end
cd "zlib-1.2.12" || goto end
if not exist build mkdir build
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" || goto end
cmake --build . || goto end
cmake --install . || goto end

@if "%BUILD_TYPE%" == "release" copy /y "%PREFIX_PATH%\lib\zlib.lib" "%PREFIX_PATH%\lib\z.lib" || goto end
@if "%BUILD_TYPE%" == "debug" copy /y "%PREFIX_PATH%\lib\zlibd.lib" "%PREFIX_PATH%\lib\z.lib" || goto end

@goto continue


:openssl

@echo Compiling openssl

cd "%BUILD_PATH%" || goto end
if not exist "openssl-3.0.5" tar -xvf "%DOWNLOADS_PATH%\openssl-3.0.5.tar.gz" || goto end
cd openssl-3.0.5 || goto end
if "%BUILD_TYPE%" == "debug" perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix=%PREFIX_PATH% --libdir=lib --openssldir=%PREFIX_PATH%\ssl --debug --with-zlib-include=%PREFIX_PATH%\include --with-zlib-lib=%PREFIX_PATH%\lib\zlibd.lib || goto end
if "%BUILD_TYPE%" == "release" perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix="%PREFIX_PATH%" --libdir=lib --openssldir="%PREFIX_PATH%\ssl" --release --with-zlib-include="%PREFIX_PATH%\include" --with-zlib-lib="%PREFIX_PATH%\lib\zlib.lib" || goto end
nmake || goto end
nmake install_sw || goto end

@goto continue


:gnutls

@echo Installing gnutls

cd "%BUILD_PATH%" || goto end
if not exist gnutls mkdir gnutls || goto end
cd gnutls || goto end
7z x -aoa "%DOWNLOADS_PATH%\libgnutls_3.7.5_msvc17.zip" || goto end
xcopy /s /y "bin\x64\*.*" "%PREFIX_PATH%\bin\" || goto end
xcopy /s /y "lib\x64\*.*" "%PREFIX_PATH%\lib\" || goto end
if not exist "%PREFIX_PATH%\include\gnutls" mkdir "%PREFIX_PATH%\include\gnutls" || goto end
xcopy /s /y "include\gnutls\*.h" "%PREFIX_PATH%\include\gnutls\" || goto end

@echo prefix=%PREFIX_PATH_FORWARD% > "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD% >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo. >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Name: gnutls >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Description: gnutls >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo URL: https://www.gnutls.org/ >> %PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Version: 3.7.3 >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Libs: -L%PREFIX_PATH_FORWARD%/lib -lgnutls >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Cflags: -I%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"

@goto continue


:libpng

@echo Compiling libpng

cd "%BUILD_PATH%"
if not exist "libpng-1.6.37" tar -xvf "%DOWNLOADS_PATH%\libpng-1.6.37.tar.gz" || goto end
cd "libpng-1.6.37" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/libpng-msvc.patch"
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" || goto end
cmake --build . || goto end
cmake --install . || goto end
@if "%BUILD_TYPE%" == "debug" copy /y "%PREFIX_PATH%\lib\libpng16d.lib" "%PREFIX_PATH%\lib\png16.lib" || goto end

@goto continue


:bzip2

@echo Compiling bzip2

cd "%BUILD_PATH%"
if not exist "bzip2-1.0.8" tar -xvf "%DOWNLOADS_PATH%\bzip2-1.0.8.tar.gz" || goto end
cd bzip2-1.0.8 || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/bzip2-cmake.patch"
if not exist build2 mkdir build2 || goto end
cd build2 || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:xz

@echo Compiling xz

cd "%BUILD_PATH%"
if not exist "xz-5.2.5" tar -xvf "%DOWNLOADS_PATH%\xz-5.2.5.tar.bz2" || goto end
cd xz-5.2.5\windows\vs2019 || goto end
start /w devenv.exe xz_win.sln /upgrade
msbuild xz_win.sln /property:Configuration=%BUILD_TYPE% || goto end
copy /y "%BUILD_TYPE%\x64\liblzma_dll\*.lib" "%PREFIX_PATH%\lib\" || goto end
copy /y "%BUILD_TYPE%\x64\liblzma_dll\*.dll" "%PREFIX_PATH%\bin\" || goto end
copy /y "..\..\src\liblzma\api\*.h" "%PREFIX_PATH%\include\" || goto end
if not exist "%PREFIX_PATH%\include\lzma" mkdir "%PREFIX_PATH%\include\lzma" || goto end
copy /y "..\..\src\liblzma\api\lzma\*.*" "%PREFIX_PATH%\include\lzma\" || goto end

@goto continue


:brotli

@echo Compiling brotli

cd "%BUILD_PATH%"
if not exist "brotli-1.0.9" tar -xvf "%DOWNLOADS_PATH%\v1.0.9.tar.gz" || goto end
cd "brotli-1.0.9" || goto end
if not exist build2 mkdir build2 || goto end
cd build2 || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_TESTING=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:pcre2

@echo Compiling pcre2

cd "%BUILD_PATH%"
if not exist "pcre2-10.40" tar -xvf "%DOWNLOADS_PATH%\pcre2-10.40.tar.bz2" || goto end
cd "pcre2-10.40" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DPCRE2_BUILD_PCRE2_16=ON -DPCRE2_BUILD_PCRE2_32=ON -DPCRE2_BUILD_PCRE2_8=ON -DPCRE2_BUILD_TESTS=OFF -DPCRE2_SUPPORT_UNICODE=ON || goto end
cmake --build . || goto end
cmake --install . || goto end

@if "%BUILD_TYPE%" == "debug" copy /y "%PREFIX_PATH%\lib\pcre2-8d.lib" "%PREFIX_PATH%\lib\pcre2-8.lib" || goto end

@goto continue


:libiconv

@echo Compiling libiconv

cd "%BUILD_PATH%"
if not exist "libiconv-for-Windows" @(
  mkdir libiconv-for-Windows || goto end
  cd libiconv-for-Windows || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\libiconv-for-Windows" . || goto end
  cd ..
) || goto end
cd libiconv-for-Windows || goto end
msbuild libiconv.sln /property:Configuration=%BUILD_TYPE% || goto end
copy /y "lib64\*.lib" "%PREFIX_PATH%\lib\" || goto end
copy /y "lib64\*.dll" "%PREFIX_PATH%\bin\" || goto end
copy /y "include\*.h" "%PREFIX_PATH%\include\" || goto end

@goto continue


:pixman

@echo Compiling pixman

cd "%BUILD_PATH%"
if not exist "pixman-0.40.0" tar -xvf "%DOWNLOADS_PATH%\pixman-0.40.0.tar.gz" || goto end
cd "pixman-0.40.0" || goto end
if not exist "build\build.ninja" meson --buildtype=%BUILD_TYPE% --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig -Dgtk=disabled -Dlibpng=enabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:libxml2

@echo Compiling libxml2

cd "%BUILD_PATH%"
if not exist "libxml2-v2.9.14" tar -xvf "%DOWNLOADS_PATH%\libxml2-v2.9.14.tar.bz2"
cd "libxml2-v2.9.14" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DLIBXML2_WITH_PYTHON=OFF -DLIBXML2_WITH_ZLIB=ON || goto end
cmake --build . || goto end
cmake --install . || goto end
@if "%BUILD_TYPE%" == "debug" copy /y "%PREFIX_PATH%\lib\libxml2d.lib" "%PREFIX_PATH%/lib/libxml2.lib"

@goto continue


:nghttp2

@echo Compiling nghttp2

cd "%BUILD_PATH%"
if not exist "nghttp2-1.48.0" tar -xvf "%DOWNLOADS_PATH%\nghttp2-1.48.0.tar.bz2" || goto end
cd "nghttp2-1.48.0" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DENABLE_SHARED_LIB=ON || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:sqlite

@echo Compiling sqlite

cd "%BUILD_PATH%"
if not exist "sqlite-autoconf-3390000" tar -xvf "%DOWNLOADS_PATH%\sqlite-autoconf-3390000.tar.gz" || goto end
cd "sqlite-autoconf-3390000" || goto end
cl -DSQLITE_API="__declspec(dllexport)" -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_COLUMN_METADATA sqlite3.c -link -dll -out:sqlite3.dll || goto end
cl shell.c sqlite3.c -Fe:sqlite3.exe || goto end
copy /y "*.h" "%PREFIX_PATH%\include\" || goto end
copy /y "*.lib" "%PREFIX_PATH%\lib\" || goto end
copy /y "*.dll" "%PREFIX_PATH%\bin\" || goto end
copy /y "*.exe" "%PREFIX_PATH%\bin\" || goto end

echo prefix=%PREFIX_PATH_FORWARD% > "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo exec_prefix=%PREFIX_PATH_FORWARD% >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo libdir=%PREFIX_PATH_FORWARD%/lib >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo includedir=%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Name: SQLite >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Description: SQL database engine >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo URL: https://www.sqlite.org/ >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Version: 3.38.1 >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Libs: -L%PREFIX_PATH_FORWARD%/lib -lsqlite3 >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Libs.private: -lz -ldl >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Cflags: -I%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"

@goto continue


:libogg

@echo Compiling libogg

cd "%BUILD_PATH%"
if not exist "libogg-1.3.5" tar -xvf "%DOWNLOADS_PATH%\libogg-1.3.5.tar.gz" || goto end
cd "libogg-1.3.5" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DINSTALL_DOCS=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:libvorbis

@echo Compiling libvorbis

cd "%BUILD_PATH%"
if not exist "libvorbis-1.3.7" tar -xvf "%DOWNLOADS_PATH%\libvorbis-1.3.7.tar.gz" || goto end
cd "libvorbis-1.3.7" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DINSTALL_DOCS=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:flac

@echo Compiling flac

cd "%BUILD_PATH%"
if not exist "flac-1.3.4" 7z x "%DOWNLOADS_PATH%\flac-1.3.4.tar.xz" -so | 7z x -aoa -si"flac-1.3.4.tar" || goto end
cd "flac-1.3.4" || goto end
if not exist build2 mkdir build2 || goto end
cd build2 || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DBUILD_DOCS=OFF -DBUILD_EXAMPLES=OFF -DINSTALL_MANPAGES=OFF -DBUILD_TESTING=OFF -DBUILD_PROGRAMS=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:wavpack

@echo Compiling wavpack

cd "%BUILD_PATH%"
if not exist "wavpack-5.4.0" tar -xvf "%DOWNLOADS_PATH%\wavpack-5.4.0.tar.bz2" || goto end
cd "wavpack-5.4.0" || goto end
if not exist build mkdir build || goto end
cd build || goto end
if not exist wavpackdll mkdir wavpackdll
echo. > wavpackdll/wavpackdll.rc || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF -DWAVPACK_BUILD_DOCS=OFF -DWAVPACK_BUILD_PROGRAMS=OFF -DWAVPACK_ENABLE_ASM=OFF -DWAVPACK_ENABLE_LEGACY=OFF -DWAVPACK_BUILD_WINAMP_PLUGIN=OFF -DWAVPACK_BUILD_COOLEDIT_PLUGIN=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end
if not exist "%PREFIX_PATH%\include\wavpack" mkdir "%PREFIX_PATH%\include\wavpack" || goto end
copy /y "%PREFIX_PATH%\include\wavpack.h" "%PREFIX_PATH%\include\wavpack\" || goto end
copy /y "%PREFIX_PATH%\lib\wavpackdll.lib" "%PREFIX_PATH%\lib\wavpack.lib" || goto end
copy /y "%PREFIX_PATH%\bin\wavpackdll.dll" "%PREFIX_PATH%\bin\wavpack.dll" || goto end


@goto continue


:opus

@echo Compiling opus

cd "%BUILD_PATH%"
if not exist "opus-1.3.1" tar -xvf "%DOWNLOADS_PATH%\opus-1.3.1.tar.gz" || goto end
cd opus-1.3.1 || goto end
findstr /v /c:"include(opus_buildtype.cmake)" CMakeLists.txt > CMakeLists.txt.new || goto end
del CMakeLists.txt
ren CMakeLists.txt.new CMakeLists.txt || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:opusfile

@echo Compiling opusfile

cd "%BUILD_PATH%"
if not exist "opusfile-0.12" tar -xvf "%DOWNLOADS_PATH%\opusfile-0.12.tar.gz" || goto end
cd "opusfile-0.12" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/opusfile-cmake.patch"
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:speex

@echo Compiling speex

cd "%BUILD_PATH%"
if not exist "speex" @(
  mkdir speex || goto end
  cd speex || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\speex" . || goto end
  cd .. || goto end
) || goto end
cd "speex" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/speex-cmake.patch"
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end
@if "%BUILD_TYPE%" == "debug" (
  copy /y "%PREFIX_PATH%\lib\libspeexd.lib" "%PREFIX_PATH%\lib\libspeex.lib" || goto end
  copy /y "%PREFIX_PATH%\bin\libspeexd.dll" "%PREFIX_PATH%\bin\libspeex.dll" || goto end
)

@goto continue


:mpg123

@echo Compiling mpg123

cd "%BUILD_PATH%"
if not exist "mpg123-1.30.0" tar -xvf "%DOWNLOADS_PATH%\mpg123-1.30.0.tar.bz2" || goto end
cd "mpg123-1.30.0" || goto end
if not exist build2 mkdir build2 || goto end
cd build2 || goto end
cmake ../ports/cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DBUILD_PROGRAMS=OFF -DBUILD_LIBOUT123=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:lame

@echo Compiling lame

cd "%BUILD_PATH%"
if not exist "lame-3.100" tar -xvf "%DOWNLOADS_PATH%\lame-3.100.tar.gz" || goto end
cd "lame-3.100" || goto end
sed -i "s/MACHINE = \/machine:.*/MACHINE = \/machine:Win64/g" Makefile.MSVC || goto end
nmake -f Makefile.MSVC MSVCVER=Win64 libmp3lame.dll || goto end
copy include\*.h "%PREFIX_PATH%\include\" || goto end
copy output\libmp3lame*.lib "%PREFIX_PATH%\lib\" || goto end
copy output\libmp3lame*.dll "%PREFIX_PATH%\bin\" || goto end

@echo "Create lame pc file"

@echo prefix=%PREFIX_PATH_FORWARD% > "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD% >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo. >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Name: lame >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Description: encoder that converts audio to the MP3 file format. >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo URL: https://lame.sourceforge.io/ >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Version: 3.100 >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Libs: -L%PREFIX_PATH_FORWARD%/lib -lmp3lame >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Cflags: -I%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"


@goto continue


:twolame

@echo Compiling twolame

cd "%BUILD_PATH%"
if not exist "twolame-0.4.0" tar -xvf "%DOWNLOADS_PATH%\twolame-0.4.0.tar.gz" || goto end
cd "twolame-0.4.0" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/twolame.patch"
cd "win32" || goto end
start /w devenv.exe libtwolame_dll.sln /upgrade || goto end
sed -i "s/Win32/x64/g" libtwolame_dll.sln libtwolame_dll.vcxproj || goto end
sed -i "s/MachineX86/MachineX64/g" libtwolame_dll.sln libtwolame_dll.vcxproj || goto end
msbuild libtwolame_dll.sln /property:Configuration="%BUILD_TYPE%" || goto end
copy /y ..\libtwolame\twolame.h "%PREFIX_PATH%\include\" || goto end
copy /y lib\*.lib "%PREFIX_PATH%\lib\" || goto end
copy /y lib\*.dll "%PREFIX_PATH%\bin\" || goto end

@echo "Create twolame pc file"

@echo prefix=%PREFIX_PATH_FORWARD% > "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD% >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo. >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Name: lame >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Description: optimised MPEG Audio Layer 2 (MP2) encoder based on tooLAME >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo URL: https://www.twolame.org/ >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Version: 0.4.0 >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Libs: -L%PREFIX_PATH_FORWARD%/lib -ltwolame_dll >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Cflags: -I%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"

@goto continue


:taglib

@echo Compiling taglib

cd "%BUILD_PATH%"
if not exist "taglib-1.12" tar -xvf "%DOWNLOADS_PATH%\taglib-1.12.tar.gz" || goto end
cd "taglib-1.12" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:dlfcn-win32

@echo Compiling dlfcn-win32

cd "%BUILD_PATH%"
if not exist "dlfcn-win32-1.3.0" tar -xvf "%DOWNLOADS_PATH%\v1.3.0.tar.gz" || goto end
cd "dlfcn-win32-1.3.0" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:fftw3

@echo Compiling fftw3

cd "%BUILD_PATH%"

@REM if not exist "fftw-3.3.10" tar -xvf "%DOWNLOADS_PATH%\fftw-3.3.10.tar.gz" || goto end
@REM cd "fftw-3.3.10" || goto end
@REM if not exist build mkdir build || goto end
@REM cd build || goto end
@REM cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF -DENABLE_AVX=ON -DENABLE_AVX2=ON -DENABLE_SSE=ON -DENABLE_SSE2=ON -DENABLE_THREADS=ON -DWITH_COMBINED_THREADS=ON || goto end
@REM cmake --build . || goto end
@REM cmake --install . || goto end

if not exist "fftw" @(
  mkdir fftw || goto end
  cd fftw || goto end
  7z x "%DOWNLOADS_PATH%\fftw-3.3.5-dll64.zip" || goto end
  cd ..
) || goto end
cd fftw
lib /def:libfftw3-3.def
xcopy /s /y libfftw3-3.dll "%PREFIX_PATH%\bin\"
xcopy /s /y libfftw3-3.lib "%PREFIX_PATH%\lib\"
xcopy /s /y fftw3.h "%PREFIX_PATH%\include\"

@goto continue


:glib

@echo Compiling glib

@set LDFLAGS="-L%PREFIX_PATH%\lib"

cd "%BUILD_PATH%"
if not exist "glib-2.72.1" 7z x "%DOWNLOADS_PATH%\glib-2.73.2.tar.xz" -so | 7z x -aoa -si"glib-2.73.2.tar"
cd "glib-2.73.2" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% -Dpkg_config_path="%PREFIX_PATH%\lib\pkgconfig" build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:glib-networking

@echo Compiling glib-networking

cd "%BUILD_PATH%"
if not exist "glib-networking-2.72.1" 7z x "%DOWNLOADS_PATH%\glib-networking-2.72.1.tar.xz" -so | 7z x -aoa -si"glib-networking-2.72.1.tar" || goto end
cd "glib-networking-2.72.1" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/glib-networking-tests.patch"
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig -Dgnutls=enabled -Dopenssl=enabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:libpsl

@echo Compiling libpsl

cd "%BUILD_PATH%"
if not exist "libpsl-0.21.1" tar -xvf "%DOWNLOADS_PATH%\libpsl-0.21.1.tar.gz" || goto end
cd "libpsl-0.21.1" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:libsoup

@echo Compiling libsoup

cd "%BUILD_PATH%"
if not exist "libsoup-2.74.2" 7z x "%DOWNLOADS_PATH%\libsoup-2.74.2.tar.xz" -so | 7z x -aoa -si"libsoup-2.74.2.tar" || goto end
cd "libsoup-2.74.2" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig -Dtests=false -Dvapi=disabled -Dgssapi=disabled -Dintrospection=disabled -Dtests=false -Dsysprof=disabled -Dtls_check=false -Dgnome=false -Dgtk_doc=false build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end


@goto continue


:orc

@echo Compiling orc

cd "%BUILD_PATH%"
if not exist "orc-0.4.32" 7z x "%DOWNLOADS_PATH%\orc-0.4.32.tar.xz" -so | 7z x -aoa -si"orc-0.4.32.tar" || goto end
cd "orc-0.4.32" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end


@goto continue


:musepack

@echo Compiling musepack

cd "%BUILD_PATH%"
if not exist "musepack_src_r475" tar -xvf "%DOWNLOADS_PATH%\musepack_src_r475.tar.gz" || goto end
cd "musepack_src_r475" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\musepack-fixes.patch"
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX=%PREFIX_PATH% -DBUILD_SHARED_LIBS=ON -DSHARED=ON || goto end
cmake --build . || goto end
cmake --install . || goto end
copy libmpcdec\*.lib %PREFIX_PATH%\lib\ || goto end
copy libmpcdec\*.dll %PREFIX_PATH%\bin\ || goto end


goto continue


:libopenmpt

@echo Compiling libopenmpt

cd "%BUILD_PATH%"
if not exist "libopenmpt" @(
  mkdir libopenmpt || goto end
  cd libopenmpt || goto end
  7z x "%DOWNLOADS_PATH%\libopenmpt-0.6.4+release.msvc.zip" || goto end
  cd ..
 ) || goto end
cd "libopenmpt" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\libopenmpt-cmake.patch"
if not exist build2 mkdir build2 || goto end
cd build2 || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX=%PREFIX_PATH% -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end

goto continue


:fdk-aac

@echo Compiling fdk-aac

cd "%BUILD_PATH%"
if not exist "fdk-aac-2.0.2" tar -xvf "%DOWNLOADS_PATH%\fdk-aac-2.0.2.tar.gz" || goto end
cd "fdk-aac-2.0.2" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX=%PREFIX_PATH% -DBUILD_SHARED_LIBS=ON -DBUILD_PROGRAMS=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:faad2

@echo Compiling faad2

cd "%BUILD_PATH%"
if not exist "faad2" @(
  mkdir "faad2" || goto end
  cd "faad2" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\faad2" . || goto end
  cd ..
 ) || goto end
cd "faad2" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\faad2-cmake.patch"
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX=%PREFIX_PATH% -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end
copy /y "..\include\*.h" "%PREFIX_PATH%\include\" || goto end


@goto continue


:faac

@echo Compiling faac

cd "%BUILD_PATH%"
if not exist "faac" @(
  mkdir "faac" || goto end
  cd "faac" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\faac" . || goto end
  cd ..
 ) || goto end
cd faac
patch -p1 -N < "%DOWNLOADS_PATH%\faac-msvc.patch"
cd project\msvc || goto end
start /w devenv.exe faac.sln /upgrade
msbuild faac.sln /property:Configuration=%BUILD_TYPE% || goto end
copy /y "..\..\include\*.h" "%PREFIX_PATH%\include\" || goto end
copy /y "bin\%BUILD_TYPE%\libfaac_dll.lib" "%PREFIX_PATH%\lib\libfaac.lib" || goto end
copy /y "bin\%BUILD_TYPE%\*.dll" "%PREFIX_PATH%\bin\" || goto end


@goto continue


:libbs2b

@echo Compiling libbs2b

cd "%BUILD_PATH%"
if not exist "libbs2b-3.1.0" tar -xvf "%DOWNLOADS_PATH%\libbs2b-3.1.0.tar.bz2" || goto end
cd "libbs2b-3.1.0" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\libbs2b-msvc.patch"
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX=%PREFIX_PATH% -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:ffmpeg

@echo Compiling ffmpeg

cd "%BUILD_PATH%"
if not exist "ffmpeg" @(
  mkdir "ffmpeg" || goto end
  cd "ffmpeg" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\ffmpeg" . || goto end
  cd ..
 ) || goto end
cd ffmpeg || goto end
@rem --buildtype="%BUILD_TYPE%"
if not exist "build\build.ninja" meson --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig -Dtests=disabled -Dgpl=enabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end


@goto continue


:chromaprint

@echo Compiling chromaprint

cd "%BUILD_PATH%"
if not exist "chromaprint-1.5.1" tar -xvf "%DOWNLOADS_PATH%\chromaprint-1.5.1.tar.gz"
cd "chromaprint-1.5.1" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DBUILD_SHARED_LIBS=ON -DFFMPEG_ROOT="%PREFIX_PATH%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" || goto end
nmake || goto end
cmake --install . || goto end

@goto continue


:gstreamer

@echo Compiling GStreamer

cd "%BUILD_PATH%"
if not exist "gstreamer-1.20.3" 7z x "%DOWNLOADS_PATH%\gstreamer-1.20.3.tar.xz" -so | 7z x -aoa -si"gstreamer-1.20.3.tar" || goto end
cd "gstreamer-1.20.3" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

goto continue


:gst-plugins-base

@echo Compiling gst-plugins-base

cd "%BUILD_PATH%"
if not exist "gst-plugins-base-1.20.3" 7z x "%DOWNLOADS_PATH%\gst-plugins-base-1.20.3.tar.xz" -so | 7z x -aoa -si"gst-plugins-base-1.20.3.tar" || goto end
cd "gst-plugins-base-1.20.3" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig -Dexamples=disabled -Dtests=disabled -Dtools=enabled -Ddoc=disabled -Dorc=enabled -Dadder=enabled -Dapp=enabled -Daudioconvert=enabled -Daudiomixer=enabled -Daudiorate=enabled -Daudioresample=enabled -Daudiotestsrc=enabled -Dcompositor=disabled -Dencoding=disabled -Dgio=enabled -Dgio-typefinder=enabled -Doverlaycomposition=disabled -Dpbtypes=enabled -Dplayback=enabled -Drawparse=disabled -Dsubparse=disabled -Dtcp=enabled -Dtypefind=enabled -Dvideoconvert=disabled -Dvideorate=disabled -Dvideoscale=disabled -Dvideotestsrc=disabled -Dvolume=enabled -Dalsa=disabled -Dcdparanoia=disabled -Dlibvisual=disabled -Dogg=enabled -Dopus=enabled -Dpango=disabled -Dtheora=disabled -Dtremor=disabled -Dvorbis=enabled -Dx11=disabled -Dxshm=disabled -Dxvideo=disabled -Dgl=disabled -Dgl-graphene=disabled -Dgl-jpeg=disabled -Dgl-png=disabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:gst-plugins-good

@echo Compiling gst-plugins-good

cd "%BUILD_PATH%"
if not exist "gst-plugins-good-1.20.3" 7z x "%DOWNLOADS_PATH%\gst-plugins-good-1.20.3.tar.xz" -so | 7z x -aoa -si"gst-plugins-good-1.20.3.tar" || goto end
cd "gst-plugins-good-1.20.3" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig -Dexamples=disabled -Dtests=disabled -Ddoc=disabled -Dorc=enabled -Dalpha=disabled -Dapetag=enabled -Daudiofx=enabled -Daudioparsers=enabled -Dauparse=disabled -Dautodetect=enabled -Davi=disabled -Dcutter=disabled -Ddebugutils=disabled -Ddeinterlace=disabled -Ddtmf=disabled -Deffectv=disabled -Dequalizer=enabled -Dflv=disabled -Dflx=disabled -Dgoom=disabled -Dgoom2k1=disabled -Dicydemux=enabled -Did3demux=enabled -Dimagefreeze=disabled -Dinterleave=disabled -Disomp4=enabled -Dlaw=disabled -Dlevel=disabled -Dmatroska=disabled -Dmonoscope=disabled -Dmultifile=disabled -Dmultipart=disabled -Dreplaygain=enabled -Drtp=enabled -Drtpmanager=disabled -Drtsp=enabled -Dshapewipe=disabled -Dsmpte=disabled -Dspectrum=enabled -Dudp=enabled -Dvideobox=disabled -Dvideocrop=disabled -Dvideofilter=disabled -Dvideomixer=disabled -Dwavenc=enabled -Dwavparse=enabled -Dy4m=disabled -Daalib=disabled -Dbz2=disabled -Dcairo=disabled -Ddirectsound=enabled -Ddv=disabled -Ddv1394=disabled -Dflac=enabled -Dgdk-pixbuf=disabled -Dgtk3=disabled -Djack=disabled -Djpeg=disabled -Dlame=enabled -Dlibcaca=disabled -Dmpg123=enabled -Doss=disabled -Doss4=disabled -Dosxaudio=disabled -Dosxvideo=disabled -Dpng=disabled -Dpulse=disabled -Dqt5=disabled -Dshout2=disabled -Dsoup=enabled -Dspeex=enabled -Dtaglib=enabled -Dtwolame=enabled -Dvpx=disabled -Dwaveform=enabled -Dwavpack=enabled -Dximagesrc=disabled -Dv4l2=disabled -Dv4l2-libv4l2=disabled -Dv4l2-gudev=disabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:gst-plugins-bad

@echo Compiling gst-plugins-bad

cd "%BUILD_PATH%"
if not exist "gst-plugins-bad-1.20.3" 7z x "%DOWNLOADS_PATH%\gst-plugins-bad-1.20.3.tar.xz" -so | 7z x -aoa -si"gst-plugins-bad-1.20.3.tar" || goto end
cd "gst-plugins-bad-1.20.3" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\gst-plugins-bad-libpaths.patch"
sed -i "s/c:\\msvc_x86_64\\lib/c:\\strawberry_msvc_x86_64_debug\\lib/g" ext\faad\meson.build || goto end
sed -i "s/c:\\msvc_x86_64\\lib/c:\\strawberry_msvc_x86_64_debug\\lib/g" ext\faac\meson.build || goto end
sed -i "s/c:\\msvc_x86_64\\lib/c:\\strawberry_msvc_x86_64_debug\\lib/g" ext\musepack\meson.build || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig  -Dexamples=disabled -Dtests=disabled -Dexamples=disabled -Dgpl=enabled -Dorc=enabled -Daccurip=disabled -Dadpcmdec=disabled -Dadpcmenc=disabled -Daiff=enabled -Dasfmux=enabled -Daudiobuffersplit=disabled -Daudiofxbad=disabled -Daudiolatency=disabled -Daudiomixmatrix=disabled -Daudiovisualizers=disabled -Dautoconvert=disabled -Dbayer=disabled -Dcamerabin2=disabled -Dcodecalpha=disabled -Dcoloreffects=disabled -Ddebugutils=disabled -Ddvbsubenc=disabled -Ddvbsuboverlay=disabled -Ddvdspu=disabled -Dfaceoverlay=disabled -Dfestival=disabled -Dfieldanalysis=disabled -Dfreeverb=disabled -Dfrei0r=disabled -Dgaudieffects=disabled -Dgdp=disabled -Dgeometrictransform=disabled -Did3tag=enabled -Dinter=disabled -Dinterlace=disabled -Divfparse=disabled -Divtc=disabled -Djp2kdecimator=disabled -Djpegformat=disabled -Dlibrfb=disabled -Dmidi=disabled -Dmpegdemux=disabled -Dmpegpsmux=disabled -Dmpegtsdemux=disabled -Dmpegtsmux=disabled -Dmxf=disabled -Dnetsim=disabled -Donvif=disabled -Dpcapparse=disabled -Dpnm=disabled -Dproxy=disabled -Dqroverlay=disabled -Drawparse=disabled -Dremovesilence=enabled -Drist=disabled -Drtmp2=disabled -Drtp=disabled -Dsdp=disabled -Dsegmentclip=disabled -Dsiren=disabled -Dsmooth=disabled -Dspeed=disabled -Dsubenc=disabled -Dswitchbin=disabled -Dtimecode=disabled -Dvideofilters=disabled -Dvideoframe_audiolevel=disabled -Dvideoparsers=disabled -Dvideosignal=disabled -Dvmnc=disabled -Dy4m=disabled -Dopencv=disabled -Dwayland=disabled -Dx11=disabled -Daes=enabled -Daom=disabled -Davtp=disabled -Dandroidmedia=disabled -Dapplemedia=disabled -Dasio=disabled -Dassrender=disabled -Dbluez=enabled -Dbs2b=enabled -Dbz2=disabled -Dchromaprint=enabled -Dclosedcaption=disabled -Dcolormanagement=disabled -Dcurl=disabled -Dcurl-ssh2=disabled -Dd3dvideosink=disabled -Dd3d11=disabled -Ddash=enabled -Ddc1394=disabled -Ddecklink=disabled -Ddirectfb=disabled -Ddirectsound=enabled -Ddtls=disabled -Ddts=disabled -Ddvb=disabled -Dfaac=enabled -Dfaad=enabled -Dfbdev=disabled -Dfdkaac=enabled -Dflite=disabled -Dfluidsynth=disabled -Dgl=disabled -Dgme=disabled -Dgs=disabled -Dgsm=disabled -Dipcpipeline=disabled -Diqa=disabled -Dkate=disabled -Dkms=disabled -Dladspa=disabled -Dldac=disabled -Dlibde265=disabled -Dopenaptx=disabled -Dlv2=disabled -Dmediafoundation=disabled -Dmicrodns=disabled -Dmodplug=disabled -Dmpeg2enc=disabled -Dmplex=disabled -Dmsdk=disabled -Dmusepack=enabled -Dneon=disabled -Dnvcodec=disabled -Donnx=disabled -Dopenal=disabled -Dopenexr=disabled -Dopenh264=disabled -Dopenjpeg=disabled -Dopenmpt=enabled -Dopenni2=disabled -Dopensles=disabled -Dopus=enabled -Dresindvd=disabled -Drsvg=disabled -Drtmp=disabled -Dsbc=disabled -Dsctp=disabled -Dshm=disabled -Dsmoothstreaming=disabled -Dsndfile=disabled -Dsoundtouch=disabled -Dspandsp=disabled -Dsrt=disabled -Dsrtp=disabled -Dsvthevcenc=disabled -Dteletext=disabled -Dtinyalsa=disabled -Dtranscode=disabled -Dttml=disabled -Duvch264=disabled -Dva=disabled -Dvoaacenc=disabled -Dvoamrwbenc=disabled -Dvulkan=disabled -Dwasapi=enabled -Dwasapi2=enabled -Dwebp=disabled -Dwebrtc=disabled -Dwebrtcdsp=disabled -Dwildmidi=disabled -Dwinks=disabled -Dwinscreencap=disabled -Dx265=disabled -Dzbar=disabled -Dzxing=disabled -Dwpe=disabled -Dmagicleap=disabled -Dv4l2codecs=disabled -Disac=disabled -Dhls=enabled -Dhls-crypto=openssl build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:gst-plugins-ugly

@echo Compiling gst-plugins-ugly

cd "%BUILD_PATH%"
if not exist "gst-plugins-ugly-1.20.3" 7z x "%DOWNLOADS_PATH%\gst-plugins-ugly-1.20.3.tar.xz" -so | 7z x -aoa -si"gst-plugins-ugly-1.20.3.tar" || goto end
cd "gst-plugins-ugly-1.20.3" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig -Dtests=disabled -Ddoc=disabled -Dgpl=enabled -Dorc=enabled -Dasfdemux=enabled -Ddvdlpcmdec=disabled -Ddvdsub=disabled -Drealmedia=disabled -Dxingmux=enabled -Da52dec=disabled -Damrnb=disabled -Damrwbdec=disabled -Dcdio=disabled -Ddvdread=disabled -Dmpeg2dec=disabled -Dsidplay=disabled -Dx264=disabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:gst-libav

@echo Compiling gst-libav

cd "%BUILD_PATH%"
if not exist "gst-libav-1.20.3" 7z x "%DOWNLOADS_PATH%\gst-libav-1.20.3.tar.xz" -so | 7z x -aoa -si"gst-libav-1.20.3.tar" || goto end
cd "gst-libav-1.20.3" || goto end
if not exist "build\build.ninja" meson --buildtype="%BUILD_TYPE%" --prefix=%PREFIX_PATH% --pkg-config-path=%PREFIX_PATH%\lib\pkgconfig -Dtests=disabled -Ddoc=disabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:protobuf

@echo Compiling protobuf

cd "%BUILD_PATH%"
if not exist "protobuf-3.21.2" tar -xvf "%DOWNLOADS_PATH%\protobuf-cpp-3.21.2.tar.gz" || goto end
cd "protobuf-3.21.2\cmake" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -Dprotobuf_BUILD_SHARED_LIBS=ON -Dprotobuf_BUILD_TESTS=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end
copy /y "protobuf.pc" "%PREFIX_PATH%\lib\pkgconfig\" || goto end

@goto continue


:expat

@echo Compiling expat

cd "%BUILD_PATH%"
if not exist "expat-2.4.8" tar -xvf "%DOWNLOADS_PATH%\expat-2.4.8.tar.bz2" || goto end
cd "expat" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DEXPAT_SHARED_LIBS=ON -DEXPAT_BUILD_DOCS=OFF -DEXPAT_BUILD_EXAMPLES=OFF -DEXPAT_BUILD_FUZZERS=OFF -DEXPAT_BUILD_TESTS=OFF -DEXPAT_BUILD_TOOLS=OFF -DEXPAT_BUILD_PKGCONFIG=ON || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:freetype

@echo Compiling freetype

cd "%BUILD_PATH%"
if not exist "freetype-2.12.0" tar -xvf "%DOWNLOADS_PATH%\freetype-2.12.0.tar.bz2" || goto end
cd "freetype-2.12.0" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:harfbuzz

@echo Compiling harfbuzz

cd "%BUILD_PATH%"
if not exist "harfbuzz-4.2.0" tar -xvf "%DOWNLOADS_PATH%\harfbuzz-4.2.0.tar.bz2" || goto end
cd "harfbuzz-4.2.0" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:qtbase

@echo Compiling qtbase

cd "%BUILD_PATH%"
if not exist "qtbase-everywhere-src-6.3.1" 7z x "%DOWNLOADS_PATH%\qtbase-everywhere-src-6.3.1.tar.xz" -so | 7z x -aoa -si"qtbase-everywhere-src-6.3.1.tar" || goto end
cd "qtbase-everywhere-src-6.3.1" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/qtbase-pcre2.patch"
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G Ninja -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON -DPKG_CONFIG_EXECUTABLE="%PREFIX_PATH%\bin\pkgconf.exe" -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_BENCHMARKS=OFF -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF -DQT_BUILD_TOOLS_BY_DEFAULT=ON -DQT_WILL_BUILD_TOOLS=ON -DBUILD_WITH_PCH=OFF -DFEATURE_rpath=OFF -DFEATURE_pkg_config=ON -DFEATURE_accessibility=ON -DFEATURE_fontconfig=OFF -DFEATURE_harfbuzz=ON -DFEATURE_pcre2=ON -DFEATURE_openssl=ON -DFEATURE_openssl_linked=ON -DFEATURE_opengl=ON -DFEATURE_opengl_dynamic=ON -DFEATURE_use_gold_linker_alias=OFF -DFEATURE_glib=ON -DFEATURE_icu=OFF -DFEATURE_directfb=OFF -DFEATURE_dbus=OFF -DFEATURE_sql=ON -DFEATURE_sql_sqlite=ON -DFEATURE_sql_odbc=OFF -DFEATURE_jpeg=ON -DFEATURE_png=ON -DFEATURE_gif=ON -DFEATURE_style_windows=ON -DFEATURE_style_windowsvista=ON -DFEATURE_system_zlib=ON -DFEATURE_system_png=ON -DFEATURE_system_jpeg=OFF -DFEATURE_system_pcre2=ON -DFEATURE_system_harfbuzz=OFF -DFEATURE_system_sqlite=ON || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:qttools

@echo Compiling qttools

cd "%BUILD_PATH%"
if not exist "qttools-everywhere-src-6.3.1" 7z x "%DOWNLOADS_PATH%\qttools-everywhere-src-6.3.1.tar.xz" -so | 7z x -aoa -si"qttools-everywhere-src-6.3.1.tar" || goto end
cd "qttools-everywhere-src-6.3.1" || goto end
if not exist build mkdir build || goto end
cd build || goto end
call %PREFIX_PATH%\bin\qt-configure-module.bat .. || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:qtsparkle

@echo Compiling qtsparkle

cd "%BUILD_PATH%"
if not exist "qtsparkle" @(
  mkdir "qtsparkle" || goto end
  cd "qtsparkle" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\qtsparkle" . || goto end
  cd ..
 ) || goto end
cd "qtsparkle" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/qtsparkle-msvc.patch"
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DBUILD_WITH_QT6=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_PREFIX_PATH="%PREFIX_PATH%\lib\cmake" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" || goto end
cmake --build . || goto end
cmake --install . || goto end

@echo prefix=%PREFIX_PATH_FORWARD% >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD% >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo. >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo Name: qtsparkle-qt6 >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo Version: >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo Description: Qt auto-updater lib >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo Libs: -L%PREFIX_PATH_FORWARD% -lqtsparkle-qt6 >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"
@echo Cflags: -I%PREFIX_PATH_FORWARD% >> "%PREFIX_PATH%/lib/pkgconfig/qtsparkle-qt6.pc"


@goto continue


:strawberry

@echo Compiling strawberry

cd "%BUILD_PATH%"
if not exist "strawberry" @(
  mkdir "strawberry" || goto end
  cd "strawberry" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\strawberry" . || goto end
  cd ..
 ) || goto end
cd "strawberry" || goto end
if not exist build mkdir build || goto end
cd build || goto end
cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DBUILD_WITH_QT6=ON -DCMAKE_PREFIX_PATH="%PREFIX_PATH%\lib\cmake" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DARCH=x86_64 -DENABLE_TRANSLATIONS=OFF || goto end
cmake --build . || goto end
cmake --install . || goto end

if not exist gio-modules mkdir gio-modules || goto end
if not exist platforms mkdir platforms || goto end
if not exist styles mkdir styles || goto end
if not exist tls mkdir tls || goto end
if not exist sqldrivers mkdir sqldrivers || goto end
if not exist imageformats mkdir imageformats || goto end
if not exist gstreamer-plugins mkdir gstreamer-plugins || goto end

copy /y "%PREFIX_PATH%\bin\libssl-3-x64.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libcrypto-3-x64.dll" || goto end
copy /y "%PREFIX_PATH%\bin\soup-2.4-1.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gst-launch-1.0.exe" || goto end
copy /y "%PREFIX_PATH%\bin\gst-discoverer-1.0.exe" || goto end
copy /y "%PREFIX_PATH%\bin\sqlite3.exe" || goto end
copy /y "%PREFIX_PATH%\bin\libcrypto-3-x64.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libssl-3-x64.dll" || goto end
copy /y "%PREFIX_PATH%\bin\brotlicommon.dll" || goto end
copy /y "%PREFIX_PATH%\bin\brotlidec.dll" || goto end
copy /y "%PREFIX_PATH%\bin\chromaprint.dll" || goto end
copy /y "%PREFIX_PATH%\bin\faad.dll" || goto end
copy /y "%PREFIX_PATH%\bin\fdk-aac.dll" || goto end
copy /y "%PREFIX_PATH%\bin\ffi-7.dll" || goto end
copy /y "%PREFIX_PATH%\bin\FLAC.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gio-2.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\glib-2.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gmodule-2.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gnutls.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gobject-2.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstadaptivedemux-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstapp-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstaudio-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstbadaudio-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstbase-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstfft-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstisoff-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstnet-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstpbutils-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstreamer-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstriff-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstrtp-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstrtsp-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstsdp-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gsttag-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gsturidownloader-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstvideo-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\gstwinrt-1.0-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libfftw3-3.dll" || goto end
copy /y "%PREFIX_PATH%\bin\intl-8.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libbs2b.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libfaac_dll.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libiconv.dll" || goto end
copy /y "%PREFIX_PATH%\bin\liblzma.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libmp3lame.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libopenmpt.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libspeex.dll" || goto end
copy /y "%PREFIX_PATH%\bin\mpcdec.dll" || goto end
copy /y "%PREFIX_PATH%\bin\mpg123.dll" || goto end
copy /y "%PREFIX_PATH%\bin\ogg.dll" || goto end
copy /y "%PREFIX_PATH%\bin\opus.dll" || goto end
copy /y "%PREFIX_PATH%\bin\orc-0.4-0.dll" || goto end
copy /y "%PREFIX_PATH%\bin\psl-5.dll" || goto end
copy /y "%PREFIX_PATH%\bin\qtsparkle-qt6.dll" || goto end
copy /y "%PREFIX_PATH%\bin\soup-2.4-1.dll" || goto end
copy /y "%PREFIX_PATH%\bin\sqlite3.dll" || goto end
copy /y "%PREFIX_PATH%\bin\tag.dll" || goto end
copy /y "%PREFIX_PATH%\bin\vorbis.dll" || goto end
copy /y "%PREFIX_PATH%\bin\vorbisfile.dll" || goto end
copy /y "%PREFIX_PATH%\bin\wavpackdll.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libpng16*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libprotobuf*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\libxml2*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\pcre2-8*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\pcre2-16*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\zlib*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\Qt6Concurrent*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\Qt6Core*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\Qt6Gui*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\Qt6Network*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\Qt6Sql*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\Qt6Widgets*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\avcodec*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\avfilter*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\avformat*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\avutil*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\postproc*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\swresample*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\swscale*.dll" || goto end
copy /y "%PREFIX_PATH%\bin\avresample*.dll" || goto end

copy /y "%PREFIX_PATH%\lib\gio\modules\*.dll" ".\gio-modules\" || goto end
copy /y "%PREFIX_PATH%\plugins\platforms\qwindows*.dll" ".\platforms\" || goto end
copy /y "%PREFIX_PATH%\plugins\styles\qwindowsvistastyle*.dll" ".\styles\" || goto end
copy /y "%PREFIX_PATH%\plugins\tls\*.dll" ".\tls\" || goto end
copy /y "%PREFIX_PATH%\plugins\sqldrivers\qsqlite*.dll" ".\sqldrivers\" || goto end
copy /y "%PREFIX_PATH%\plugins\imageformats\*.dll" ".\imageformats\" || goto end

copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaiff.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstapetag.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstapp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstasf.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstasfmux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudioconvert.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudiofx.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudiomixer.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudioparsers.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudiorate.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudioresample.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudiotestsrc.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstautodetect.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstbs2b.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstcoreelements.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstdash.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstdirectsound.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstequalizer.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstfaac.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstfaad.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstfdkaac.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstflac.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstgio.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsthls.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsticydemux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstid3demux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstisomp4.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstlame.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstmpg123.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstmusepack.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstogg.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstopenmpt.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstopus.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstopusparse.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstplayback.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstremovesilence.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstreplaygain.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstrtp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstrtsp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstspeex.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstsoup.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstspectrum.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsttcp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsttypefindfunctions.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstudp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstvolume.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstvorbis.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwasapi.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwasapi2.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwavpack.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwavparse.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstxingmux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstlibav.dll" ".\gstreamer-plugins\" || goto end

copy /y "..\COPYING" . || goto end
copy /y "..\dist\windows\*.nsi" . || goto end
copy /y "..\dist\windows\*.nsh" . || goto end
copy /y "..\dist\windows\*.ico" . || goto end

makensis "strawberry.nsi" || goto end


@goto continue


:end

@endlocal
