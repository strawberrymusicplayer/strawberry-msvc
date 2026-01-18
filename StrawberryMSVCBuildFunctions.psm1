# StrawberryMSVCBuildFunctions.psm1
# Common functions for building dependencies with CMake, Meson, and MSBuild

<#
.SYNOPSIS
  Invokes a CMake build for a project
.PARAMETER SourcePath
  Path to the source directory
.PARAMETER BuildPath
  Path to the build directory
.PARAMETER Generator
  CMake generator to use (default: Ninja)
.PARAMETER BuildType
  Build type (Debug or Release)
.PARAMETER InstallPrefix
  Installation prefix path
.PARAMETER AdditionalArgs
  Additional CMake arguments
#>
function Invoke-CMakeBuild {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$source_path,

    [Parameter(Mandatory=$true)]
    [string]$build_path,

    [Parameter(Mandatory=$false)]
    [string]$generator = "Ninja",

    [Parameter(Mandatory=$true)]
    [string]$build_type,

    [Parameter(Mandatory=$true)]
    [string]$install_prefix,

    [Parameter(Mandatory=$false)]
    [string[]]$additional_args = @()
  )

  Write-Host "Building with CMake: $source_path" -ForegroundColor Cyan

  if (-not (Test-Path $build_path)) {
    New-Item -ItemType Directory -Path $build_path -Force | Out-Null
  }

  $configure_args = @(
    "--log-level=DEBUG",
    "-S", $source_path,
    "-B", $build_path,
    "-G", $generator,
    "-DCMAKE_BUILD_TYPE=$build_type",
    "-DCMAKE_INSTALL_PREFIX=$install_prefix"
  )

  if ($additional_args) {
    $configure_args += $additional_args
  }

  & cmake @configure_args
  if ($LASTEXITCODE -ne 0) {
    throw "CMake configuration failed"
  }

  Push-Location $build_path
  try {
    & cmake --build .
    if ($LASTEXITCODE -ne 0) {
      throw "CMake build failed"
    }

    & cmake --install .
    if ($LASTEXITCODE -ne 0) {
      throw "CMake install failed"
    }
  }
  finally {
    Pop-Location
  }
}

<#
.SYNOPSIS
  Invokes a Meson build for a project
.PARAMETER SourcePath
  Path to the source directory
.PARAMETER BuildPath
  Path to the build directory
.PARAMETER BuildType
  Build type (debug or release)
.PARAMETER InstallPrefix
  Installation prefix path
.PARAMETER PkgConfigPath
  Path to pkg-config files
.PARAMETER AdditionalArgs
  Additional Meson setup arguments
#>
function Invoke-MesonBuild {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$source_path,

    [Parameter(Mandatory=$true)]
    [string]$build_path,

    [Parameter(Mandatory=$true)]
    [string]$build_type,

    [Parameter(Mandatory=$true)]
    [string]$install_prefix,

    [Parameter(Mandatory=$false)]
    [string]$pkg_config_path,

    [Parameter(Mandatory=$false)]
    [string[]]$additional_args = @()
  )

  Write-Host "Building with Meson: $source_path" -ForegroundColor Cyan

  Push-Location $source_path
  try {
    if (-not (Test-Path "$build_path\build.ninja")) {
      $setup_args = @(
        "setup",
        "--buildtype=$build_type",
        "--default-library=shared",
        "--prefix=$install_prefix",
        "--wrap-mode=nodownload"
      )

      if ($pkg_config_path) {
        $setup_args += "--pkg-config-path=$pkg_config_path"
      }

      if ($additional_args) {
        $setup_args += $additional_args
      }

      $setup_args += $build_path

      & meson @setup_args
      if ($LASTEXITCODE -ne 0) {
        throw "Meson setup failed"
      }
    }

    Push-Location $build_path
    try {
      & ninja
      if ($LASTEXITCODE -ne 0) {
        throw "Ninja build failed"
      }

      & ninja install
      if ($LASTEXITCODE -ne 0) {
        throw "Ninja install failed"
      }
    }
    finally {
      Pop-Location
    }
  }
  finally {
    Pop-Location
  }
}

<#
.SYNOPSIS
  Invokes an MSBuild for a project
