@echo on

@setlocal

@set BUILD_TYPE=%1%
@if "%BUILD_TYPE%" == "" set BUILD_TYPE=debug

@if /I "%BUILD_TYPE%" == "debug" set CMAKE_BUILD_TYPE=Debug
@if /I "%BUILD_TYPE%" == "debug" set MESON_BUILD_TYPE=debug

@if /I "%BUILD_TYPE%" == "release" set CMAKE_BUILD_TYPE=Release
@if /I "%BUILD_TYPE%" == "release" set MESON_BUILD_TYPE=release

@if /I "%BUILD_TYPE%" == "debug" set LIB_POSTFIX=d

@set DOWNLOADS_PATH=c:\data\projects\strawberry\msvc_\downloads
@set BUILD_PATH=c:\data\projects\strawberry\msvc_\build_%BUILD_TYPE%
@set PREFIX_PATH=c:\strawberry_msvc_x86_64_%BUILD_TYPE%
@set PREFIX_PATH_FORWARD=%PREFIX_PATH:\=/%
@set PREFIX_PATH_ESCAPE=%PREFIX_PATH:\=\\%
@set QT_DEV=OFF
@set GST_DEV=OFF

@rem @set CMAKE_GENERATOR=NMake Makefiles
@rem @set CMAKE_GENERATOR=Visual Studio 17 2022
@set CMAKE_GENERATOR=Ninja

@call versions.bat

@echo Strawberry MSVC dependencies build script
@echo.
@echo Downloads path: %DOWNLOADS_PATH%
@echo Build path: %BUILD_PATH%
@echo Build type: %BUILD_TYPE%
@echo CMake Build type: %CMAKE_BUILD_TYPE%
@echo Meson Build type: %MESON_BUILD_TYPE%
@echo Prefix path: %PREFIX_PATH%
@echo Prefix path forward: %PREFIX_PATH_FORWARD%
@echo Prefix path escape: %PREFIX_PATH_ESCAPE%
@echo.


:create_directories

@echo Creating directories

@if not exist "%DOWNLOADS_PATH%" MKDIR "%DOWNLOADS_PATH%" || goto end
@if not exist "%BUILD_PATH%" MKDIR "%BUILD_PATH%" || goto end
@if not exist "%PREFIX_PATH%" MKDIR "%PREFIX_PATH%" || goto end
@if not exist "%PREFIX_PATH%\bin" MKDIR "%PREFIX_PATH%\bin" || goto end
@if not exist "%PREFIX_PATH%\lib" MKDIR "%PREFIX_PATH%\lib" || goto end
@if not exist "%PREFIX_PATH%\include" MKDIR "%PREFIX_PATH%\include" || goto end


:install

@if not exist "%PREFIX_PATH%\bin\sed.exe" goto sed

goto setup

:sed

copy /y "%DOWNLOADS_PATH%\sed.exe" "%PREFIX_PATH%\bin\" || goto end

@goto install


:setup

@echo Setting environment variables

@set PKG_CONFIG_EXECUTABLE=%PREFIX_PATH%\bin\pkgconf.exe
@set PKG_CONFIG_PATH=%PREFIX_PATH%\lib\pkgconfig

@set CL=-MP

@set PATH=%PREFIX_PATH%\bin;%PATH%

@rem @set YASMPATH=%PREFIX_PATH%\bin\
@set YASMPATH=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\

@goto check


:check

echo Checking requirements...

@patch --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Git\usr\bin
@patch --version >NUL 2>&1 || (
  @echo "Missing patch."
  @goto end
)

@sed --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Git\usr\bin
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
  @echo "Missing nmake. Install Visual Studio 2022"
  @goto end
)


goto continue


:continue


@if not exist "%PREFIX_PATH%\bin\yasm.exe" goto yasm
@if not exist "%PREFIX_PATH%\bin\pkgconf.exe" goto pkgconf
@rem @if not exist "%PREFIX_PATH%\lib\pkgconfig\mimalloc.pc" goto mimalloc
@if not exist "%PREFIX_PATH%\lib\getopt.lib" goto getopt-win
@if not exist "%PREFIX_PATH%\lib\pkgconfig\zlib.pc" goto zlib
@if not exist "%PREFIX_PATH%\lib\pkgconfig\openssl.pc" goto openssl
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gmp.pc" goto gmp
@if not exist "%PREFIX_PATH%\lib\pkgconfig\nettle.pc" goto nettle
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc" goto gnutls
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libpng.pc" goto libpng
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libjpeg.pc" goto libjpeg
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libpcre2-16.pc" goto pcre2
@if not exist "%PREFIX_PATH%\lib\pkgconfig\bzip2.pc" goto bzip2
@if not exist "%PREFIX_PATH%\lib\pkgconfig\liblzma.pc" goto xz
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libbrotlicommon.pc" goto brotli
@if not exist "%PREFIX_PATH%\lib\libiconv*.lib" goto libiconv
@if not exist "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc" goto icu4c
@if not exist "%PREFIX_PATH%\lib\pkgconfig\pixman-1.pc" goto pixman
@if not exist "%PREFIX_PATH%\lib\pkgconfig\expat.pc" goto expat
@if not exist "%PREFIX_PATH%\include\boost\config.hpp" goto boost
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libxml-2.0.pc" goto libxml2
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libnghttp2.pc" goto nghttp2
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libffi.pc" goto libffi
@rem @if not exist "%PREFIX_PATH%\lib\intl.lib" goto libintl
@if not exist "%PREFIX_PATH%\include\dlfcn.h" goto dlfcn-win32
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libpsl.pc" goto libpsl
@if not exist "%PREFIX_PATH%\lib\pkgconfig\orc-0.4.pc" goto orc
@rem @if not exist "%PREFIX_PATH%\lib\pkgconfig\libcurl.pc" goto curl
@if not exist "%PREFIX_PATH%\lib\pkgconfig\sqlite3.pc" goto sqlite
@if not exist "%PREFIX_PATH%\lib\pkgconfig\glib-2.0.pc" goto glib
@rem @if not exist "%PREFIX_PATH%\lib\libproxy.lib" goto libproxy
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libsoup-3.0.pc" goto libsoup
@if not exist "%PREFIX_PATH%\lib\gio\modules\gioopenssl.lib" goto glib-networking
@if not exist "%PREFIX_PATH%\lib\pkgconfig\freetype2.pc" goto freetype
@rem @if not exist "%PREFIX_PATH%\lib\pkgconfig\cairo.pc" goto cairo
@if not exist "%PREFIX_PATH%\lib\harfbuzz*.lib" goto harfbuzz
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
@if not exist "%PREFIX_PATH%\lib\pkgconfig\fftw3.pc" goto fftw3
@if not exist "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc" goto musepack
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libopenmpt.pc" goto libopenmpt
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libgme.pc" goto libgme
@if not exist "%PREFIX_PATH%\lib\pkgconfig\fdk-aac.pc" goto fdk-aac
@if not exist "%PREFIX_PATH%\lib\pkgconfig\faad2.pc" goto faad2
@if not exist "%PREFIX_PATH%\lib\pkgconfig\faac.pc" goto faac
@if not exist "%PREFIX_PATH%\include\utf8cpp\utf8.h" goto utfcpp
@if not exist "%PREFIX_PATH%\lib\pkgconfig\taglib.pc" goto taglib
@if not exist "%PREFIX_PATH%\lib\libbs2b.lib" goto libbs2b
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libebur128.pc" goto libebur128
@if not exist "%PREFIX_PATH%\lib\avutil.lib" goto ffmpeg
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libchromaprint.pc" goto chromaprint
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gstreamer-1.0.pc" goto gstreamer
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gstreamer-plugins-base-1.0.pc" goto gst-plugins-base
@if not exist "%PREFIX_PATH%\lib\gstreamer-1.0\gstdirectsound.lib" goto gst-plugins-good
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gstreamer-plugins-bad-1.0.pc" goto gst-plugins-bad
@if not exist "%PREFIX_PATH%\lib\gstreamer-1.0\gstasf.lib" goto gst-plugins-ugly
@if not exist "%PREFIX_PATH%\lib\gstreamer-1.0\gstlibav.lib" goto gst-libav
@if not exist "%PREFIX_PATH%\lib\pkgconfig\gstspotify.pc" goto gst-plugins-rs
@if not exist "%PREFIX_PATH%\lib\pkgconfig\absl_any.pc" goto abseil-cpp
@if not exist "%PREFIX_PATH%\lib\pkgconfig\protobuf.pc" goto protobuf
@if not exist "%PREFIX_PATH%\bin\qt-configure-module.bat" goto qtbase
@if not exist "%PREFIX_PATH%\bin\linguist.exe" goto qttools
@if not exist "%PREFIX_PATH%\lib\pkgconfig\libsparsehash.pc" goto sparsehash
@if not exist "%PREFIX_PATH%\lib\cmake\RapidJSON\RapidJSONConfig.cmake" goto rapidjson
@rem @if not exist "%PREFIX_PATH%\lib\cmake\Qt6\FindWrapProtobuf.cmake" goto qtgrpc
@if not exist "%PREFIX_PATH%\lib\cmake\qtsparkle-qt6\qtsparkle-qt6Config.cmake" goto qtsparkle
@if not exist "%PREFIX_PATH%\lib\kdsingleapplication-qt6.lib" goto kdsingleapplication
@rem @if not exist "%PREFIX_PATH%\lib\pkgconfig\glew.pc" goto glew
@rem @if not exist "%PREFIX_PATH%\lib\cmake\projectM4\projectM4Config.cmake" goto libprojectm
@if not exist "%PREFIX_PATH%\bin\gettext.exe" goto gettext
@if not exist "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc" goto tinysvcmdns
@if not exist "%BUILD_PATH%\strawberry\build\strawberrysetup*.exe" goto strawberry


@goto end


:pkgconf

@echo Building pkgconf

cd "%BUILD_PATH%" || goto end

if not exist "pkgconf-pkgconf-%PKGCONF_VERSION%" tar -xvf "%DOWNLOADS_PATH%\pkgconf-%PKGCONF_VERSION%.tar.gz" || goto end
cd "pkgconf-pkgconf-%PKGCONF_VERSION%" || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --wrap-mode=nodownload -Dtests=disabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end
copy /y "%PREFIX_PATH%\bin\pkgconf.exe" "%PREFIX_PATH%\bin\pkg-config.exe" || goto end

@goto continue


:mimalloc

@echo Building mimalloc

cd "%BUILD_PATH%" || goto end

if not exist "mimalloc-%MIMALLOC_VERSION%" tar -xvf "%DOWNLOADS_PATH%\mimalloc-%MIMALLOC_VERSION%.tar.gz" || goto end
cd "mimalloc-%MIMALLOC_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DMI_BUILD_SHARED=ON -DMI_BUILD_STATIC=OFF -DMI_BUILD_TESTS=OFF -DMI_CHECK_FULL=OFF -DMI_DEBUG_FULL=OFF -DMI_DEBUG_TSAN=OFF -DMI_DEBUG_UBSAN=OFF -DMI_OVERRIDE=ON -DMI_USE_CXX=ON -DMI_WIN_REDIRECT=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
move "%PREFIX_PATH%\lib\mimalloc*.dll" "%PREFIX_PATH%\bin\" || goto end

