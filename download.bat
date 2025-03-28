@ECHO ON

@setlocal

@set DOWNLOADS_PATH="c:\data\projects\strawberry\msvc_\downloads"

@call versions.bat

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
curl -O -L -k https://github.com/git-for-windows/git/releases/download/v%GIT_VERSION%.windows.1/Git-%GIT_VERSION%-64-bit.exe || goto end
"%DOWNLOADS_PATH%\Git-%GIT_VERSION%-64-bit.exe" /silent /norestart || goto end

@goto install


:check

@git --help >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\Git\bin

@git --help >NUL 2>&1 || @(
  @echo "Missing git."
  @goto end
)


:start


@for %%x in (
https://archives.boost.io/release/1.87.0/source/boost_%BOOST_VERSION_UNDERSCORE%.tar.gz
https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-%PKGCONF_VERSION%.tar.gz
https://github.com/microsoft/mimalloc/archive/refs/tags/v%MIMALLOC_VERSION%/mimalloc-%MIMALLOC_VERSION%.tar.gz
https://zlib.net/zlib-%ZLIB_VERSION%.tar.gz
https://github.com/openssl/openssl/releases/download/openssl-%OPENSSL_VERSION%/openssl-%OPENSSL_VERSION%.tar.gz
https://github.com/ShiftMediaProject/gnutls/releases/download/%GNUTLS_VERSION%/libgnutls_%GNUTLS_VERSION%_msvc17.zip
https://downloads.sourceforge.net/project/libpng/libpng16/%LIBPNG_VERSION%/libpng-%LIBPNG_VERSION%.tar.gz
https://downloads.sourceforge.net/project/libjpeg-turbo/%LIBJPEG_VERSION%/libjpeg-turbo-%LIBJPEG_VERSION%.tar.gz
https://github.com/PhilipHazel/pcre2/releases/download/pcre2-%PCRE2_VERSION%/pcre2-%PCRE2_VERSION%.tar.bz2
https://sourceware.org/pub/bzip2/bzip2-%BZIP2_VERSION%.tar.gz
https://downloads.sourceforge.net/project/lzmautils/xz-%XZ_VERSION%.tar.gz
https://github.com/google/brotli/archive/refs/tags/v%BROTLI_VERSION%/brotli-%BROTLI_VERSION%.tar.gz
https://www.cairographics.org/releases/pixman-%PIXMAN_VERSION%.tar.gz
https://gitlab.gnome.org/GNOME/libxml2/-/archive/v%LIBXML2_VERSION%/libxml2-v%LIBXML2_VERSION%.tar.bz2
https://github.com/nghttp2/nghttp2/releases/download/v%NGHTTP2_VERSION%/nghttp2-%NGHTTP2_VERSION%.tar.bz2
https://sqlite.org/2025/sqlite-autoconf-%SQLITE_VERSION%.tar.gz
https://downloads.xiph.org/releases/ogg/libogg-%LIBOGG_VERSION%.tar.gz
https://downloads.xiph.org/releases/vorbis/libvorbis-%LIBVORBIS_VERSION%.tar.gz
https://ftp.osuosl.org/pub/xiph/releases/flac/flac-%FLAC_VERSION%.tar.xz
https://www.wavpack.com/wavpack-%WAVPACK_VERSION%.tar.bz2
https://downloads.xiph.org/releases/opus-%OPUS_VERSION%.tar.gz
https://ftp.osuosl.org/pub/xiph/releases/opus/opusfile-%OPUSFILE_VERSION%.tar.gz
https://gitlab.xiph.org/xiph/speex/-/archive/Speex-%SPEEX_VERSION%/speex-Speex-%SPEEX_VERSION%.tar.gz
https://downloads.sourceforge.net/project/mpg123/mpg123/%MPG123_VERSION%/mpg123-%MPG123_VERSION%.tar.bz2
https://downloads.sourceforge.net/project/lame/lame/%LAME_VERSION%/lame-%LAME_VERSION%.tar.gz
https://github.com/nemtrif/utfcpp/archive/refs/tags/v%UTFCPP_VERSION%/utfcpp-%UTFCPP_VERSION%.tar.gz
https://taglib.org/releases/taglib-%TAGLIB_VERSION%.tar.gz
https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/v%DLFCN_VERSION%/dlfcn-win32-%DLFCN_VERSION%.tar.gz
https://files.strawberrymusicplayer.org/fftw-%FFTW_VERSION%-x64-debug.zip
https://files.strawberrymusicplayer.org/fftw-%FFTW_VERSION%-x64-release.zip
https://github.com/acoustid/chromaprint/releases/download/v%CHROMAPRINT_VERSION%/chromaprint-%CHROMAPRINT_VERSION%.tar.gz
https://download.gnome.org/sources/glib/2.84/glib-%GLIB_VERSION%.tar.xz
https://download.gnome.org/sources/glib-networking/2.80/glib-networking-%GLIB_NETWORKING_VERSION%.tar.xz
https://github.com/rockdaboot/libpsl/releases/download/%LIBPSL_VERSION%/libpsl-%LIBPSL_VERSION%.tar.gz
https://github.com/libproxy/libproxy/archive/refs/tags/%LIBPROXY_VERSION%/libproxy-%LIBPROXY_VERSION%.tar.gz
https://download.gnome.org/sources/libsoup/3.6/libsoup-%LIBSOUP_VERSION%.tar.xz
https://gstreamer.freedesktop.org/src/orc/orc-%ORC_VERSION%.tar.xz
https://files.musepack.net/source/musepack_src_r%MUSEPACK_VERSION%.tar.gz
https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-%LIBOPENMPT_VERSION%+release.msvc.zip
https://github.com/knik0/faad2/tarball/%FAAD2_VERSION%/faad2-%FAAD2_VERSION%.tar.gz
https://github.com/knik0/faac/archive/refs/tags/faac-%FAAC_VERSION%.tar.gz
https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-%FDK_AAC_VERSION%.tar.gz
https://downloads.sourceforge.net/project/bs2b/libbs2b/%LIBBS2B_VERSION%/libbs2b-%LIBBS2B_VERSION%.tar.bz2
https://github.com/jiixyj/libebur128/archive/refs/tags/v%LIBEBUR128_VERSION%/libebur128-%LIBEBUR128_VERSION%.tar.gz
https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-%GSTREAMER_VERSION%.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-%GSTREAMER_VERSION%.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-%GSTREAMER_VERSION%.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-%GSTREAMER_VERSION%.tar.xz
https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-%GSTREAMER_VERSION%.tar.xz
https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-%GSTREAMER_VERSION%.tar.xz
https://github.com/protocolbuffers/protobuf/releases/download/v%PROTOBUF_VERSION%/protobuf-%PROTOBUF_VERSION%.tar.gz
https://downloads.sourceforge.net/project/glew/glew/%GLEW_VERSION%/glew-%GLEW_VERSION%.tgz
https://github.com/projectM-visualizer/projectm/releases/download/v%LIBPROJECTM_VERSION%/libprojectm-%LIBPROJECTM_VERSION%.tar.gz
https://github.com/libexpat/libexpat/releases/download/R_%EXPAT_VERSION_UNDERSCORE%/expat-%EXPAT_VERSION%.tar.bz2
https://downloads.sourceforge.net/project/freetype/freetype2/%FREETYPE_VERSION%/freetype-%FREETYPE_VERSION%.tar.gz
https://github.com/unicode-org/icu/releases/download/release-%ICU4C_VERSION_DASH%/icu4c-%ICU4C_VERSION_UNDERSCORE%-src.zip
https://cairographics.org/releases/cairo-%CAIRO_VERSION%.tar.xz
https://github.com/harfbuzz/harfbuzz/releases/download/%HARFBUZZ_VERSION%/harfbuzz-%HARFBUZZ_VERSION%.tar.xz
https://download.qt.io/official_releases/qt/6.8/%QT_VERSION%/submodules/qtbase-everywhere-src-%QT_VERSION%.tar.xz
https://download.qt.io/official_releases/qt/6.8/%QT_VERSION%/submodules/qttools-everywhere-src-%QT_VERSION%.tar.xz
https://download.qt.io/official_releases/qt/6.8/%QT_VERSION%/submodules/qtgrpc-everywhere-src-%QT_VERSION%.tar.xz
https://github.com/libgme/game-music-emu/releases/download/%LIBGME_VERSION%/libgme-%LIBGME_VERSION%-src.tar.gz
https://downloads.sourceforge.net/twolame/twolame-%TWOLAME_VERSION%.tar.gz
https://github.com/sparsehash/sparsehash/archive/refs/tags/sparsehash-%SPARSEHASH_VERSION%.tar.gz
https://github.com/Tencent/rapidjson/archive/refs/tags/v%RAPIDJSON_VERSION%/rapidjson-%RAPIDJSON_VERSION%.tar.gz
https://github.com/abseil/abseil-cpp/archive/refs/tags/%ABSEIL_VERSION%/abseil-cpp-%ABSEIL_VERSION%.tar.gz
https://github.com/KDAB/KDSingleApplication/releases/download/v%KDSINGLEAPPLICATION_VERSION%/kdsingleapplication-%KDSINGLEAPPLICATION_VERSION%.tar.gz
https://github.com/curl/curl/releases/download/curl-%CURL_VERSION_UNDERSCORE%/curl-%CURL_VERSION%.tar.gz
https://github.com/mlocati/gettext-iconv-windows/releases/download/v%GETTEXT_VERSION%-v1.17/gettext%GETTEXT_VERSION%-iconv1.17-static-64.zip
https://github.com/git-for-windows/git/releases/download/v%GIT_VERSION%.windows.1/Git-%GIT_VERSION%-64-bit.exe
https://github.com/Kitware/CMake/releases/download/v%CMAKE_VERSION%/cmake-%CMAKE_VERSION%-windows-x86_64.msi
https://github.com/mesonbuild/meson/releases/download/%MESON_VERSION%/meson-%MESON_VERSION%-64.msi
https://www.nasm.us/pub/nasm/releasebuilds/%NASM_VERSION%/win64/nasm-%NASM_VERSION%-installer-x64.exe
http://www.tortall.net/projects/yasm/releases/yasm-%YASM_VERSION%.tar.gz
https://github.com/lexxmark/winflexbison/releases/download/v%WINFLEXBISON_VERSION%/win_flex_bison-%WINFLEXBISON_VERSION%.zip
https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_%STRAWBERRY_PERL_VERSION_STRIPPED%_64bit/strawberry-perl-%STRAWBERRY_PERL_VERSION%-64bit.msi
https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe
https://7-zip.org/a/7z%_7ZIP_VERSION%-x64.exe
https://prdownloads.sourceforge.net/nsis/nsis-%NSIS_VERSION%-setup.exe
https://nsis.sourceforge.io/mediawiki/images/d/d3/LockedList.zip
https://nsis.sourceforge.io/mediawiki/images/4/47/Registry.zip
https://nsis.sourceforge.io/mediawiki/images/c/c9/Inetc.zip
https://files.jkvinge.net/winbins/sed.exe
https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe
https://aka.ms/vs/17/release/vc_redist.x86.exe
https://aka.ms/vs/17/release/vc_redist.x64.exe
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libpng-pkgconf.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/bzip2-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/opusfile-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/speex-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/musepack-fixes.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libopenmpt-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/faac-msvc.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/gst-plugins-bad-meson-dependency.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libbs2b-msvc.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/qtsparkle-fixes.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/twolame.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/getopt-win-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/sparsehash-msvc.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/yasm-cmake.patch
https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libgme-pkgconf.patch
) do @(
  if not exist %%~nxx (
    echo Downloading %%~nxx
    curl -f -O -L -k %%x
  )
)

@for %%x in (
https://code.qt.io/qt/qtbase
https://code.qt.io/qt/qttools
https://github.com/pffang/libiconv-for-Windows
https://github.com/davidsansome/qtsparkle
https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi
https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg
https://github.com/frida/proxy-libintl
https://gitlab.freedesktop.org/gstreamer/gstreamer
https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs
https://github.com/ludvikjerabek/getopt-win
https://github.com/Pro/tinysvcmdns
https://github.com/Tencent/rapidjson
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