.PARAMETER ProjectPath
  Path to the solution or project file
.PARAMETER Configuration
  Build configuration (Debug or Release)
.PARAMETER Platform
  Build platform (default: x64)
.PARAMETER AdditionalArgs
  Additional MSBuild arguments
#>
function Invoke-MSBuildProject {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$project_path,

    [Parameter(Mandatory=$true)]
    [string]$configuration,

    [Parameter(Mandatory=$false)]
    [string]$platform = "x64",

    [Parameter(Mandatory=$false)]
    [string[]]$additional_args = @()
  )

  Write-Host "Building with MSBuild: $project_path" -ForegroundColor Cyan

  $build_args = @(
    $project_path,
    "/p:Configuration=$configuration"
  )

  if ($platform) {
    $build_args += "/p:Platform=$platform"
  }

  if ($additional_args) {
    $build_args += $additional_args
  }

  & msbuild @build_args
  if ($LASTEXITCODE -ne 0) {
    throw "MSBuild failed"
  }
}

<#
.SYNOPSIS
  Upgrades a Visual Studio project file
.PARAMETER ProjectPath
  Path to the project file
#>
function Update-VSProject {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$project_path
  )

  Write-Host "Upgrading Visual Studio project: $project_path" -ForegroundColor Cyan

  $devenv_path = & "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.com" 2>&1
  if ($LASTEXITCODE -ne 0) {
    $devenv_path = & "${env:ProgramFiles}\Microsoft Visual Studio\2026\Community\Common7\IDE\devenv.com" 2>&1
  }

  Start-Process -FilePath "devenv.exe" -ArgumentList "$project_path /upgrade" -Wait -NoNewWindow
}

<#
.SYNOPSIS
  Downloads a file if it doesn't already exist
.PARAMETER Url
  URL to download from
.PARAMETER DestinationPath
  Path to save the file
#>
function Get-FileIfNotExists {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$url,

    [Parameter(Mandatory=$true)]
    [string]$destination_path
  )

  $file_name = Split-Path $url -Leaf
  $file_path = Join-Path $destination_path $file_name

  if (-not (Test-Path $file_path)) {
    Write-Host "Downloading $file_name" -ForegroundColor Yellow
    try {
      Invoke-WebRequest -Uri $url -OutFile $file_path -UseBasicParsing
    }
    catch {
      Write-Error "Failed to download $url : $_"
      throw
    }
  }
}

<#
.SYNOPSIS
  Clones or updates a Git repository
.PARAMETER Url
  Git repository URL
.PARAMETER DestinationPath
  Path to clone to
#>
function Sync-GitRepository {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$url,

    [Parameter(Mandatory=$true)]
    [string]$destination_path
  )

  $repo_name = Split-Path $url -Leaf
  $repo_path = Join-Path $destination_path $repo_name

  if (Test-Path $repo_path) {
    Write-Host "Updating repository $url" -ForegroundColor Yellow
    Push-Location $repo_path
    try {
      & git pull --rebase
      if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to update repository $url"
      }
    }
    finally {
      Pop-Location
    }
  }
  else {
    Write-Host "Cloning repository $url" -ForegroundColor Yellow
    & git clone --recurse-submodules $url $repo_path
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to clone repository $url"
    }
  }
}

<#
.SYNOPSIS
  Extracts a compressed archive
.PARAMETER ArchivePath
  Path to the archive file
.PARAMETER DestinationPath
  Path to extract to
#>
function Expand-Archive7Zip {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$archive_path,

    [Parameter(Mandatory=$true)]
    [string]$destination_path
  )

  if (-not (Test-Path $archive_path)) {
    throw "Archive not found: $archive_path"
  }

  & 7z x -aoa $archive_path -o"$destination_path"
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to extract archive: $archive_path"
  }
}

<#
.SYNOPSIS
  Tests if a command exists
.PARAMETER Command
  Command name to test
#>
function Test-Command {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$command
  )

  $null = Get-Command $command -ErrorAction SilentlyContinue
  return $?
}

<#
.SYNOPSIS
  Ensures a command is available in PATH
.PARAMETER Command
  Command name to check