@goto continue


:yasm

@echo Building yasm

cd "%BUILD_PATH%" || goto end

if not exist "yasm-%YASM_VERSION%" tar -xvf "%DOWNLOADS_PATH%\yasm-%YASM_VERSION%.tar.gz" || goto end
cd "yasm-%YASM_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\yasm-cmake.patch"
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:getopt-win

@echo Building getopt-win

cd "%BUILD_PATH%" || goto end

if not exist "getopt-win-%GETOPT_WIN_VERSION%" tar -xvf %DOWNLOADS_PATH%\getopt-win-%GETOPT_WIN_VERSION%.tar.gz || goto end
cd "getopt-win-%GETOPT_WIN_VERSION%" || goto end
if not exist build mkdir build
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_SHARED_LIB=ON -DBUILD_STATIC_LIBS=OFF -DBUILD_STATIC_LIB=OFF -DBUILD_TESTING=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:zlib

@echo Building zlib

cd "%BUILD_PATH%" || goto end
if not exist "zlib-%ZLIB_VERSION%" tar -xvf "%DOWNLOADS_PATH%\zlib-%ZLIB_VERSION%.tar.gz" || goto end
cd "zlib-%ZLIB_VERSION%" || goto end
if not exist build mkdir build
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

copy "%PREFIX_PATH%\share\pkgconfig\zlib.pc" "%PREFIX_PATH%\lib\pkgconfig\" || goto end
sed -i "s/\-lz/\-lzlib%LIB_POSTFIX%/g" "%PREFIX_PATH%\lib\pkgconfig\zlib.pc" || goto end

@if "%BUILD_TYPE%" == "release" copy /y "%PREFIX_PATH%\lib\zlib.lib" "%PREFIX_PATH%\lib\z.lib" || goto end
@if "%BUILD_TYPE%" == "debug" copy /y "%PREFIX_PATH%\lib\zlibd.lib" "%PREFIX_PATH%\lib\z.lib" || goto end

del %PREFIX_PATH%\lib\zlibstatic*.lib

@goto continue


:openssl

@echo Building openssl

cd "%BUILD_PATH%" || goto end
if not exist "openssl-%OPENSSL_VERSION%" tar -xvf "%DOWNLOADS_PATH%\openssl-%OPENSSL_VERSION%.tar.gz" || goto end
cd openssl-%OPENSSL_VERSION% || goto end
if "%BUILD_TYPE%" == "debug" perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix="%PREFIX_PATH%" --libdir=lib --openssldir=%PREFIX_PATH%\ssl --debug --with-zlib-include=%PREFIX_PATH%\include --with-zlib-lib=%PREFIX_PATH%\lib\zlibd.lib || goto end
if "%BUILD_TYPE%" == "release" perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix="%PREFIX_PATH%" --libdir=lib --openssldir="%PREFIX_PATH%\ssl" --release --with-zlib-include="%PREFIX_PATH%\include" --with-zlib-lib="%PREFIX_PATH%\lib\zlib.lib" || goto end
nmake || goto end
nmake install_sw || goto end

copy %PREFIX_PATH%\lib\libssl.lib %PREFIX_PATH%\lib\ssl.lib
copy %PREFIX_PATH%\lib\libcrypto.lib %PREFIX_PATH%\lib\crypto.lib

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo exec_prefix=${prefix}>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo libdir=${exec_prefix}/lib>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo includedir=${prefix}/include>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo enginesdir=${libdir}/engines-3>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo modulesdir=${libdir}/ossl-modules>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo Name: OpenSSL-libcrypto>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo Description: OpenSSL cryptography library>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo Version: %OPENSSL_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo Libs: -L${libdir} -lcrypto>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo Libs.private: -lz -ldl -pthread>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"
@echo Cflags: -DOPENSSL_LOAD_CONF -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\libcrypto.pc"

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo exec_prefix=${prefix}>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo libdir=${exec_prefix}/lib>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo includedir=${prefix}/include>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo Name: OpenSSL-libssl>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo Description: Secure Sockets Layer and cryptography libraries>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo Version: %OPENSSL_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo Requires.private: libcrypto>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo Libs: -L${libdir} -lssl>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"
@echo Cflags: -DOPENSSL_LOAD_CONF -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\libssl.pc"

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"
@echo exec_prefix=${prefix}>> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"
@echo libdir=${exec_prefix}/lib>> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"
@echo includedir=${prefix}/include>> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"
@echo Name: OpenSSL>> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"
@echo Description: Secure Sockets Layer and cryptography libraries and tools>> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"
@echo Version: %OPENSSL_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"
@echo Requires: libssl libcrypto>> "%PREFIX_PATH%\lib\pkgconfig\openssl.pc"

@goto continue


:gmp

@echo Installing gmp

if not exist "%BUILD_PATH%\ShiftMediaProject\build" mkdir "%BUILD_PATH%\ShiftMediaProject\build" || goto end
cd "%BUILD_PATH%\ShiftMediaProject\build" || goto end

if not exist "gmp" @(
  mkdir gmp || goto end
  cd gmp || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\gmp" . || goto end
  git checkout %GMP_VERSION% || goto end
  cd ..
) || goto end

cd gmp\SMP || goto end

msbuild libgmp.sln -p:Configuration=%BUILD_TYPE%DLL || goto end

xcopy /s /y ..\..\..\msvc\lib\x64\gmp*.lib "%PREFIX_PATH%\lib\" || goto end
xcopy /s /y ..\..\..\msvc\bin\x64\gmp*.dll "%PREFIX_PATH%\bin\" || goto end
xcopy /s /y ..\..\..\msvc\include\gmp*.h "%PREFIX_PATH%\include\" || goto end

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo Name: gmp>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo Description: gmp>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo URL: https://gmplib.org/>> %PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo Version: %GMP_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo Libs: -L${libdir} -lgmp%LIB_POSTFIX%>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\gmp.pc"

@goto continue


:nettle

@echo Installing nettle

if not exist "%BUILD_PATH%\ShiftMediaProject\build" mkdir "%BUILD_PATH%\ShiftMediaProject\build" || goto end
cd "%BUILD_PATH%\ShiftMediaProject\build" || goto end

if not exist "nettle" @(
  mkdir nettle || goto end
  cd nettle || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\nettle" . || goto end
  git checkout nettle_%NETTLE_VERSION% || goto end
  cd ..
) || goto end

cd nettle\SMP || goto end

msbuild libnettle.vcxproj -p:Configuration=%BUILD_TYPE%DLL || goto end
xcopy /s /y ..\..\..\msvc\lib\x64\nettle*.lib "%PREFIX_PATH%\lib\" || goto end
xcopy /s /y ..\..\..\msvc\bin\x64\nettle*.dll "%PREFIX_PATH%\bin\" || goto end
if not exist "%PREFIX_PATH%\include\nettle" mkdir "%PREFIX_PATH%\include\nettle" || goto end
xcopy /s /y ..\..\..\msvc\include\nettle\*.h "%PREFIX_PATH%\include\nettle\" || goto end

msbuild libhogweed.vcxproj -p:Configuration=%BUILD_TYPE%DLL || goto end
xcopy /s /y ..\..\..\msvc\lib\x64\hogweed*.lib "%PREFIX_PATH%\lib\" || goto end
xcopy /s /y ..\..\..\msvc\bin\x64\hogweed*.dll "%PREFIX_PATH%\bin\" || goto end
if not exist "%PREFIX_PATH%\include\nettle" mkdir "%PREFIX_PATH%\include\nettle" || goto end
xcopy /s /y ..\..\..\msvc\include\nettle\*.h "%PREFIX_PATH%\include\nettle\" || goto end

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo Name: nettle>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo Description: nettle>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo URL: https://www.lysator.liu.se/~nisse/nettle/>> %PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo Version: %NETTLE_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo Libs: -L${libdir} -lnettle%LIB_POSTFIX%>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\nettle.pc"

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo Name: hogweed>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo Description: hogweed>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo URL: https://www.lysator.liu.se/~nisse/nettle/>> %PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo Version: %NETTLE_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo Libs: -L${libdir} -lhogweed%LIB_POSTFIX%>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\hogweed.pc"

@goto continue


:gnutls

@echo Installing gnutls

if not exist "%BUILD_PATH%\ShiftMediaProject\build" mkdir "%BUILD_PATH%\ShiftMediaProject\build" || goto end
cd "%BUILD_PATH%\ShiftMediaProject\build" || goto end

if not exist "gnutls" @(
  mkdir gnutls || goto end
  cd gnutls || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\gnutls" . || goto end
  git checkout %GNUTLS_VERSION% || goto end
  cd ..
) || goto end

cd gnutls\SMP || goto end

echo ^<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003"^>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo   ^<ItemDefinitionGroup^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo     ^<ClCompile^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo       ^<AdditionalIncludeDirectories^>%PREFIX_PATH%\include;%%(AdditionalIncludeDirectories)^</AdditionalIncludeDirectories^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo     ^</ClCompile^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo     ^<Link^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo       ^<AdditionalLibraryDirectories^>%PREFIX_PATH%\lib;%%(AdditionalLibraryDirectories)^</AdditionalLibraryDirectories^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo     ^</Link^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo   ^</ItemDefinitionGroup^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"
echo ^</Project^>>> "%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props"

msbuild libgnutls.sln -p:Configuration=%CMAKE_BUILD_TYPE%DLL -p:ForceImportBeforeCppTargets=%BUILD_PATH%\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props || goto end

xcopy /s /y ..\..\..\msvc\lib\x64\gnutls*.lib "%PREFIX_PATH%\lib\" || goto end
xcopy /s /y ..\..\..\msvc\bin\x64\gnutls*.dll "%PREFIX_PATH%\bin\" || goto end
if not exist "%PREFIX_PATH%\include\gnutls" mkdir "%PREFIX_PATH%\include\gnutls" || goto end
xcopy /s /y ..\..\..\msvc\include\gnutls\*.h "%PREFIX_PATH%\include\gnutls\" || goto end

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Name: gnutls>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Description: gnutls>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo URL: https://www.gnutls.org/>> %PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Version: %GNUTLS_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Libs: -L${libdir} -lgnutls%LIB_POSTFIX%>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\gnutls.pc"

@goto continue


:libpng

@echo Building libpng

cd "%BUILD_PATH%" || goto end
if not exist "libpng-%LIBPNG_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libpng-%LIBPNG_VERSION%.tar.gz" || goto end
cd "libpng-%LIBPNG_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/libpng-pkgconf.patch"
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
@if "%BUILD_TYPE%" == "debug" copy /y "%PREFIX_PATH%\lib\libpng16d.lib" "%PREFIX_PATH%\lib\png16.lib" || goto end

@goto continue


:libjpeg

@echo Building libjpeg

cd "%BUILD_PATH%" || goto end
if not exist "libjpeg-turbo-%LIBJPEG_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libjpeg-turbo-%LIBJPEG_VERSION%.tar.gz" || goto end
cd "libjpeg-turbo-%LIBJPEG_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DENABLE_SHARED=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:pcre2

