@ECHO ON

@setlocal

@set DOWNLOADS_PATH="c:\data\projects\strawberry\msvc_\downloads"

:setup

@c: || goto end
@cd \ || goto end
@if not exist  "%DOWNLOADS_PATH%" mkdir "%DOWNLOADS_PATH%"
@cd "%DOWNLOADS_PATH%" || goto end


@curl --help >NUL 2>&1 || @(
  @echo "Missing curl."
  @goto end
)

:install


@if not exist "C:\Program Files\Git\bin\git.exe" goto git


@goto check


:git

@echo Installing git...

cd "%DOWNLOADS_PATH%" || goto end
curl -O -L -k https://github.com/git-for-windows/git/releases/download/v2.40.0.windows.1/Git-2.40.0-64-bit.exe || goto end
"%DOWNLOADS_PATH%\Git-2.40.0-64-bit.exe" /silent /norestart || goto end

@goto install


:check

@git --help >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Git\bin

@git --help >NUL 2>&1 || @(
  @echo "Missing git."
  @goto end
)


:start


@for %%x in (
https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.gz
https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-1.9.5.tar.gz
https://github.com/microsoft/mimalloc/archive/refs/tags/v2.1.2.tar.gz
https://zlib.net/zlib-1.2.13.tar.gz
https://www.openssl.org/source/openssl-3.1.1.tar.gz
https://github.com/ShiftMediaProject/gnutls/releases/download/3.8.0/libgnutls_3.8.0_msvc17.zip
https://downloads.sourceforge.net/project/libpng/libpng16/1.6.40/libpng-1.6.40.tar.gz
https://downloads.sourceforge.net/project/libjpeg-turbo/3.0.0/libjpeg-turbo-3.0.0.tar.gz
https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.41/pcre2-10.41.tar.bz2
https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
https://tukaani.org/xz/xz-5.4.3.tar.bz2
https://github.com/google/brotli/archive/refs/tags/v1.0.9.tar.gz
https://www.cairographics.org/releases/pixman-0.42.2.tar.gz
https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.11.4/libxml2-v2.11.4.tar.bz2
https://github.com/nghttp2/nghttp2/releases/download/v1.55.1/nghttp2-1.55.1.tar.bz2
https://sqlite.org/2023/sqlite-autoconf-3420000.tar.gz
https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.gz
https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.gz
https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.4.3.tar.xz
https://www.wavpack.com/wavpack-5.6.0.tar.bz2
https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
https://ftp.osuosl.org/pub/xiph/releases/opus/opusfile-0.12.tar.gz
https://gitlab.xiph.org/xiph/speex/-/archive/Speex-1.2.1/speex-Speex-1.2.1.tar.gz
https://downloads.sourceforge.net/project/mpg123/mpg123/1.31.3/mpg123-1.31.3.tar.bz2
https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
https://taglib.org/releases/taglib-1.13.1.tar.gz
https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/v1.4.1.tar.gz
https://files.strawberrymusicplayer.org/fftw-3.3.10-x64-debug.zip
https://files.strawberrymusicplayer.org/fftw-3.3.10-x64-release.zip
https://github.com/acoustid/chromaprint/releases/download/v1.5.1/chromaprint-1.5.1.tar.gz
https://download.gnome.org/sources/glib/2.77/glib-2.77.0.tar.xz
https://download.gnome.org/sources/glib-networking/2.76/glib-networking-2.76.1.tar.xz
https://github.com/rockdaboot/libpsl/releases/download/0.21.2/libpsl-0.21.2.tar.gz
https://github.com/libproxy/libproxy/releases/download/0.4.18/libproxy-0.4.18.tar.xz
https://download.gnome.org/sources/libsoup/3.4/libsoup-3.4.2.tar.xz
https://gstreamer.freedesktop.org/src/orc/orc-0.4.34.tar.xz
https://files.musepack.net/source/musepack_src_r475.tar.gz
https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-0.7.2+release.msvc.zip
https://github.com/knik0/faad2/tarball/2.10.1/faad2-2.10.1.tar.gz
https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-2.0.2.tar.gz
https://downloads.sourceforge.net/project/bs2b/libbs2b/3.1.0/libbs2b-3.1.0.tar.bz2
https://github.com/jiixyj/libebur128/archive/refs/tags/v1.2.6.tar.gz
https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.22.5.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.22.5.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.22.5.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.22.5.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-1.22.5.tar.xz
https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-1.22.5.tar.xz
https://github.com/protocolbuffers/protobuf/releases/download/v23.4/protobuf-23.4.tar.gz
https://downloads.sourceforge.net/project/expat/expat/2.5.0/expat-2.5.0.tar.bz2
https://downloads.sourceforge.net/project/freetype/freetype2/2.13.1/freetype-2.13.1.tar.gz
https://github.com/unicode-org/icu/archive/release-73-1.tar.gz
https://cairographics.org/releases/cairo-1.16.0.tar.xz
https://github.com/harfbuzz/harfbuzz/releases/download/8.0.1/harfbuzz-8.0.1.tar.xz
https://download.qt.io/official_releases/qt/6.5/6.5.2/submodules/qtbase-everywhere-src-6.5.2.tar.xz
https://download.qt.io/official_releases/qt/6.5/6.5.2/submodules/qttools-everywhere-src-6.5.2.tar.xz
https://bitbucket.org/mpyne/game-music-emu/downloads/game-music-emu-0.6.3.tar.gz
https://github.com/unicode-org/icu/releases/download/release-73-1/icu4c-73_1-src.zip
https://downloads.sourceforge.net/twolame/twolame-0.4.0.tar.gz
https://github.com/abseil/abseil-cpp/archive/refs/tags/20230125.3.tar.gz
https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-64-bit.exe
https://github.com/Kitware/CMake/releases/download/v3.26.0/cmake-3.26.0-windows-x86_64.msi
https://github.com/mesonbuild/meson/releases/download/1.0.1/meson-1.0.1-64.msi
https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/win64/nasm-2.16.01-installer-x64.exe
http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
https://github.com/lexxmark/winflexbison/releases/download/v2.5.25/win_flex_bison-2.5.25.zip
https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit.msi
https://www.python.org/ftp/python/3.11.2/python-3.11.2-amd64.exe
https://7-zip.org/a/7z2201-x64.exe
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libpng-pkgconf.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/bzip2-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/opusfile-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/speex-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/glib-networking-tests.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/musepack-fixes.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libopenmpt-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/faad2-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/faac-msvc.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/gst-plugins-bad-libpaths.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libbs2b-msvc.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/qtsparkle-msvc.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/twolame.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/icu-uwp.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libpsl-time.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/qtbase-tabbar.patch
) do @(
  if not exist %%~nxx (
    echo Downloading %%~nxx
    curl -O -L -k %%x
  )
)

@for %%x in (
https://code.qt.io/qt/qtbase
https://code.qt.io/qt/qttools
https://github.com/knik0/faac
https://github.com/pffang/libiconv-for-Windows
https://github.com/davidsansome/qtsparkle
https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi
https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg
https://github.com/frida/proxy-libintl
https://gitlab.freedesktop.org/gstreamer/gstreamer
https://github.com/strawberrymusicplayer/strawberry
) do @(
  if exist %%~nxx @(
    echo Updating repository %%x
    cd %%~nxx
	git pull
	cd ..
  ) else (
    echo Cloning repository %%x
    git clone %%x
  )
)

:end

@endlocal