.PARAMETER Path
  Path to add to PATH if command is not found
.PARAMETER ErrorMessage
  Error message to display if command is not found
#>
function Assert-Command {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$command,

    [Parameter(Mandatory=$false)]
    [string]$path,

    [Parameter(Mandatory=$true)]
    [string]$error_message
  )

  if (-not (Test-Command $command)) {
    if ($path -and (Test-Path $path)) {
      $env:PATH = "$path;$env:PATH"
    }

    if (-not (Test-Command $command)) {
      throw $error_message
    }
  }
}

<#
.SYNOPSIS
  Creates a pkg-config .pc file
.PARAMETER Name
  Package name
.PARAMETER Description
  Package description
.PARAMETER Version
  Package version
.PARAMETER Prefix
  Installation prefix
.PARAMETER Libs
  Library flags
.PARAMETER Cflags
  Compiler flags
.PARAMETER Requires
  Required packages
.PARAMETER OutputPath
  Path to save the .pc file
#>
function New-PkgConfigFile {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$name,

    [Parameter(Mandatory=$true)]
    [string]$description,

    [Parameter(Mandatory=$true)]
    [string]$version,

    [Parameter(Mandatory=$true)]
    [string]$prefix,

    [Parameter(Mandatory=$false)]
    [string]$libs = "",

    [Parameter(Mandatory=$false)]
    [string]$cflags = "",

    [Parameter(Mandatory=$false)]
    [string]$requires = "",

    [Parameter(Mandatory=$true)]
    [string]$output_path
  )

  $content = @"
prefix=$prefix
exec_prefix=`${prefix}
libdir=`${exec_prefix}/lib
includedir=`${prefix}/include

Name: $name
Description: $description
Version: $version
"@

  if ($requires) {
    $content += "`nRequires: $requires"
  }

  if ($libs) {
    $content += "`nLibs: -L`${libdir} $libs"
  }

  if ($cflags) {
    $content += "`nCflags: $cflags"
  }

  Set-Content -Path $output_path -Value $content -Encoding ASCII
}

<#
.SYNOPSIS
  Gets the list of dependency download URLs
.DESCRIPTION
  Returns an object containing package URLs and Git repository URLs for all dependencies.
  URLs are organized in a hashtable with package names as keys.
  This centralizes the download configuration so it can be used by both StrawberryMSVCDownload.ps1 and StrawberryMSVCBuild.ps1.
.EXAMPLE
  $deps = Get-DependencyUrls
  foreach ($package_name in $deps.PackageUrls.Keys) { ... }
  foreach ($repo_name in $deps.GitRepos.Keys) { ... }