@echo Building pcre2

cd "%BUILD_PATH%" || goto end
if not exist "pcre2-%PCRE2_VERSION%" tar -xvf "%DOWNLOADS_PATH%\pcre2-%PCRE2_VERSION%.tar.gz" || goto end
cd "pcre2-%PCRE2_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DPCRE2_BUILD_PCRE2_16=ON -DPCRE2_BUILD_PCRE2_32=ON -DPCRE2_BUILD_PCRE2_8=ON -DPCRE2_BUILD_TESTS=OFF -DPCRE2_SUPPORT_UNICODE=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:bzip2

@echo Building bzip2

cd "%BUILD_PATH%" || goto end
if not exist "bzip2-%BZIP2_VERSION%" tar -xvf "%DOWNLOADS_PATH%\bzip2-%BZIP2_VERSION%.tar.gz" || goto end
cd bzip2-%BZIP2_VERSION% || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/bzip2-cmake.patch"
if not exist build2 mkdir build2 || goto end
cmake --log-level="DEBUG" -S . -B build2 -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build2 || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:xz

@echo Building xz

cd "%BUILD_PATH%" || goto end
if not exist "xz-%XZ_VERSION%" tar -xvf "%DOWNLOADS_PATH%\xz-%XZ_VERSION%.tar.gz" || goto end
cd "xz-%XZ_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DBUILD_TESTING=OFF -DXZ_NLS=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:brotli

@echo Building brotli

cd "%BUILD_PATH%" || goto end
if not exist "brotli-%BROTLI_VERSION%" tar -xvf "%DOWNLOADS_PATH%\brotli-%BROTLI_VERSION%.tar.gz" || goto end
cd "brotli-%BROTLI_VERSION%" || goto end
if not exist build2 mkdir build2 || goto end
cmake --log-level="DEBUG" -S . -B build2 -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_TESTING=OFF || goto end
cd build2 || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:libiconv

@echo Building libiconv

cd "%BUILD_PATH%" || goto end
if not exist "libiconv-for-Windows" @(
  mkdir libiconv-for-Windows || goto end
  cd libiconv-for-Windows || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\libiconv-for-Windows" . || goto end
  cd ..
) || goto end
cd libiconv-for-Windows || goto end
msbuild libiconv.sln /property:Configuration=%BUILD_TYPE% || goto end
copy /y "output\x64\%BUILD_TYPE%\*.lib" "%PREFIX_PATH%\lib\" || goto end
copy /y "output\x64\%BUILD_TYPE%\*.dll" "%PREFIX_PATH%\bin\" || goto end
copy /y "include\*.h" "%PREFIX_PATH%\include\" || goto end
@if "%BUILD_TYPE%" == "debug" copy /y "%PREFIX_PATH%\lib\libiconvD.lib" "%PREFIX_PATH%\lib\libiconv.lib"

@goto continue


:icu4c

@echo Building icu4c

cd "%BUILD_PATH%" || goto end
if not exist "icu" 7z x "%DOWNLOADS_PATH%\icu4c-%ICU4C_VERSION_UNDERSCORE%-src.zip" || goto end
cd "icu\source\allinone" || goto end
@rem start /w devenv.exe allinone.sln /upgrade
msbuild allinone.sln /property:Configuration="%BUILD_TYPE%" /p:Platform="x64" /p:SkipUWP=true || goto end
cd ..\..\ || goto end
if not exist "%PREFIX_PATH%\include\unicode" mkdir "%PREFIX_PATH%\include\unicode" || goto end
copy /y "include\unicode\*.h" "%PREFIX_PATH%\include\unicode\" || goto end
copy /y "lib64\*.*" "%PREFIX_PATH%\lib\" || goto end
copy /y "bin64\*.*" "%PREFIX_PATH%\bin\" || goto end

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@echo exec_prefix=${prefix}>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@echo libdir=${exec_prefix}/lib>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@echo includedir=${prefix}/include>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@echo Name: icu-uc>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@echo Description: International Components for Unicode: Common and Data libraries>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@echo Version: %ICU4C_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@if "%BUILD_TYPE%" == "debug" @echo Libs: -L${libdir} -licuucd -licudt>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@if "%BUILD_TYPE%" == "release" @echo Libs: -L${libdir} -licuuc -licudt>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"
@echo Libs.private: -lpthread -lm>> "%PREFIX_PATH%\lib\pkgconfig\icu-uc.pc"

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@echo exec_prefix=${prefix}>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@echo libdir=${exec_prefix}/lib>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@echo includedir=${prefix}/include>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@echo Name: icu-i18n>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@echo Description: International Components for Unicode: Stream and I/O Library>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@echo Version: %ICU4C_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@if "%BUILD_TYPE%" == "debug" @echo Libs: -licuind>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@if "%BUILD_TYPE%" == "release" @echo Libs: -licuin>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"
@echo Requires: icu-uc>> "%PREFIX_PATH%\lib\pkgconfig\icu-i18n.pc"

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@echo exec_prefix=${prefix}>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@echo libdir=${exec_prefix}/lib>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@echo includedir=${prefix}/include>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@echo Name: icu-io>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@echo Description: International Components for Unicode: Stream and I/O Library>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@echo Version: %ICU4C_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@if "%BUILD_TYPE%" == "debug" @echo Libs: -licuiod>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@if "%BUILD_TYPE%" == "release" @echo Libs: -licuio>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"
@echo Requires: icu-i18n>> "%PREFIX_PATH%\lib\pkgconfig\icu-io.pc"

@goto continue


:pixman

@echo Building pixman

cd "%BUILD_PATH%" || goto end
if not exist "pixman-%PIXMAN_VERSION%" tar -xvf "%DOWNLOADS_PATH%\pixman-%PIXMAN_VERSION%.tar.gz"
cd "pixman-%PIXMAN_VERSION%" || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload -Dgtk=disabled -Dlibpng=enabled build || goto end

cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:expat

@echo Building expat

cd "%BUILD_PATH%" || goto end
if not exist "expat-%EXPAT_VERSION%" tar -xvf "%DOWNLOADS_PATH%\expat-%EXPAT_VERSION%.tar.gz" || goto end
cd "expat-%EXPAT_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DEXPAT_SHARED_LIBS=ON -DEXPAT_BUILD_DOCS=OFF -DEXPAT_BUILD_EXAMPLES=OFF -DEXPAT_BUILD_FUZZERS=OFF -DEXPAT_BUILD_TESTS=OFF -DEXPAT_BUILD_TOOLS=OFF -DEXPAT_BUILD_PKGCONFIG=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:boost

@echo Building boost

cd "%BUILD_PATH%" || goto end

if not exist "boost_%BOOST_VERSION_UNDERSCORE%" tar -xvf "%DOWNLOADS_PATH%\boost_%BOOST_VERSION_UNDERSCORE%.tar.gz" || goto end
cd "%BUILD_PATH%\boost_%BOOST_VERSION_UNDERSCORE%" || goto end
if exist b2.exe del b2.exe
if exist bjam.exe del bjam.exe
if exist stage rmdir /s /q stage

@echo Running bootstrap.bat
call .\bootstrap.bat || goto end

@echo Running b2.exe
.\b2.exe -a -q -j 4 -d1 --ignore-site-config --stagedir="stage" --layout="tagged" --prefix="%PREFIX_PATH%" --exec-prefix="%PREFIX_PATH%\bin" --libdir="%PREFIX_PATH%\lib" --includedir="%PREFIX_PATH%\include" --with-headers toolset=msvc architecture=x86 address-model=64 link=shared runtime-link=shared threadapi=win32 threading=multi variant=%BUILD_TYPE% install

@goto continue


:libxml2

@echo Building libxml2

cd "%BUILD_PATH%" || goto end
if not exist "libxml2-v%LIBXML2_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libxml2-v%LIBXML2_VERSION%.tar.gz"
cd "libxml2-v%LIBXML2_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DLIBXML2_WITH_PYTHON=OFF -DLIBXML2_WITH_ZLIB=ON -DLIBXML2_WITH_LZMA=ON -DLIBXML2_WITH_ICONV=ON -DLIBXML2_WITH_ICU=ON -DICU_ROOT="%PREFIX_PATH_FORWARD%" || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
@if "%BUILD_TYPE%" == "debug" copy /y "%PREFIX_PATH%\lib\libxml2d.lib" "%PREFIX_PATH%/lib/libxml2.lib"

@goto continue


:nghttp2

@echo Building nghttp2

cd "%BUILD_PATH%" || goto end
if not exist "nghttp2-%NGHTTP2_VERSION%" tar -xvf "%DOWNLOADS_PATH%\nghttp2-%NGHTTP2_VERSION%.tar.gz" || goto end
cd "nghttp2-%NGHTTP2_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:libffi

@echo Building libffi

cd "%BUILD_PATH%" || goto end
if not exist "libffi" @(
  mkdir "libffi" || goto end
  cd "libffi" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\libffi" . || goto end
  cd ..
 ) || goto end
cd libffi || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" -Dpkg_config_path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:libintl

@echo Building libintl

cd "%BUILD_PATH%" || goto end
if not exist "proxy-libintl" @(
  mkdir "proxy-libintl" || goto end
  cd "proxy-libintl" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\proxy-libintl" . || goto end
  cd ..
 ) || goto end
cd proxy-libintl || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" -Dpkg_config_path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:dlfcn-win32

@echo Building dlfcn-win32

cd "%BUILD_PATH%" || goto end
if not exist "dlfcn-win32-%DLFCN_VERSION%" tar -xvf "%DOWNLOADS_PATH%\dlfcn-win32-%DLFCN_VERSION%.tar.gz" || goto end
cd "dlfcn-win32-%DLFCN_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:libpsl

@echo Building libpsl

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include
@set LDFLAGS=-L%PREFIX_PATH%\lib

cd "%BUILD_PATH%" || goto end
if not exist "libpsl-%LIBPSL_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libpsl-%LIBPSL_VERSION%.tar.gz" || goto end
cd "libpsl-%LIBPSL_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\libpsl-time.patch"
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@set CFLAGS=
@set LDFLAGS=

@goto continue


:orc

@echo Building orc

cd "%BUILD_PATH%" || goto end
if not exist "orc-%ORC_VERSION%" 7z x "%DOWNLOADS_PATH%\orc-%ORC_VERSION%.tar.xz" -so | 7z x -aoa -si"orc-%ORC_VERSION%.tar" || goto end
@rem if not exist "orc-%ORC_VERSION%" tar -xvf "%DOWNLOADS_PATH%\orc-%ORC_VERSION%.tar.xz" || goto end
cd "orc-%ORC_VERSION%" || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end


@goto continue


:curl

@echo Building curl

cd "%BUILD_PATH%" || goto end
if not exist "curl-%CURL_VERSION%" tar -xvf "%DOWNLOADS_PATH%\curl-%CURL_VERSION%.tar.gz" || goto end
cd "curl-%CURL_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:sqlite

