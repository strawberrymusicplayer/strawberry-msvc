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
curl -O -L -k https://github.com/git-for-windows/git/releases/download/v2.36.0.windows.1/Git-2.36.0-64-bit.exe || goto end
"%DOWNLOADS_PATH%\Git-2.36.0-64-bit.exe" /silent /norestart || goto end

@goto install


:check

@git --help >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Git\bin

@git --help >NUL 2>&1 || @(
  @echo "Missing git."
  @goto end
)


:start


@for %%x in (
https://boostorg.jfrog.io/artifactory/main/release/1.80.0/source/boost_1_80_0.tar.gz
https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-1.9.3.tar.gz
https://zlib.net/zlib-1.2.12.tar.gz
https://www.openssl.org/source/openssl-3.0.5.tar.gz
https://github.com/ShiftMediaProject/gnutls/releases/download/3.7.7/libgnutls_3.7.7_msvc17.zip
https://downloads.sourceforge.net/project/libpng/libpng16/1.6.38/libpng-1.6.38.tar.gz
https://sourceforge.net/projects/libjpeg-turbo/files/2.1.4/libjpeg-turbo-2.1.4.tar.gz
https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2
https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
https://tukaani.org/xz/xz-5.2.7.tar.bz2
https://github.com/google/brotli/archive/refs/tags/v1.0.9.tar.gz
https://www.cairographics.org/releases/pixman-0.40.0.tar.gz
https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.10.2/libxml2-v2.10.2.tar.bz2
https://github.com/nghttp2/nghttp2/releases/download/v1.50.0/nghttp2-1.50.0.tar.bz2
https://sqlite.org/2022/sqlite-autoconf-3390400.tar.gz
https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.gz
https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.gz
https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.4.1.tar.xz
https://www.wavpack.com/wavpack-5.5.0.tar.bz2
https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
https://ftp.osuosl.org/pub/xiph/releases/opus/opusfile-0.12.tar.gz
https://downloads.sourceforge.net/project/mpg123/mpg123/1.30.2/mpg123-1.30.2.tar.bz2
https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
https://taglib.org/releases/taglib-1.12.tar.gz
https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/v1.3.0.tar.gz
https://www.fftw.org/fftw-3.3.10.tar.gz
https://fftw.org/pub/fftw/fftw-3.3.5-dll64.zip
https://github.com/acoustid/chromaprint/releases/download/v1.5.1/chromaprint-1.5.1.tar.gz
https://download.gnome.org/sources/glib/2.74/glib-2.74.0.tar.xz
https://download.gnome.org/sources/glib-networking/2.74/glib-networking-2.74.0.tar.xz
https://github.com/rockdaboot/libpsl/releases/download/0.21.1/libpsl-0.21.1.tar.gz
https://download.gnome.org/sources/libsoup/3.2/libsoup-3.2.0.tar.xz
https://gstreamer.freedesktop.org/src/orc/orc-0.4.32.tar.xz
https://files.musepack.net/source/musepack_src_r475.tar.gz
https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-0.6.6+release.msvc.zip
https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-2.0.2.tar.gz
https://downloads.sourceforge.net/project/bs2b/libbs2b/3.1.0/libbs2b-3.1.0.tar.bz2
https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.20.3.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.20.3.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.20.3.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.20.3.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-1.20.3.tar.xz
https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-1.20.3.tar.xz
https://github.com/protocolbuffers/protobuf/releases/download/v21.7/protobuf-cpp-3.21.7.tar.gz
https://jztkft.dl.sourceforge.net/project/expat/expat/2.4.9/expat-2.4.9.tar.bz2
https://netix.dl.sourceforge.net/project/freetype/freetype2/2.12.1/freetype-2.12.1.tar.gz
https://github.com/unicode-org/icu/archive/release-71-1.tar.gz
https://cairographics.org/releases/cairo-1.16.0.tar.xz
https://github.com/harfbuzz/harfbuzz/releases/download/5.2.0/harfbuzz-5.2.0.tar.xz
https://download.qt.io/official_releases/qt/6.4/6.4.0/submodules/qtbase-everywhere-src-6.4.0.tar.xz
https://download.qt.io/official_releases/qt/6.4/6.4.0/submodules/qttools-everywhere-src-6.4.0.tar.xz
https://bitbucket.org/mpyne/game-music-emu/downloads/game-music-emu-0.6.3.tar.gz
https://github.com/unicode-org/icu/releases/download/release-71-1/icu4c-71_1-src.zip
https://downloads.sourceforge.net/twolame/twolame-0.4.0.tar.gz
https://aka.ms/vs/17/release/vs_community.exe
https://github.com/git-for-windows/git/releases/download/v2.36.0.windows.1/Git-2.36.0-64-bit.exe
https://github.com/Kitware/CMake/releases/download/v3.24.0/cmake-3.24.0-windows-x86_64.msi
https://github.com/mesonbuild/meson/releases/download/0.63.2/meson-0.63.2-64.msi
https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-installer-x64.exe
http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe
https://github.com/lexxmark/winflexbison/releases/download/v2.5.25/win_flex_bison-2.5.25.zip
https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit.msi
https://www.python.org/ftp/python/3.10.4/python-3.10.4-amd64.exe
https://www.7-zip.org/a/7z2107-x64.exe
https://files.jkvinge.net/winbins/sed.exe
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
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/icu-fixes.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/xz-config.patch
) do @(
  if not exist %%~nxx (
    echo Downloading %%~nxx
    curl -O -L -k %%x
  )
)

@for %%x in (
https://github.com/xiph/speex
https://github.com/knik0/faad2
https://github.com/knik0/faac
https://github.com/pffang/libiconv-for-Windows
https://github.com/davidsansome/qtsparkle
https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi
https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg.git
https://github.com/frida/proxy-libintl
https://github.com/strawberrymusicplayer/strawberry
) do @(
  if exist %%~nxx @(
    echo Udating repostiory %%x
    cd %%~nxx
	git pull
	cd ..
  ) else (
    echo Cloning repostiory %%x
    git clone %%x
  )
)

:end

@endlocal