#>
function Get-DependencyUrls {
  [CmdletBinding()]
  param()

  # Note: Requires versions.ps1 to be loaded by the caller
  # Both StrawberryMSVCDownload.ps1 and StrawberryMSVCBuild.ps1 already do this

  # Return hashtable mapping package names to download URLs
  $package_urls = @{
    'ccache' = "https://github.com/ccache/ccache/releases/download/v$ccache_version/ccache-$ccache_version.tar.gz"
    'boost' = "https://archives.boost.io/release/$boost_version/source/boost_$boost_version_UNDERSCORE.tar.gz"
    'pkg-config' = "https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
    'pkgconf' = "https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-$pkgconf_version.tar.gz"
    'mimalloc' = "https://github.com/microsoft/mimalloc/archive/refs/tags/v$mimalloc_version/mimalloc-$mimalloc_version.tar.gz"
    'zlib' = "https://zlib.net/zlib-$zlib_version.tar.gz"
    'openssl' = "https://github.com/openssl/openssl/releases/download/openssl-$openssl_version/openssl-$openssl_version.tar.gz"
    'gnutls-prebuilt' = "https://github.com/ShiftMediaProject/gnutls/releases/download/$gnutls_version/libgnutls_$($gnutls_version)_msvc17.zip"
    'libpng' = "https://downloads.sourceforge.net/project/libpng/libpng16/$libpng_version/libpng-$libpng_version.tar.gz"
    'libjpeg-turbo' = "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/$libjpeg_version/libjpeg-turbo-$libjpeg_version.tar.gz"
    'pcre2' = "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$pcre2_version/pcre2-$pcre2_version.tar.gz"
    'bzip2' = "https://sourceware.org/pub/bzip2/bzip2-$bzip2_version.tar.gz"
    'xz' = "https://downloads.sourceforge.net/project/lzmautils/xz-$xz_version.tar.gz"
    'brotli' = "https://github.com/google/brotli/archive/refs/tags/v$brotli_version/brotli-$brotli_version.tar.gz"
    'pixman' = "https://www.cairographics.org/releases/pixman-$pixman_version.tar.gz"
    'libxml2' = "https://gitlab.gnome.org/GNOME/libxml2/-/archive/v$libxml2_version/libxml2-v$libxml2_version.tar.gz"
    'nghttp2' = "https://github.com/nghttp2/nghttp2/releases/download/v$nghttp2_version/nghttp2-$nghttp2_version.tar.gz"
    'sqlite' = "https://sqlite.org/2025/sqlite-autoconf-$sqlite_version.tar.gz"
    'libogg' = "https://downloads.xiph.org/releases/ogg/libogg-$libogg_version.tar.gz"
    'libvorbis' = "https://downloads.xiph.org/releases/vorbis/libvorbis-$libvorbis_version.tar.gz"
    'flac' = "https://ftp.osuosl.org/pub/xiph/releases/flac/flac-$flac_version.tar.xz"
    'wavpack' = "https://www.wavpack.com/wavpack-$wavpack_version.tar.bz2"
    'opus' = "https://downloads.xiph.org/releases/opus/opus-$opus_version.tar.gz"
    'opusfile' = "https://ftp.osuosl.org/pub/xiph/releases/opus/opusfile-$opusfile_version.tar.gz"
    'speex' = "https://gitlab.xiph.org/xiph/speex/-/archive/Speex-$speex_version/speex-Speex-$speex_version.tar.gz"
    'mpg123' = "https://downloads.sourceforge.net/project/mpg123/mpg123/$mpg123_version/mpg123-$mpg123_version.tar.bz2"
    'lame' = "https://downloads.sourceforge.net/project/lame/lame/$lame_version/lame-$lame_version.tar.gz"
    'utfcpp' = "https://github.com/nemtrif/utfcpp/archive/refs/tags/v$utfcpp_version/utfcpp-$utfcpp_version.tar.gz"
    'taglib' = "https://taglib.org/releases/taglib-$taglib_version.tar.gz"
    'dlfcn-win32' = "https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/v$dlfcn_version/dlfcn-win32-$dlfcn_version.tar.gz"
    'fftw-debug' = "https://files.strawberrymusicplayer.org/fftw-$fftw_version-x64-debug.zip"
    'fftw-release' = "https://files.strawberrymusicplayer.org/fftw-$fftw_version-x64-release.zip"
    'chromaprint' = "https://github.com/acoustid/chromaprint/releases/download/v$chromaprint_version/chromaprint-$chromaprint_version.tar.gz"
    'glib' = "https://download.gnome.org/sources/glib/2.87/glib-$glib_version.tar.xz"
    'glib-networking' = "https://download.gnome.org/sources/glib-networking/2.80/glib-networking-$glib_networking_version.tar.xz"
    'libpsl' = "https://github.com/rockdaboot/libpsl/releases/download/$libpsl_version/libpsl-$libpsl_version.tar.gz"
    'libproxy' = "https://github.com/libproxy/libproxy/archive/refs/tags/$libproxy_version/libproxy-$libproxy_version.tar.gz"
    'libsoup' = "https://download.gnome.org/sources/libsoup/3.6/libsoup-$libsoup_version.tar.xz"
    'orc' = "https://gstreamer.freedesktop.org/src/orc/orc-$orc_version.tar.xz"
    'musepack' = "https://files.musepack.net/source/musepack_src_r$musepack_version.tar.gz"
    'libopenmpt' = "https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-$libopenmpt_version+release.msvc.zip"
    'faad2' = "https://github.com/knik0/faad2/tarball/$faad2_version/faad2-$faad2_version.tar.gz"
    'faac' = "https://github.com/knik0/faac/archive/refs/tags/faac-$faac_version.tar.gz"
    'fdk-aac' = "https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-$fdk_aac_version.tar.gz"
    'libbs2b' = "https://downloads.sourceforge.net/project/bs2b/libbs2b/$libbs2b_version/libbs2b-$libbs2b_version.tar.bz2"
    'libebur128' = "https://github.com/jiixyj/libebur128/archive/refs/tags/v$libebur128_version/libebur128-$libebur128_version.tar.gz"
    'gstreamer' = "https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-$gstreamer_version.tar.xz"
    'gst-plugins-base' = "https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-$gstreamer_version.tar.xz"
    'gst-plugins-good' = "https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-$gstreamer_version.tar.xz"
    'gst-plugins-bad' = "https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-$gstreamer_version.tar.xz"
    'gst-plugins-ugly' = "https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-$gstreamer_version.tar.xz"
    'gst-libav' = "https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-$gstreamer_version.tar.xz"
    'protobuf' = "https://github.com/protocolbuffers/protobuf/releases/download/v$protobuf_version/protobuf-$protobuf_version.tar.gz"
    'glew' = "https://downloads.sourceforge.net/project/glew/glew/$glew_version/glew-$glew_version.tgz"
    'libprojectm' = "https://github.com/projectM-visualizer/projectm/releases/download/v$libprojectm_version/libprojectm-$libprojectm_version.tar.gz"
    'expat' = "https://github.com/libexpat/libexpat/releases/download/R_$expat_version_UNDERSCORE/expat-$expat_version.tar.gz"
    'freetype' = "https://downloads.sourceforge.net/project/freetype/freetype2/$freetype_version/freetype-$freetype_version.tar.gz"
    'icu4c' = "https://github.com/unicode-org/icu/releases/download/release-$icu4c_version/icu4c-$icu4c_version-sources.tgz"
    'cairo' = "https://cairographics.org/releases/cairo-$cairo_version.tar.xz"
    'harfbuzz' = "https://github.com/harfbuzz/harfbuzz/releases/download/$harfbuzz_version/harfbuzz-$harfbuzz_version.tar.xz"
    'qtbase' = "https://download.qt.io/official_releases/qt/6.10/$qt_version/submodules/qtbase-everywhere-src-$qt_version.tar.xz"
    'qttools' = "https://download.qt.io/official_releases/qt/6.10/$qt_version/submodules/qttools-everywhere-src-$qt_version.tar.xz"
    'qtgrpc' = "https://download.qt.io/official_releases/qt/6.10/$qt_version/submodules/qtgrpc-everywhere-src-$qt_version.tar.xz"
    'libgme' = "https://github.com/libgme/game-music-emu/releases/download/$libgme_version/libgme-$libgme_version-src.tar.gz"
    'twolame' = "https://downloads.sourceforge.net/twolame/twolame-$twolame_version.tar.gz"
    'sparsehash' = "https://github.com/sparsehash/sparsehash/archive/refs/tags/sparsehash-$sparsehash_version.tar.gz"
    'rapidjson' = "https://github.com/Tencent/rapidjson/archive/refs/tags/v$rapidjson_version/rapidjson-$rapidjson_version.tar.gz"
    'abseil-cpp' = "https://github.com/abseil/abseil-cpp/archive/refs/tags/$abseil_version/abseil-cpp-$abseil_version.tar.gz"
    'kdsingleapplication' = "https://github.com/KDAB/KDSingleApplication/releases/download/v$kdsingleapplication_version/kdsingleapplication-$kdsingleapplication_version.tar.gz"
    'getopt-win' = "https://github.com/ludvikjerabek/getopt-win/archive/refs/tags/v$getopt_win_version/getopt-win-$getopt_win_version.tar.gz"
    'pe-parse' = "https://github.com/trailofbits/pe-parse/archive/refs/tags/v$peparse_version/pe-parse-$peparse_version.tar.gz"
    'curl' = "https://github.com/curl/curl/releases/download/curl-$curl_version_UNDERSCORE/curl-$curl_version.tar.gz"
    'gettext' = "https://github.com/mlocati/gettext-iconv-windows/releases/download/v$gettext_version-v1.17/gettext$gettext_version-iconv1.17-static-64.zip"
    'git' = "https://github.com/git-for-windows/git/releases/download/v$git_version.windows.1/Git-$git_version-64-bit.exe"
    'cmake' = "https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version-windows-x86_64.msi"
    'nasm' = "https://www.nasm.us/pub/nasm/releasebuilds/$nasm_version/win64/nasm-$nasm_version-installer-x64.exe"
    'winflexbison' = "https://github.com/lexxmark/winflexbison/releases/download/v$winflexbison_version/win_flex_bison-$winflexbison_version.zip"
    'strawberry-perl' = "https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_$($strawberry_perl_version_STRIPPED)_64bit_UCRT/strawberry-perl-$strawberry_perl_version-64bit.msi"
    'python' = "https://www.python.org/ftp/python/$python_version/python-$python_version-amd64.exe"
    '7zip' = "https://7-zip.org/a/7z$_7zip_version-x64.exe"
    'nsis' = "https://prdownloads.sourceforge.net/nsis/nsis-$nsis_version-setup.exe"
    'nsis-lockedlist' = "https://nsis.sourceforge.io/mediawiki/images/d/d3/LockedList.zip"
    'nsis-registry' = "https://nsis.sourceforge.io/mediawiki/images/4/47/Registry.zip"
    'nsis-inetc' = "https://nsis.sourceforge.io/mediawiki/images/c/c9/Inetc.zip"
    'sed' = "https://files.jkvinge.net/winbins/sed.exe"
    'rustup' = "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
    'vc-redist-x86' = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
    'vc-redist-x64' = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    'patch-libpng-pkgconf' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libpng-pkgconf.patch"
    'patch-bzip2-cmake' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/bzip2-cmake.patch"
    'patch-opusfile-cmake' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/opusfile-cmake.patch"
    'patch-speex-cmake' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/speex-cmake.patch"
    'patch-musepack-fixes' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/musepack-fixes.patch"
    'patch-libopenmpt-cmake' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libopenmpt-cmake.patch"
    'patch-faac-msvc' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/faac-msvc.patch"
    'patch-gst-plugins-bad-meson-dependency' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/gst-plugins-bad-meson-dependency.patch"
    'patch-libbs2b-msvc' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libbs2b-msvc.patch"
    'patch-twolame' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/twolame.patch"
    'patch-sparsehash-msvc' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/sparsehash-msvc.patch"
    'patch-yasm-cmake' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/yasm-cmake.patch"
    'patch-libgme-pkgconf' = "https://raw.githubusercontent.com/strawberrymusicplayer/strawberry-msvc-dependencies/master/patches/libgme-pkgconf.patch"
  }

  $git_repos = @{
    'qtbase-git' = "https://code.qt.io/qt/qtbase"
    'qttools-git' = "https://code.qt.io/qt/qttools"
    'libiconv' = "https://github.com/pffang/libiconv-for-Windows"
    'qtsparkle' = "https://github.com/strawberrymusicplayer/qtsparkle"
    'libffi' = "https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi"
    'ffmpeg' = "https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg"
    'proxy-libintl' = "https://github.com/frida/proxy-libintl"
    'gstreamer-git' = "https://gitlab.freedesktop.org/gstreamer/gstreamer"
    'gst-plugins-rs' = "https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs"
    'tinysvcmdns' = "https://github.com/Pro/tinysvcmdns"
    'rapidjson-git' = "https://github.com/Tencent/rapidjson"
    'yasm' = "https://github.com/yasm/yasm"
    'vsyasm' = "https://github.com/ShiftMediaProject/VSYASM"
    'gmp' = "https://github.com/ShiftMediaProject/gmp"
    'nettle' = "https://github.com/ShiftMediaProject/nettle"
    'gnutls' = "https://github.com/ShiftMediaProject/gnutls"
    'pe-util' = "https://github.com/gsauthof/pe-util"
    'strawberry' = "https://github.com/strawberrymusicplayer/strawberry"
  }

  return [PSCustomObject]@{
    PackageUrls = $package_urls
    GitRepos = $git_repos
  }
}