@echo Building sqlite

cd "%BUILD_PATH%" || goto end
if not exist "sqlite-autoconf-%SQLITE_VERSION%" tar -xvf "%DOWNLOADS_PATH%\sqlite-autoconf-%SQLITE_VERSION%.tar.gz" || goto end
cd "sqlite-autoconf-%SQLITE_VERSION%" || goto end
cl -DSQLITE_API="__declspec(dllexport)" -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_COLUMN_METADATA sqlite3.c -link -dll -out:sqlite3.dll || goto end
cl shell.c sqlite3.c -Fe:sqlite3.exe || goto end
copy /y "*.h" "%PREFIX_PATH%\include\" || goto end
copy /y "*.lib" "%PREFIX_PATH%\lib\" || goto end
copy /y "*.dll" "%PREFIX_PATH%\bin\" || goto end
copy /y "*.exe" "%PREFIX_PATH%\bin\" || goto end

echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo.>>"%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Name: SQLite>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Description: SQL database engine>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo URL: https://www.sqlite.org/>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Version: 3.38.1>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Libs: -L${libdir} -lsqlite3>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Libs.private: -lz -ldl>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"
echo Cflags: -I${includedir}>> "%PREFIX_PATH%/lib/pkgconfig/sqlite3.pc"

@goto continue


:glib

@echo Building glib

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include
@set LDFLAGS=-L%PREFIX_PATH%\lib

cd "%BUILD_PATH%" || goto end
if not exist "glib-%GLIB_VERSION%" 7z x "%DOWNLOADS_PATH%\glib-%GLIB_VERSION%.tar.xz" -so | 7z x -aoa -si"glib-%GLIB_VERSION%.tar"
@rem if not exist "glib-%GLIB_VERSION%" tar -xvf "%DOWNLOADS_PATH%\glib-%GLIB_VERSION%.tar.xz" || goto end
cd "glib-%GLIB_VERSION%" || goto end
@rem sed -i "s/libintl = dependency('intl', required: false)/libintl = cc.find_library('intl', dirs: '%PREFIX_PATH_ESCAPE%\\lib', required: true)/g" meson.build || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --includedir="%PREFIX_PATH%\include" --libdir="%PREFIX_PATH%\lib" -Dpkg_config_path="%PREFIX_PATH%\lib\pkgconfig" -Dtests=false build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@set CFLAGS=
@set LDFLAGS=

@goto continue


:libproxy

@echo Building libproxy

cd "%BUILD_PATH%" || goto end
if not exist "libproxy-%LIBPROXY_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libproxy-%LIBPROXY_VERSION%.tar.gz" || goto end
cd "libproxy-%LIBPROXY_VERSION%" || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" -Dpkg_config_path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload -Ddocs=false -Dtests=false -Dconfig-gnome=false -Dpacrunner-duktape=false -Dintrospection=false build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end
move /y "%PREFIX_PATH%\lib\libproxy.dll" "%PREFIX_PATH%\bin\libproxy.dll" || goto end

@goto continue


:libsoup

@echo Building libsoup

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include

cd "%BUILD_PATH%" || goto end
if not exist "libsoup-%LIBSOUP_VERSION%" 7z x "%DOWNLOADS_PATH%\libsoup-%LIBSOUP_VERSION%.tar.xz" -so | 7z x -aoa -si"libsoup-%LIBSOUP_VERSION%.tar" || goto end
@rem if not exist "libsoup-%LIBSOUP_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libsoup-%LIBSOUP_VERSION%.tar.xz" || goto end
cd "libsoup-%LIBSOUP_VERSION%" || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload -Dtests=false -Dvapi=disabled -Dgssapi=disabled -Dintrospection=disabled -Dtests=false -Dsysprof=disabled -Dtls_check=false build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@set CFLAGS=

@goto continue


:glib-networking

@echo Building glib-networking

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include

cd "%BUILD_PATH%" || goto end
if not exist "glib-networking-%GLIB_NETWORKING_VERSION%" 7z x "%DOWNLOADS_PATH%\glib-networking-%GLIB_NETWORKING_VERSION%.tar.xz" -so | 7z x -aoa -si"glib-networking-%GLIB_NETWORKING_VERSION%.tar" || goto end
@rem if not exist "glib-networking-%GLIB_NETWORKING_VERSION%" tar -xvf "%DOWNLOADS_PATH%\glib-networking-%GLIB_NETWORKING_VERSION%.tar.xz" || goto end
cd "glib-networking-%GLIB_NETWORKING_VERSION%" || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload -Dgnutls=enabled -Dopenssl=enabled -Dgnome_proxy=disabled -Dlibproxy=disabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@set CFLAGS=

@goto continue


:freetype

@echo Building freetype without harfbuzz

cd "%BUILD_PATH%" || goto end
if not exist "freetype-%FREETYPE_VERSION%" tar -xvf "%DOWNLOADS_PATH%\freetype-%FREETYPE_VERSION%.tar.gz" || goto end
cd "freetype-%FREETYPE_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DFT_DISABLE_HARFBUZZ=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
copy /y "%PREFIX_PATH%\lib\freetyped.lib" "%PREFIX_PATH%\lib\freetype.lib"

@goto continue


:cairo

@echo Building cairo

cd "%BUILD_PATH%" || goto end
if not exist "cairo-%CAIRO_VERSION%" 7z x "%DOWNLOADS_PATH%\cairo-%CAIRO_VERSION%.tar.xz" -so | 7z x -aoa -si"cairo-%CAIRO_VERSION%.tar" || goto end
@rem if not exist "cairo-%CAIRO_VERSION%" tar -xvf "%DOWNLOADS_PATH%\cairo-%CAIRO_VERSION%.tar.xz" || goto end
cd "cairo-%CAIRO_VERSION%" || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload -Dfontconfig=disabled -Dfreetype=enabled -Dzlib=enabled -Dpng=enabled -Dtests=disabled -Dgtk_doc=false build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@goto continue


:harfbuzz

@echo Building harfbuzz

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include
@set CXXFLAGS=-I%PREFIX_PATH_FORWARD%/include
@set LDFLAGS=-L%PREFIX_PATH%\lib

cd "%BUILD_PATH%" || goto end
if not exist "harfbuzz-%HARFBUZZ_VERSION%" 7z x "%DOWNLOADS_PATH%\harfbuzz-%HARFBUZZ_VERSION%.tar.xz" -so | 7z x -aoa -si"harfbuzz-%HARFBUZZ_VERSION%.tar"
@rem if not exist "harfbuzz-%HARFBUZZ_VERSION%" tar -xvf "%DOWNLOADS_PATH%\harfbuzz-%HARFBUZZ_VERSION%.tar.xz" || goto end
cd "harfbuzz-%HARFBUZZ_VERSION%" || goto end

if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --wrap-mode=nodownload -Dcpp_std=c++17 -Dtests=disabled -Ddocs=disabled -Dicu=enabled -Dfreetype=enabled -Dcairo=disabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@rem if not exist build mkdir build || goto end
@rem cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DHB_HAVE_GLIB=ON -DHB_HAVE_ICU=ON -DHB_HAVE_FREETYPE=ON -DICU_ROOT="%PREFIX_PATH_FORWARD%" || goto end
@rem cd build || goto end
@rem cmake --build . || goto end
@rem cmake --install . || goto end

@echo Building freetype with harfbuzz

cd "%BUILD_PATH%" || goto end
if not exist "freetype-%FREETYPE_VERSION%" tar -xvf "%DOWNLOADS_PATH%\freetype-%FREETYPE_VERSION%.tar.gz" || goto end
cd "freetype-%FREETYPE_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DFT_DISABLE_HARFBUZZ=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
copy /y "%PREFIX_PATH%\lib\freetyped.lib" "%PREFIX_PATH%\lib\freetype.lib"

@set CFLAGS=
@set CXXFLAGS=
@set LDFLAGS=

@goto continue


:libogg

@echo Building libogg

cd "%BUILD_PATH%" || goto end
if not exist "libogg-%LIBOGG_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libogg-%LIBOGG_VERSION%.tar.gz" || goto end
cd "libogg-%LIBOGG_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DINSTALL_DOCS=OFF -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:libvorbis

@echo Building libvorbis

cd "%BUILD_PATH%" || goto end
if not exist "libvorbis-%LIBVORBIS_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libvorbis-%LIBVORBIS_VERSION%.tar.gz" || goto end
cd "libvorbis-%LIBVORBIS_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DINSTALL_DOCS=OFF -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:flac

@echo Building flac

cd "%BUILD_PATH%" || goto end
if not exist "flac-%FLAC_VERSION%" 7z x "%DOWNLOADS_PATH%\flac-%FLAC_VERSION%.tar.xz" -so | 7z x -aoa -si"flac-%FLAC_VERSION%.tar" || goto end
@rem if not exist "flac-%FLAC_VERSION%" tar -xvf "%DOWNLOADS_PATH%\flac-%FLAC_VERSION%.tar.xz" || goto end
cd "flac-%FLAC_VERSION%" || goto end
if not exist build2 mkdir build2 || goto end
cmake --log-level="DEBUG" -S . -B build2 -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_DOCS=OFF -DBUILD_EXAMPLES=OFF -DINSTALL_MANPAGES=OFF -DBUILD_TESTING=OFF -DBUILD_PROGRAMS=OFF || goto end
cd build2 || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:wavpack

@echo Building wavpack

cd "%BUILD_PATH%" || goto end
if not exist "wavpack-%WAVPACK_VERSION%" tar -xvf "%DOWNLOADS_PATH%\wavpack-%WAVPACK_VERSION%.tar.bz2" || goto end
cd "wavpack-%WAVPACK_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF -DWAVPACK_BUILD_DOCS=OFF -DWAVPACK_BUILD_PROGRAMS=OFF -DWAVPACK_ENABLE_ASM=OFF -DWAVPACK_ENABLE_LEGACY=OFF -DWAVPACK_BUILD_WINAMP_PLUGIN=OFF -DWAVPACK_BUILD_COOLEDIT_PLUGIN=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
if not exist "%PREFIX_PATH%\include\wavpack" mkdir "%PREFIX_PATH%\include\wavpack" || goto end
copy /y "%PREFIX_PATH%\lib\wavpackdll.lib" "%PREFIX_PATH%\lib\wavpack.lib" || goto end
copy /y "%PREFIX_PATH%\bin\wavpackdll.dll" "%PREFIX_PATH%\bin\wavpack.dll" || goto end


@goto continue


:opus

@echo Building opus

cd "%BUILD_PATH%" || goto end
if not exist "opus-%OPUS_VERSION%" tar -xvf "%DOWNLOADS_PATH%\opus-%OPUS_VERSION%.tar.gz" || goto end
cd opus-%OPUS_VERSION% || goto end
findstr /v /c:"include(opus_buildtype.cmake)" CMakeLists.txt > CMakeLists.txt.new || goto end
del CMakeLists.txt
ren CMakeLists.txt.new CMakeLists.txt || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:opusfile

@echo Building opusfile