<#
.SYNOPSIS
  Gets the download URL for a specific package
.PARAMETER PackageName
  Name of the package to get URL for
.EXAMPLE
  $url = Get-PackageUrl -PackageName "zlib"
#>
function Get-PackageUrl {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$package_name
  )

  $deps = Get-DependencyUrls

  if ($deps.PackageUrls.ContainsKey($package_name)) {
    return $deps.PackageUrls[$package_name]
  }
  elseif ($deps.GitRepos.ContainsKey($package_name)) {
    return $deps.GitRepos[$package_name]
  }
  else {
    throw "Package '$package_name' not found in dependency URLs"
  }
}

<#
.SYNOPSIS
  Downloads a specific package if it doesn't exist
.PARAMETER PackageName
  Name of the package to download
.PARAMETER DownloadsPath
  Path where the download will be stored
.EXAMPLE
  Invoke-PackageDownload -PackageName "zlib" -DownloadsPath "c:\downloads"
#>
function Invoke-PackageDownload {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$package_name,

    [Parameter(Mandatory=$true)]
    [string]$downloads_path
  )

  Write-Host "Checking package: $package_name" -ForegroundColor Cyan

  # Ensure downloads directory exists
  if (-not (Test-Path $downloads_path)) {
    New-Item -ItemType Directory -Path $downloads_path -Force | Out-Null
  }

  try {
    $deps = Get-DependencyUrls

    # Check if it's a regular download URL
    if ($deps.PackageUrls.ContainsKey($package_name)) {
      $url = $deps.PackageUrls[$package_name]
      Get-FileIfNotExists -url $url -destination_path $downloads_path
      Write-Host "✓ Package $package_name is available" -ForegroundColor Green
    }
    # Check if it's a Git repository
    elseif ($deps.GitRepos.ContainsKey($package_name)) {
      $url = $deps.GitRepos[$package_name]
      Sync-GitRepository -url $url -destination_path $downloads_path
      Write-Host "✓ Repository $package_name is available" -ForegroundColor Green
    }
    else {
      Write-Warning "Package '$package_name' not found in dependency configuration"
    }
  }
  catch {
    Write-Warning "Failed to download package $package_name : $_"
    throw
  }
}