cd "%BUILD_PATH%" || goto end
if not exist "opusfile-%OPUSFILE_VERSION%" tar -xvf "%DOWNLOADS_PATH%\opusfile-%OPUSFILE_VERSION%.tar.gz" || goto end
cd "opusfile-%OPUSFILE_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/opusfile-cmake.patch"
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:speex

@echo Building speex

cd "%BUILD_PATH%" || goto end
if not exist "speex-Speex-%SPEEX_VERSION%" tar -xvf "%DOWNLOADS_PATH%\speex-Speex-%SPEEX_VERSION%.tar.gz" || goto end
cd "speex-Speex-%SPEEX_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/speex-cmake.patch"
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
@if "%BUILD_TYPE%" == "debug" (
  copy /y "%PREFIX_PATH%\lib\libspeexd.lib" "%PREFIX_PATH%\lib\libspeex.lib" || goto end
  copy /y "%PREFIX_PATH%\bin\libspeexd.dll" "%PREFIX_PATH%\bin\libspeex.dll" || goto end
)

@goto continue


:mpg123

@echo Building mpg123

cd "%BUILD_PATH%" || goto end
if not exist "mpg123-%MPG123_VERSION%" tar -xvf "%DOWNLOADS_PATH%\mpg123-%MPG123_VERSION%.tar.bz2" || goto end
cd "mpg123-%MPG123_VERSION%" || goto end
if not exist build2 mkdir build2 || goto end
cmake --log-level="DEBUG" -S ports/cmake -B build2 -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_PROGRAMS=OFF -DBUILD_LIBOUT123=OFF -DYASM_ASSEMBLER="%PREFIX_PATH_FORWARD%/bin/vsyasm.exe" || goto end

cd build2 || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:lame

@echo Building lame

cd "%BUILD_PATH%" || goto end
if not exist "lame-%LAME_VERSION%" tar -xvf "%DOWNLOADS_PATH%\lame-%LAME_VERSION%.tar.gz" || goto end
cd "lame-%LAME_VERSION%" || goto end
sed -i "s/MACHINE = \/machine:.*/MACHINE = \/machine:Win64/g" Makefile.MSVC || goto end
nmake -f Makefile.MSVC MSVCVER=Win64 libmp3lame.dll || goto end
copy include\*.h "%PREFIX_PATH%\include\" || goto end
copy output\libmp3lame*.lib "%PREFIX_PATH%\lib\" || goto end
copy output\libmp3lame*.dll "%PREFIX_PATH%\bin\" || goto end

@echo "Create lame pc file"

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo.>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Name: lame>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Description: encoder that converts audio to the MP3 file format.>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo URL: https://lame.sourceforge.io/>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Version: %LAME_VERSION%>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Libs: -L${libdir} -lmp3lame>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%/lib/pkgconfig/mp3lame.pc"


@goto continue


:twolame

@echo Building twolame

cd "%BUILD_PATH%" || goto end
if not exist "twolame-%TWOLAME_VERSION%" tar -xvf "%DOWNLOADS_PATH%\twolame-%TWOLAME_VERSION%.tar.gz" || goto end
cd "twolame-%TWOLAME_VERSION%" || goto end
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

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo.>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Name: lame>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Description: optimised MPEG Audio Layer 2 (MP2) encoder based on tooLAME>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo URL: https://www.twolame.org/>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Version: %TWOLAME_VERSION%>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Libs: -L${libdir} -ltwolame_dll>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%/lib/pkgconfig/twolame.pc"

@goto continue


:fftw3

@rem Use FFTW compiled with mingw as it's recommended by FFTW.

@echo Building fftw3

cd "%BUILD_PATH%" || goto end

if not exist "fftw" @(
  mkdir fftw || goto end
  cd fftw || goto end
  7z x "%DOWNLOADS_PATH%\fftw-%FFTW_VERSION%-x64-%BUILD_TYPE%.zip" || goto end
  cd ..
) || goto end
cd fftw || goto end
@rem echo LIBRARY libfftw3-3.dll > libfftw3-3.def
@rem echo EXPORTS >> libfftw3-3.def
@rem for /f "skip=19 tokens=4" %A in ('dumpbin /exports libfftw3-3.dll') do echo %A>> libfftw3-3.def
lib /machine:x64 /def:libfftw3-3.def || goto end
xcopy /s /y libfftw3-3.dll "%PREFIX_PATH%\bin\" || goto end
xcopy /s /y libfftw3-3.lib "%PREFIX_PATH%\lib\" || goto end
xcopy /s /y fftw3.h "%PREFIX_PATH%\include\" || goto end

echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo.>>"%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo Name: fftw3>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo Description: discrete Fourier transform (DFT)>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo URL: https://www.fftw.org/>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo Version: %FFTW_VERSION%>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo Libs: -L${libdir} -lfftw3-3>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"
echo Cflags: -I${includedir}>> "%PREFIX_PATH%/lib/pkgconfig/fftw3.pc"

@goto continue


:musepack

@echo Building musepack

cd "%BUILD_PATH%" || goto end
if not exist "musepack_src_r%MUSEPACK_VERSION%" tar -xvf "%DOWNLOADS_PATH%\musepack_src_r%MUSEPACK_VERSION%.tar.gz" || goto end
cd "musepack_src_r%MUSEPACK_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\musepack-fixes.patch"
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="Debug" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DSHARED=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
copy libmpcdec\*.lib %PREFIX_PATH%\lib\ || goto end
copy libmpcdec\*.dll %PREFIX_PATH%\bin\ || goto end

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo Name: mpc>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo Description: mpc>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo URL: https://www.musepack.net/>> %PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo Version: %GNUTLS_VERSION%>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo Libs: -L${libdir} -lmpcdec>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\mpcdec.pc"

goto continue


:libopenmpt

@echo Building libopenmpt

cd "%BUILD_PATH%" || goto end
if not exist "libopenmpt" @(
  mkdir libopenmpt || goto end
  cd libopenmpt || goto end
  7z x "%DOWNLOADS_PATH%\libopenmpt-%LIBOPENMPT_VERSION%+release.msvc.zip" || goto end
  cd ..
 ) || goto end
cd "libopenmpt" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\libopenmpt-cmake.patch"
if not exist build2 mkdir build2 || goto end
cmake --log-level="DEBUG" -S . -B build2 -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build2 || goto end
cmake --build . || goto end
cmake --install . || goto end

goto continue


:libgme

@echo Building libgme

cd "%BUILD_PATH%" || goto end
if not exist "libgme-%LIBGME_VERSION%" tar -xf "%DOWNLOADS_PATH%/libgme-%LIBGME_VERSION%-src.tar.gz" || goto end
cd libgme-%LIBGME_VERSION% || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\libgme-pkgconf.patch"
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

goto continue


:fdk-aac

@echo Building fdk-aac

cd "%BUILD_PATH%" || goto end
if not exist "fdk-aac-%FDK_AAC_VERSION%" tar -xvf "%DOWNLOADS_PATH%\fdk-aac-%FDK_AAC_VERSION%.tar.gz" || goto end
cd "fdk-aac-%FDK_AAC_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_PROGRAMS=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:faad2

@echo Building faad2

cd "%BUILD_PATH%" || goto end
if not exist "knik0-faad2-*" tar -xvf "%DOWNLOADS_PATH%\faad2-%FAAD2_VERSION%.tar.gz" || goto end
cd "knik0-faad2-*" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . --config %CMAKE_BUILD_TYPE% || goto end


@goto continue


:faac

@echo Building faac

cd "%BUILD_PATH%" || goto end
if not exist "faac-faac-%FAAC_VERSION%" tar -xvf "%DOWNLOADS_PATH%\faac-%FAAC_VERSION%.tar.gz" || goto end
cd "faac-faac-%FAAC_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\faac-msvc.patch"
cd project\msvc || goto end
start /w devenv.exe faac.sln /upgrade
msbuild faac.sln /property:Configuration=%BUILD_TYPE% || goto end
copy /y "..\..\include\*.h" "%PREFIX_PATH%\include\" || goto end
copy /y "bin\%BUILD_TYPE%\libfaac_dll.lib" "%PREFIX_PATH%\lib\libfaac.lib" || goto end
copy /y "bin\%BUILD_TYPE%\*.dll" "%PREFIX_PATH%\bin\" || goto end

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo Name: faac>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo Description: faac>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo URL: https://github.com/knik0/faac>> %PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo Version: 1.30>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo Libs: -L${libdir} -lfaac>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\faac.pc"

@goto continue


:utfcpp

@echo Building utfcpp

cd "%BUILD_PATH%" || goto end
if not exist "utfcpp-%UTFCPP_VERSION%" tar -xvf "%DOWNLOADS_PATH%\utfcpp-%UTFCPP_VERSION%.tar.gz" || goto end
cd "utfcpp-%UTFCPP_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue

:taglib

@echo Building taglib

cd "%BUILD_PATH%" || goto end
if not exist "taglib-%TAGLIB_VERSION%" tar -xvf "%DOWNLOADS_PATH%\taglib-%TAGLIB_VERSION%.tar.gz" || goto end
cd "taglib-%TAGLIB_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:libbs2b

@echo Building libbs2b

cd "%BUILD_PATH%" || goto end
if not exist "libbs2b-%LIBBS2B_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libbs2b-%LIBBS2B_VERSION%.tar.bz2" || goto end
cd "libbs2b-%LIBBS2B_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%\libbs2b-msvc.patch"
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:libebur128

@echo Building libebur128

cd "%BUILD_PATH%" || goto end
if not exist "libebur128 -%LIBEBUR128_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libebur128-%LIBEBUR128_VERSION%.tar.gz" || goto end
cd "libebur128-%LIBEBUR128_VERSION%" || goto end
sed -i "/^Libs.private.*/d" ebur128\libebur128.pc.cmake || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:ffmpeg

@echo Building ffmpeg

cd "%BUILD_PATH%" || goto end
if not exist "ffmpeg" @(
  mkdir "ffmpeg" || goto end
  cd "ffmpeg" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\ffmpeg" . || goto end
  git checkout meson-%FFMPEG_VERSION% || goto end
  git checkout . || goto end
  git pull --rebase || goto end
  cd ..
 ) || goto end
cd ffmpeg || goto end
if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=both --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload -Dtests=disabled -Dgpl=enabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end
cd .. || goto end

@goto continue


:chromaprint

@echo Building chromaprint

cd "%BUILD_PATH%" || goto end
if not exist "chromaprint-%CHROMAPRINT_VERSION%" tar -xvf "%DOWNLOADS_PATH%\chromaprint-%CHROMAPRINT_VERSION%.tar.gz"
cd "chromaprint-%CHROMAPRINT_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DBUILD_SHARED_LIBS=ON -DFFMPEG_ROOT="%PREFIX_PATH%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:gstreamer

@echo Building GStreamer

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include

cd "%BUILD_PATH%" || goto end

if "%GST_DEV%" == "ON" @(
  if not exist "gstreamer" mkdir "gstreamer" || goto end
  cd "gstreamer" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\gstreamer\subprojects\gstreamer" . || goto end
) else @(
  if not exist "gstreamer-%GSTREAMER_VERSION%" 7z x "%DOWNLOADS_PATH%\gstreamer-%GSTREAMER_VERSION%.tar.xz" -so | 7z x -aoa -si"gstreamer-%GSTREAMER_VERSION%.tar" || goto end
  @rem if not exist "gstreamer-%GSTREAMER_VERSION%" tar -xvf "%DOWNLOADS_PATH%\gstreamer-%GSTREAMER_VERSION%.tar.xz" || goto end
  cd "gstreamer-%GSTREAMER_VERSION%" || goto end
)

if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload -Dexamples=disabled -Dtests=disabled -Dbenchmarks=disabled -Dtools=enabled -Dintrospection=disabled -Dnls=disabled -Ddoc=disabled -Dgst_debug=true -Dgst_parse=true -Dregistry=true build || goto end

cd build || goto end
ninja || goto end
ninja install || goto end

@rem if not exist "%PREFIX_PATH%\bin\gstreamer-1.0" mkdir "%PREFIX_PATH%\bin\gstreamer-1.0" || goto end
@rem if exist "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" move /Y "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" "%PREFIX_PATH%\bin\gstreamer-1.0\" || goto end

@set CFLAGS=

goto continue


:gst-plugins-base

@echo Building gst-plugins-base

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include -I%PREFIX_PATH_FORWARD%/include/opus

cd "%BUILD_PATH%" || goto end

if "%GST_DEV%" == "ON" @(
  if not exist "gst-plugins-base" mkdir "gst-plugins-base" || goto end
  cd "gst-plugins-base" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\gstreamer\subprojects\gst-plugins-base" . || goto end
) else @(
  if not exist "gst-plugins-base-%GSTREAMER_VERSION%" 7z x "%DOWNLOADS_PATH%\gst-plugins-base-%GSTREAMER_VERSION%.tar.xz" -so | 7z x -aoa -si"gst-plugins-base-%GSTREAMER_VERSION%.tar" || goto end
  @rem if not exist "gst-plugins-base-%GSTREAMER_VERSION%" tar -xvf "%DOWNLOADS_PATH%\gst-plugins-base-%GSTREAMER_VERSION%.tar.xz" || goto end
  cd "gst-plugins-base-%GSTREAMER_VERSION%" || goto end
)

if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload --auto-features=disabled -Dexamples=disabled -Dtests=disabled -Dtools=enabled -Dintrospection=disabled -Dnls=disabled -Dorc=enabled -Ddoc=disabled -Dadder=enabled -Dapp=enabled -Daudioconvert=enabled -Daudiomixer=enabled -Daudiorate=enabled -Daudioresample=enabled -Daudiotestsrc=enabled -Ddsd=enabled -Dencoding=enabled -Dgio=enabled -Dgio-typefinder=enabled -Dpbtypes=enabled -Dplayback=enabled -Dtcp=enabled -Dtypefind=enabled -Dvolume=enabled -Dogg=enabled -Dopus=enabled -Dvorbis=enabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@rem if not exist "%PREFIX_PATH%\bin\gstreamer-1.0" mkdir "%PREFIX_PATH%\bin\gstreamer-1.0" || goto end
@rem if exist "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" move /Y "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" "%PREFIX_PATH%\bin\gstreamer-1.0\" || goto end

@set CFLAGS=

@goto continue


:gst-plugins-good

@echo Building gst-plugins-good

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include

cd "%BUILD_PATH%" || goto end

if "%GST_DEV%" == "ON" @(
  if not exist "gst-plugins-good" mkdir "gst-plugins-good" || goto end
  cd "gst-plugins-good" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\gstreamer\subprojects\gst-plugins-good" . || goto end
) else @(
  if not exist "gst-plugins-good-%GSTREAMER_VERSION%" 7z x "%DOWNLOADS_PATH%\gst-plugins-good-%GSTREAMER_VERSION%.tar.xz" -so | 7z x -aoa -si"gst-plugins-good-%GSTREAMER_VERSION%.tar" || goto end
  @rem if not exist "gst-plugins-good-%GSTREAMER_VERSION%" tar -xvf "%DOWNLOADS_PATH%\gst-plugins-good-%GSTREAMER_VERSION%.tar.xz" || goto end
  cd "gst-plugins-good-%GSTREAMER_VERSION%" || goto end
)

if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload --auto-features=disabled -Dexamples=disabled -Dtests=disabled -Dnls=disabled -Dorc=enabled -Dasm=enabled -Ddoc=disabled -Dapetag=enabled -Daudiofx=enabled -Daudioparsers=enabled -Dautodetect=enabled -Dequalizer=enabled -Dicydemux=enabled -Did3demux=enabled -Disomp4=enabled -Dreplaygain=enabled -Drtp=enabled -Drtsp=enabled -Dspectrum=enabled -Dudp=enabled -Dwavenc=enabled -Dwavparse=enabled -Dxingmux=enabled -Dadaptivedemux2=enabled -Ddirectsound=enabled -Dflac=enabled -Dlame=enabled -Dmpg123=enabled -Dspeex=enabled -Dtaglib=enabled -Dtwolame=enabled -Dwaveform=enabled -Dwavpack=enabled -Dsoup=enabled -Dhls-crypto=openssl build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@rem if not exist "%PREFIX_PATH%\bin\gstreamer-1.0" mkdir "%PREFIX_PATH%\bin\gstreamer-1.0" || goto end
@rem if exist "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" move /Y "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" "%PREFIX_PATH%\bin\gstreamer-1.0\" || goto end

@set CFLAGS=

@goto continue


:gst-plugins-bad

@echo Building gst-plugins-bad

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include -I%PREFIX_PATH_FORWARD%/include/opus

cd "%BUILD_PATH%" || goto end

if "%GST_DEV%" == "ON" @(
  if not exist "gst-plugins-bad" mkdir "gst-plugins-bad" || goto end
  cd "gst-plugins-bad" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\gstreamer\subprojects\gst-plugins-bad" . || goto end
  patch -p1 -N < "%DOWNLOADS_PATH%\gst-plugins-bad-meson-dependency.patch"
) else @(
  if not exist "gst-plugins-bad-%GSTREAMER_VERSION%" 7z x "%DOWNLOADS_PATH%\gst-plugins-bad-%GSTREAMER_VERSION%.tar.xz" -so | 7z x -aoa -si"gst-plugins-bad-%GSTREAMER_VERSION%.tar" || goto end
  @rem if not exist "gst-plugins-bad-%GSTREAMER_VERSION%" tar -xvf "%DOWNLOADS_PATH%\gst-plugins-bad-%GSTREAMER_VERSION%.tar.xz" || goto end
  cd "gst-plugins-bad-%GSTREAMER_VERSION%" || goto end
  patch -p1 -N < "%DOWNLOADS_PATH%\gst-plugins-bad-meson-dependency.patch"
)

if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload --auto-features=disabled -Dexamples=disabled -Dtools=enabled -Dtests=disabled -Dintrospection=disabled -Dnls=disabled -Dorc=enabled -Dgpl=enabled -Daiff=enabled -Dasfmux=enabled -Did3tag=enabled -Dmpegdemux=enabled -Dmpegpsmux=enabled -Dmpegtsdemux=enabled -Dmpegtsmux=enabled -Dremovesilence=enabled -Daes=enabled -Dasio=enabled -Dbluez=enabled -Dbs2b=enabled -Dchromaprint=enabled -Ddash=enabled -Ddirectsound=enabled -Dfaac=enabled -Dfaad=enabled -Dfdkaac=enabled -Dgme=enabled -Dmusepack=enabled -Dopenmpt=enabled -Dopus=enabled -Dwasapi=enabled -Dwasapi2=enabled -Dhls=enabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@rem if not exist "%PREFIX_PATH%\bin\gstreamer-1.0" mkdir "%PREFIX_PATH%\bin\gstreamer-1.0" || goto end
@rem if exist "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" move /Y "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" "%PREFIX_PATH%\bin\gstreamer-1.0\" || goto end

@set CFLAGS=

@goto continue


:gst-plugins-ugly

@echo Building gst-plugins-ugly

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include

cd "%BUILD_PATH%" || goto end

if "%GST_DEV%" == "ON" @(
  if not exist "gst-plugins-ugly" mkdir "gst-plugins-ugly" || goto end
  cd "gst-plugins-ugly" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\gstreamer\subprojects\gst-plugins-ugly" . || goto end
) else @(
  if not exist "gst-plugins-ugly-%GSTREAMER_VERSION%" 7z x "%DOWNLOADS_PATH%\gst-plugins-ugly-%GSTREAMER_VERSION%.tar.xz" -so | 7z x -aoa -si"gst-plugins-ugly-%GSTREAMER_VERSION%.tar" || goto end
  @rem if not exist "gst-plugins-ugly-%GSTREAMER_VERSION%" tar -xvf "%DOWNLOADS_PATH%\gst-plugins-ugly-%GSTREAMER_VERSION%.tar.xz" || goto end
  cd "gst-plugins-ugly-%GSTREAMER_VERSION%" || goto end
)

if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload --auto-features=disabled -Dnls=disabled -Dorc=enabled -Dtests=disabled -Ddoc=disabled -Dgpl=enabled -Dasfdemux=enabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@rem if not exist "%PREFIX_PATH%\bin\gstreamer-1.0" mkdir "%PREFIX_PATH%\bin\gstreamer-1.0" || goto end
@rem if exist "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" move /Y "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" "%PREFIX_PATH%\bin\gstreamer-1.0\" || goto end

@set CFLAGS=

@goto continue


:gst-libav

@echo Building gst-libav

@set CFLAGS=-I%PREFIX_PATH_FORWARD%/include

cd "%BUILD_PATH%" || goto end

if "%GST_DEV%" == "ON" @(
  if not exist "gst-libav" mkdir "gst-libav" || goto end
  cd "gst-libav" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\gstreamer\subprojects\gst-libav" . || goto end
) else @(
  if not exist "gst-libav-%GSTREAMER_VERSION%" 7z x "%DOWNLOADS_PATH%\gst-libav-%GSTREAMER_VERSION%.tar.xz" -so | 7z x -aoa -si"gst-libav-%GSTREAMER_VERSION%.tar" || goto end
  @rem if not exist "gst-libav-%GSTREAMER_VERSION%" tar -xvf "%DOWNLOADS_PATH%\gst-libav-%GSTREAMER_VERSION%.tar.xz" || goto end
  cd "gst-libav-%GSTREAMER_VERSION%" || goto end
)

if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --pkg-config-path="%PREFIX_PATH%\lib\pkgconfig" --wrap-mode=nodownload -Dtests=disabled -Ddoc=disabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@rem if not exist "%PREFIX_PATH%\bin\gstreamer-1.0" mkdir "%PREFIX_PATH%\bin\gstreamer-1.0" || goto end
@rem if exist "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" move /Y "%PREFIX_PATH%\lib\gstreamer-1.0\"*".dll" "%PREFIX_PATH%\bin\gstreamer-1.0\" || goto end

@set CFLAGS=

@goto continue


:gst-plugins-rs

@echo Building gst-plugins-rs