<#
.SYNOPSIS
  Downloads all dependencies if they don't exist
.PARAMETER DownloadsPath
  Path where downloads will be stored
.EXAMPLE
  Invoke-DependencyDownload -DownloadsPath "c:\downloads"
#>
function Invoke-DependencyDownload {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$downloads_path
  )

  Write-Host "Downloading dependencies to: $downloads_path" -ForegroundColor Cyan

  # Ensure downloads directory exists
  if (-not (Test-Path $downloads_path)) {
    New-Item -ItemType Directory -Path $downloads_path -Force | Out-Null
  }

  # Get dependency URLs
  $deps = Get-DependencyUrls

  # Download files
  Write-Host "`nDownloading dependency files..." -ForegroundColor Green
  foreach ($package_name in $deps.PackageUrls.Keys) {
    try {
      $url = $deps.PackageUrls[$package_name]
      Get-FileIfNotExists -Url $url -DestinationPath $downloads_path
    }
    catch {
      Write-Warning "Failed to download $package_name : $_"
    }
  }

  # Clone/update Git repositories
  Write-Host "`nCloning/updating Git repositories..." -ForegroundColor Green
  foreach ($repo_name in $deps.GitRepos.Keys) {
    try {
      $url = $deps.GitRepos[$repo_name]
      Sync-GitRepository -Url $url -DestinationPath $downloads_path
    }
    catch {
      Write-Warning "Failed to sync repository $repo_name : $_"
    }
  }

  Write-Host "`nDependency download completed!" -ForegroundColor Green
}

Export-ModuleMember -Function @(
  'Invoke-CMakeBuild',
  'Invoke-MesonBuild',
  'Invoke-MSBuildProject',
  'Update-VSProject',
  'Get-FileIfNotExists',
  'Sync-GitRepository',
  'Expand-Archive7Zip',
  'Test-Command',
  'Assert-Command',
  'New-PkgConfigFile',
  'Get-DependencyUrls',
  'Get-PackageUrl',
  'Invoke-PackageDownload',
  'Invoke-DependencyDownload'
)