@rem Workaround gstspotify.dll failing to link when PKG_CONFIG_PATH is set.
@set PKG_CONFIG_PATH=

cd "%BUILD_PATH%" || goto end

if not exist "gst-plugins-rs" git clone --recurse-submodules --depth 1 -b "%GSTREAMER_GST_PLUGINS_RS_VERSION%" https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs || goto end
cd "gst-plugins-rs" || goto end

if not exist "build\build.ninja" meson setup --buildtype="%MESON_BUILD_TYPE%" --default-library=shared --prefix="%PREFIX_PATH%" --wrap-mode=nodownload --auto-features=disabled -Dexamples=disabled -Dtests=disabled -Dspotify=enabled build || goto end
cd build || goto end
ninja || goto end
ninja install || goto end

@set PKG_CONFIG_PATH=%PREFIX_PATH%\lib\pkgconfig

@goto continue


:sparsehash

@echo Building sparsehash

cd "%BUILD_PATH%" || goto end
if not exist "sparsehash-sparsehash-%SPARSEHASH_VERSION%" tar -xvf "%DOWNLOADS_PATH%\sparsehash-%SPARSEHASH_VERSION%.tar.gz" || goto end
cd "sparsehash-sparsehash-%SPARSEHASH_VERSION%" || goto end
patch -p1 -N < "%DOWNLOADS_PATH%/sparsehash-msvc.patch"
if not exist "%PREFIX_PATH%\include\google" mkdir "%PREFIX_PATH%\include\google" || goto end
if not exist "%PREFIX_PATH%\include\sparsehash" mkdir "%PREFIX_PATH%\include\sparsehash" || goto end
xcopy /s /y "src\google" "%PREFIX_PATH%\include\google\" || goto end
xcopy /s /y "src\sparsehash" "%PREFIX_PATH%\include\sparsehash\" || goto end
xcopy /s /y "src\windows\sparsehash\internal\sparseconfig.h" "%PREFIX_PATH%\include\sparsehash\internal\" || goto end
xcopy /s /y "src\windows\google\sparsehash\sparseconfig.h" "%PREFIX_PATH%\include\google\sparsehash\" || goto end

@echo "Create sparsehash pc file"

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo.>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo Name: sparsehash>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo Description: C++ associative containers>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo URL: https://github.com/sparsehash/sparsehash>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo Version: %SPARSEHASH_VERSION%>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%/lib/pkgconfig/libsparsehash.pc"

@goto continue


:rapidjson

@echo Building rapidjson

cd "%BUILD_PATH%" || goto end
@rem if not exist "rapidjson-%RAPIDJSON_VERSION%" tar -xvf "%DOWNLOADS_PATH%\rapidjson-%RAPIDJSON_VERSION%.tar.gz" || goto end
@rem cd "rapidjson-%RAPIDJSON_VERSION%" || goto end
if not exist "rapidjson" @(
  mkdir "rapidjson" || goto end
  cd "rapidjson" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\rapidjson" . || goto end
  cd ..
 ) || goto end
cd "rapidjson" || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DBUILD_TESTING=OFF -DRAPIDJSON_BUILD_TESTS=OFF -DRAPIDJSON_BUILD_EXAMPLES=OFF -DRAPIDJSON_BUILD_DOC=OFF -DCMAKE_INSTALL_DIR="%PREFIX_PATH_FORWARD%\lib\cmake\RapidJSON" || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:abseil-cpp

@echo Building abseil-cpp

cd "%BUILD_PATH%" || goto end
if not exist "abseil-cpp-%ABSEIL_VERSION%" tar -xvf "%DOWNLOADS_PATH%\abseil-cpp-%ABSEIL_VERSION%.tar.gz" || goto end
cd "abseil-cpp-%ABSEIL_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF -DABSL_BUILD_TESTING=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:protobuf

@echo Building protobuf

cd "%BUILD_PATH%" || goto end
if not exist "protobuf-%PROTOBUF_VERSION%" tar -xvf "%DOWNLOADS_PATH%\protobuf-%PROTOBUF_VERSION%.tar.gz" || goto end
cd "protobuf-%PROTOBUF_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -Dprotobuf_BUILD_SHARED_LIBS=ON -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_EXAMPLES=OFF -Dprotobuf_ABSL_PROVIDER="package" -Dprotobuf_BUILD_LIBPROTOC=OFF -Dprotobuf_BUILD_PROTOC_BINARIES=ON -Dprotobuf_WITH_ZLIB=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end
copy /y "protobuf.pc" "%PREFIX_PATH%\lib\pkgconfig\" || goto end

@goto continue


:qtbase

@echo Building qtbase

cd "%BUILD_PATH%" || goto end

if "%QT_DEV%" == "ON" @(
  if not exist "qtbase" mkdir "qtbase" || goto end
  cd "qtbase" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\qtbase" . || goto end
) else @(
  if not exist "qtbase-everywhere-src-%QT_VERSION%" 7z x "%DOWNLOADS_PATH%\qtbase-everywhere-src-%QT_VERSION%.tar.xz" -so | 7z x -aoa -si"qtbase-everywhere-src-%QT_VERSION%.tar" || goto end
  @rem if not exist "qtbase-everywhere-src-%QT_VERSION%" tar -xvf "%DOWNLOADS_PATH%\qtbase-everywhere-src-%QT_VERSION%.tar.xz" || goto end
  cd "qtbase-everywhere-src-%QT_VERSION%" || goto end
)

if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G Ninja -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DPKG_CONFIG_EXECUTABLE="%PREFIX_PATH_FORWARD%/bin/pkgconf.exe" -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_BENCHMARKS=OFF -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF -DQT_BUILD_TOOLS_BY_DEFAULT=ON -DQT_WILL_BUILD_TOOLS=ON -DBUILD_WITH_PCH=OFF -DFEATURE_rpath=OFF -DFEATURE_pkg_config=ON -DFEATURE_accessibility=ON -DFEATURE_brotli=ON -DFEATURE_fontconfig=OFF -DFEATURE_freetype=ON -DFEATURE_harfbuzz=ON -DFEATURE_pcre2=ON -DFEATURE_schannel=ON -DFEATURE_openssl=ON -DFEATURE_openssl_linked=ON -DFEATURE_opengl=ON -DFEATURE_opengl_dynamic=ON -DFEATURE_use_gold_linker_alias=OFF -DFEATURE_glib=ON -DFEATURE_icu=ON -DFEATURE_directfb=OFF -DFEATURE_dbus=OFF -DFEATURE_sql=ON -DFEATURE_sql_sqlite=ON -DFEATURE_sql_odbc=OFF -DFEATURE_jpeg=ON -DFEATURE_png=ON -DFEATURE_gif=ON -DFEATURE_style_windows=ON -DFEATURE_style_windowsvista=ON -DFEATURE_style_windows11=ON -DFEATURE_system_zlib=ON -DFEATURE_system_png=ON -DFEATURE_system_jpeg=ON -DFEATURE_system_pcre2=ON -DFEATURE_system_freetype=ON -DFEATURE_system_harfbuzz=ON -DFEATURE_system_sqlite=ON -DICU_ROOT="%PREFIX_PATH_FORWARD%" || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:qttools

@echo Building qttools

cd "%BUILD_PATH%" || goto end

if "%QT_DEV%" == "ON" @(
  if not exist "qttools" @(
    mkdir "qttools" || goto end
    cd "qttools" || goto end
    xcopy /s /y /h "%DOWNLOADS_PATH%\qttools" . || goto end
  )
) else (
  if not exist "qttools-everywhere-src-%QT_VERSION%" 7z x "%DOWNLOADS_PATH%\qttools-everywhere-src-%QT_VERSION%.tar.xz" -so | 7z x -aoa -si"qttools-everywhere-src-%QT_VERSION%.tar" || goto end
  @rem if not exist "qttools-everywhere-src-%QT_VERSION%" tar -xvf "%DOWNLOADS_PATH%\qttools-everywhere-src-%QT_VERSION%.tar.xz" || goto end
  cd "qttools-everywhere-src-%QT_VERSION%" || goto end
)

if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G Ninja -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_PREFIX_PATH="%PREFIX_PATH_FORWARD%/lib/cmake" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF -DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING=ON -DFEATURE_assistant=OFF -DFEATURE_designer=OFF -DFEATURE_distancefieldgenerator=OFF -DFEATURE_kmap2qmap=OFF -DFEATURE_pixeltool=OFF -DFEATURE_qdbus=OFF -DFEATURE_qev=OFF -DFEATURE_qtattributionsscanner=OFF -DFEATURE_qtdiag=OFF -DFEATURE_qtplugininfo=OFF -DFEATURE_linguist=ON
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:qtgrpc

@echo Building qtgrpc

cd "%BUILD_PATH%" || goto end

if "%QT_DEV%" == "ON" @(
  if not exist "qtgrpc" @(
    mkdir "qtgrpc" || goto end
    cd "qtgrpc" || goto end
    xcopy /s /y /h "%DOWNLOADS_PATH%\qtgrpc" . || goto end
  )
) else (
  if not exist "qtgrpc-everywhere-src-%QT_VERSION%" 7z x "%DOWNLOADS_PATH%\qtgrpc-everywhere-src-%QT_VERSION%.tar.xz" -so | 7z x -aoa -si"qtgrpc-everywhere-src-%QT_VERSION%.tar" || goto end
  @rem if not exist "qtgrpc-everywhere-src-%QT_VERSION%" tar -xvf "%DOWNLOADS_PATH%\qtgrpc-everywhere-src-%QT_VERSION%.tar.xz" || goto end
  cd "qtgrpc-everywhere-src-%QT_VERSION%" || goto end
)

if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G Ninja -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_PREFIX_PATH="%PREFIX_PATH_FORWARD%/lib/cmake" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF -DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING=ON
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:qtsparkle

@echo Building qtsparkle

cd "%BUILD_PATH%" || goto end
if not exist "qtsparkle" @(
  mkdir "qtsparkle" || goto end
  cd "qtsparkle" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\qtsparkle" . || goto end
  cd ..
 ) || goto end
cd "qtsparkle" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DBUILD_WITH_QT6=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_PREFIX_PATH="%PREFIX_PATH_FORWARD%/lib/cmake" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:kdsingleapplication

@echo Building KDSingleApplication

cd "%BUILD_PATH%" || goto end
if not exist "kdsingleapplication-%KDSINGLEAPPLICATION_VERSION%" tar -xvf "%DOWNLOADS_PATH%\kdsingleapplication-%KDSINGLEAPPLICATION_VERSION%.tar.gz" || goto end
cd "kdsingleapplication-%KDSINGLEAPPLICATION_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_PREFIX_PATH="%PREFIX_PATH_FORWARD%/lib/cmake" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DKDSingleApplication_QT6=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end


@goto continue


:glew

@echo Building glew

cd "%BUILD_PATH%" || goto end
if not exist "glew-%GLEW_VERSION%" tar -xvf "%DOWNLOADS_PATH%\glew-%GLEW_VERSION%.tgz" || goto end
cd "glew-%GLEW_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S build\cmake -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:libprojectm

@echo Building libprojectm

cd "%BUILD_PATH%" || goto end
if not exist "libprojectm-%LIBPROJECTM_VERSION%" tar -xvf "%DOWNLOADS_PATH%\libprojectm-%LIBPROJECTM_VERSION%.tar.gz" || goto end
cd "libprojectm-%LIBPROJECTM_VERSION%" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

@goto continue


:gettext

@echo Installing gettext

cd "%BUILD_PATH%" || goto end
if not exist gettext mkdir gettext || goto end
cd gettext || goto end
7z x -aoa "%DOWNLOADS_PATH%\gettext%GETTEXT_VERSION%-iconv1.17-static-64.zip" || goto end
xcopy /s /y "bin\*.exe" "%PREFIX_PATH%\bin\" || goto end

@goto continue


:tinysvcmdns

@echo Building tinysvcmdns

cd "%BUILD_PATH%" || goto end
if not exist "tinysvcmdns" @(
  mkdir "tinysvcmdns" || goto end
  cd "tinysvcmdns" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\tinysvcmdns" . || goto end
  cd ..
 ) || goto end
cd "tinysvcmdns" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DBUILD_SHARED_LIBS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

xcopy /y "*.lib" "%PREFIX_PATH%\lib\" || goto end
xcopy /y "*.dll" "%PREFIX_PATH%\bin\" || goto end
xcopy /y "*.exe" "%PREFIX_PATH%\bin\" || goto end
xcopy /y "*.h" "%PREFIX_PATH%\include\" || goto end
xcopy /y "..\*.h" "%PREFIX_PATH%\include\" || goto end

@echo prefix=%PREFIX_PATH_FORWARD%> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo exec_prefix=%PREFIX_PATH_FORWARD%>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo libdir=%PREFIX_PATH_FORWARD%/lib>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo includedir=%PREFIX_PATH_FORWARD%/include>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo.>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo Name: tinysvcmdns>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo Description: tinysvcmdns>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo Version: 0.1>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo Libs: -L${libdir} -ltinysvcmdns>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"
@echo Cflags: -I${includedir}>> "%PREFIX_PATH%\lib\pkgconfig\tinysvcmdns.pc"

@goto continue


:strawberry

@echo Building strawberry

cd "%BUILD_PATH%" || goto end
if not exist "strawberry" @(
  mkdir "strawberry" || goto end
  cd "strawberry" || goto end
  xcopy /s /y /h "%DOWNLOADS_PATH%\strawberry" . || goto end
  cd ..
 ) || goto end
cd "strawberry" || goto end
if not exist build mkdir build || goto end
cmake --log-level="DEBUG" -S . -B build -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DCMAKE_PREFIX_PATH="%PREFIX_PATH_FORWARD%/lib/cmake" -DCMAKE_INSTALL_PREFIX="%PREFIX_PATH_FORWARD%" -DARCH=x86_64 -DENABLE_TRANSLATIONS=ON -DBUILD_WERROR=ON -DENABLE_WIN32_CONSOLE=OFF -DICU_ROOT="%PREFIX_PATH%" -DENABLE_AUDIOCD=OFF -DENABLE_MTP=OFF -DENABLE_GPOD=OFF || goto end
cd build || goto end
cmake --build . || goto end
cmake --install . || goto end

if not exist gio-modules mkdir gio-modules || goto end
if not exist platforms mkdir platforms || goto end
if not exist styles mkdir styles || goto end
if not exist tls mkdir tls || goto end
if not exist sqldrivers mkdir sqldrivers || goto end
if not exist imageformats mkdir imageformats || goto end
if not exist gstreamer-plugins mkdir gstreamer-plugins || goto end

@rem copy /y "%prefix_path%\bin\abseil_dll.dll" || goto end
copy /y "%prefix_path%\bin\avcodec*.dll" || goto end
copy /y "%prefix_path%\bin\avfilter*.dll" || goto end
copy /y "%prefix_path%\bin\avformat*.dll" || goto end
copy /y "%prefix_path%\bin\avutil*.dll" || goto end
copy /y "%prefix_path%\bin\brotlicommon.dll" || goto end
copy /y "%prefix_path%\bin\brotlidec.dll" || goto end
copy /y "%prefix_path%\bin\chromaprint.dll" || goto end
copy /y "%prefix_path%\bin\ebur128.dll" || goto end
copy /y "%prefix_path%\bin\faad-2.dll" || goto end
copy /y "%prefix_path%\bin\fdk-aac.dll" || goto end
copy /y "%prefix_path%\bin\ffi-7.dll" || goto end
copy /y "%prefix_path%\bin\flac.dll" || goto end
copy /y "%prefix_path%\bin\freetype%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\gio-2.0-0.dll" || goto end
copy /y "%prefix_path%\bin\glib-2.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gme.dll" || goto end
copy /y "%prefix_path%\bin\gmodule-2.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gnutls%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\gobject-2.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gst-discoverer-1.0.exe" || goto end
copy /y "%prefix_path%\bin\gst-launch-1.0.exe" || goto end
copy /y "%prefix_path%\bin\gst-play-1.0.exe" || goto end
copy /y "%prefix_path%\bin\gstadaptivedemux-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstapp-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstaudio-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstbadaudio-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstbase-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstcodecparsers-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstfft-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstisoff-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstmpegts-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstnet-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstpbutils-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstreamer-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstriff-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstrtp-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstrtsp-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstsdp-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gsttag-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gsturidownloader-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstvideo-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\gstwinrt-1.0-0.dll" || goto end
copy /y "%prefix_path%\bin\harfbuzz*.dll" || goto end
copy /y "%prefix_path%\bin\icudt*.dll" || goto end
copy /y "%prefix_path%\bin\icuin*%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\icuuc*%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\intl-8.dll" || goto end
copy /y "%prefix_path%\bin\jpeg62.dll" || goto end
copy /y "%prefix_path%\bin\libbs2b.dll" || goto end
copy /y "%prefix_path%\bin\libcrypto-3-x64.dll" || goto end
copy /y "%prefix_path%\bin\libfaac_dll.dll" || goto end
copy /y "%prefix_path%\bin\libfftw3-3.dll" || goto end
copy /y "%prefix_path%\bin\libiconv%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\liblzma.dll" || goto end
copy /y "%prefix_path%\bin\libmp3lame.dll" || goto end
copy /y "%prefix_path%\bin\libopenmpt.dll" || goto end
copy /y "%prefix_path%\bin\libpng16%LIB_POSTFIX%.dll" || goto end
@rem copy /y "%prefix_path%\bin\libprotobuf*.dll" || goto end
copy /y "%prefix_path%\bin\libspeex%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\libssl-3-x64.dll" || goto end
copy /y "%prefix_path%\bin\libxml2%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\mpcdec.dll" || goto end
copy /y "%prefix_path%\bin\mpg123.dll" || goto end
copy /y "%prefix_path%\bin\nghttp2.dll" || goto end
copy /y "%prefix_path%\bin\ogg.dll" || goto end
copy /y "%prefix_path%\bin\opus.dll" || goto end
copy /y "%prefix_path%\bin\orc-0.4-0.dll" || goto end
copy /y "%prefix_path%\bin\pcre2-16%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\pcre2-8%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\postproc*.dll" || goto end
copy /y "%prefix_path%\bin\psl-5.dll" || goto end
copy /y "%prefix_path%\bin\qt6concurrent%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\qt6core%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\qt6gui%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\qt6network%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\qt6sql%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\qt6widgets%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\qtsparkle-qt6.dll" || goto end
copy /y "%prefix_path%\bin\soup-3.0-0.dll" || goto end
copy /y "%prefix_path%\bin\sqlite3.dll" || goto end
copy /y "%prefix_path%\bin\sqlite3.exe" || goto end
copy /y "%prefix_path%\bin\swresample*.dll" || goto end
copy /y "%prefix_path%\bin\swscale*.dll" || goto end
copy /y "%prefix_path%\bin\tag.dll" || goto end
copy /y "%prefix_path%\bin\twolame%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\vorbis.dll" || goto end
copy /y "%prefix_path%\bin\vorbisfile.dll" || goto end
copy /y "%prefix_path%\bin\wavpackdll.dll" || goto end
copy /y "%prefix_path%\bin\zlib%LIB_POSTFIX%1.dll" || goto end
copy /y "%prefix_path%\bin\kdsingleapplication*.dll" || goto end
@rem copy /y "%prefix_path%\bin\utf8_validity.dll" || goto end
copy /y "%prefix_path%\bin\getopt.dll" || goto end
copy /y "%prefix_path%\bin\gmp%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\nettle%LIB_POSTFIX%.dll" || goto end
copy /y "%prefix_path%\bin\hogweed%LIB_POSTFIX%.dll" || goto end

copy /y "%PREFIX_PATH%\lib\gio\modules\*.dll" ".\gio-modules\" || goto end
copy /y "%PREFIX_PATH%\plugins\platforms\qwindows*.dll" ".\platforms\" || goto end
copy /y "%PREFIX_PATH%\plugins\styles\qmodernwindowsstyle*.dll" ".\styles\" || goto end
copy /y "%PREFIX_PATH%\plugins\tls\*.dll" ".\tls\" || goto end
copy /y "%PREFIX_PATH%\plugins\sqldrivers\qsqlite*.dll" ".\sqldrivers\" || goto end
copy /y "%PREFIX_PATH%\plugins\imageformats\*.dll" ".\imageformats\" || goto end

copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstadaptivedemux2.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaes.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaiff.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstapetag.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstapp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstasf.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstasfmux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstasio.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudioconvert.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudiofx.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudioparsers.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstaudioresample.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstautodetect.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstbs2b.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstcoreelements.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstdash.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstdsd.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstdirectsound.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstequalizer.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstfaac.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstfaad.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstfdkaac.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstflac.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstgio.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstgme.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsthls.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsticydemux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstid3demux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstid3tag.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstisomp4.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstlame.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstlibav.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstmpegpsdemux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstmpegpsmux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstmpegtsdemux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstmpegtsmux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstmpg123.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstmusepack.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstogg.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstopenmpt.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstopus.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstopusparse.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstpbtypes.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstplayback.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstreplaygain.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstrtp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstrtsp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstsoup.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstspectrum.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstspeex.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsttaglib.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsttcp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsttwolame.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gsttypefindfunctions.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstudp.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstvolume.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstvorbis.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwasapi.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwasapi2.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwaveform.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwavenc.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwavpack.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstwavparse.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstxingmux.dll" ".\gstreamer-plugins\" || goto end
copy /y "%PREFIX_PATH%\lib\gstreamer-1.0\gstspotify.dll" ".\gstreamer-plugins\" || goto end

copy /y "..\COPYING" . || goto end
copy /y "..\dist\windows\*.nsh" . || goto end
copy /y "..\dist\windows\*.ico" . || goto end

xcopy /y "%DOWNLOADS_PATH%\vc_redist.x86.exe" .
xcopy /y "%DOWNLOADS_PATH%\vc_redist.x64.exe" .

makensis "strawberry.nsi" || goto end


@goto continue


:end

@endlocal
