# BuildFunctions.psm1
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
    [string]$SourcePath,
        
    [Parameter(Mandatory=$true)]
    [string]$BuildPath,
        
    [Parameter(Mandatory=$false)]
    [string]$Generator = "Ninja",
        
    [Parameter(Mandatory=$true)]
    [string]$BuildType,
        
    [Parameter(Mandatory=$true)]
    [string]$InstallPrefix,
        
    [Parameter(Mandatory=$false)]
    [string[]]$AdditionalArgs = @()
  )
    
  Write-Host "Building with CMake: $SourcePath" -ForegroundColor Cyan
    
  if (-not (Test-Path $BuildPath)) {
    New-Item -ItemType Directory -Path $BuildPath -Force | Out-Null
  }
    
  $configureArgs = @(
    "--log-level=DEBUG",
    "-S", $SourcePath,
    "-B", $BuildPath,
    "-G", $Generator,
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DCMAKE_INSTALL_PREFIX=$InstallPrefix"
  )
    
  if ($AdditionalArgs) {
    $configureArgs += $AdditionalArgs
  }
    
  & cmake @configureArgs
  if ($LASTEXITCODE -ne 0) {
    throw "CMake configuration failed"
  }
    
  Push-Location $BuildPath
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
    [string]$SourcePath,
        
    [Parameter(Mandatory=$true)]
    [string]$BuildPath,
        
    [Parameter(Mandatory=$true)]
    [string]$BuildType,
        
    [Parameter(Mandatory=$true)]
    [string]$InstallPrefix,
        
    [Parameter(Mandatory=$false)]
    [string]$PkgConfigPath,
        
    [Parameter(Mandatory=$false)]
    [string[]]$AdditionalArgs = @()
  )
    
  Write-Host "Building with Meson: $SourcePath" -ForegroundColor Cyan
    
  Push-Location $SourcePath
  try {
    if (-not (Test-Path "$BuildPath\build.ninja")) {
      $setupArgs = @(
        "setup",
        "--buildtype=$BuildType",
        "--default-library=shared",
        "--prefix=$InstallPrefix",
        "--wrap-mode=nodownload"
      )
            
      if ($PkgConfigPath) {
        $setupArgs += "--pkg-config-path=$PkgConfigPath"
      }
            
      if ($AdditionalArgs) {
        $setupArgs += $AdditionalArgs
      }
            
      $setupArgs += $BuildPath
            
      & meson @setupArgs
      if ($LASTEXITCODE -ne 0) {
        throw "Meson setup failed"
      }
    }
        
    Push-Location $BuildPath
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
    [string]$ProjectPath,
        
    [Parameter(Mandatory=$true)]
    [string]$Configuration,
        
    [Parameter(Mandatory=$false)]
    [string]$Platform = "x64",
        
    [Parameter(Mandatory=$false)]
    [string[]]$AdditionalArgs = @()
  )
    
  Write-Host "Building with MSBuild: $ProjectPath" -ForegroundColor Cyan
    
  $buildArgs = @(
    $ProjectPath,
    "/p:Configuration=$Configuration"
  )
    
  if ($Platform) {
    $buildArgs += "/p:Platform=$Platform"
  }
    
  if ($AdditionalArgs) {
    $buildArgs += $AdditionalArgs
  }
    
  & msbuild @buildArgs
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
    [string]$ProjectPath
  )
    
  Write-Host "Upgrading Visual Studio project: $ProjectPath" -ForegroundColor Cyan
    
  $devenvPath = & "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.com" 2>&1
  if ($LASTEXITCODE -ne 0) {
    $devenvPath = & "${env:ProgramFiles}\Microsoft Visual Studio\2026\Community\Common7\IDE\devenv.com" 2>&1
  }
    
  Start-Process -FilePath "devenv.exe" -ArgumentList "$ProjectPath /upgrade" -Wait -NoNewWindow
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
    [string]$Url,
        
    [Parameter(Mandatory=$true)]
    [string]$DestinationPath
  )
    
  $fileName = Split-Path $Url -Leaf
  $filePath = Join-Path $DestinationPath $fileName
    
  if (-not (Test-Path $filePath)) {
    Write-Host "Downloading $fileName" -ForegroundColor Yellow
    try {
      Invoke-WebRequest -Uri $Url -OutFile $filePath -UseBasicParsing
    }
    catch {
      Write-Error "Failed to download $Url : $_"
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
    [string]$Url,
        
    [Parameter(Mandatory=$true)]
    [string]$DestinationPath
  )
    
  $repoName = Split-Path $Url -Leaf
  $repoPath = Join-Path $DestinationPath $repoName
    
  if (Test-Path $repoPath) {
    Write-Host "Updating repository $Url" -ForegroundColor Yellow
    Push-Location $repoPath
    try {
      & git pull --rebase
      if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to update repository $Url"
      }
    }
    finally {
      Pop-Location
    }
  }
  else {
    Write-Host "Cloning repository $Url" -ForegroundColor Yellow
    & git clone --recurse-submodules $Url $repoPath
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to clone repository $Url"
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
    [string]$ArchivePath,
        
    [Parameter(Mandatory=$true)]
    [string]$DestinationPath
  )
    
  if (-not (Test-Path $ArchivePath)) {
    throw "Archive not found: $ArchivePath"
  }
    
  & 7z x -aoa $ArchivePath -o"$DestinationPath"
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to extract archive: $ArchivePath"
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
    [string]$Command
  )
    
  $null = Get-Command $Command -ErrorAction SilentlyContinue
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
    [string]$Command,
        
    [Parameter(Mandatory=$false)]
    [string]$Path,
        
    [Parameter(Mandatory=$true)]
    [string]$ErrorMessage
  )
    
  if (-not (Test-Command $Command)) {
    if ($Path -and (Test-Path $Path)) {
      $env:PATH = "$Path;$env:PATH"
    }
        
    if (-not (Test-Command $Command)) {
      throw $ErrorMessage
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
    [string]$Name,
        
    [Parameter(Mandatory=$true)]
    [string]$Description,
        
    [Parameter(Mandatory=$true)]
    [string]$Version,
        
    [Parameter(Mandatory=$true)]
    [string]$Prefix,
        
    [Parameter(Mandatory=$true)]
    [string]$Libs,
        
    [Parameter(Mandatory=$false)]
    [string]$Cflags = "",
        
    [Parameter(Mandatory=$false)]
    [string]$Requires = "",
        
    [Parameter(Mandatory=$true)]
    [string]$OutputPath
  )
    
  $content = @"
prefix=$Prefix
exec_prefix=`${prefix}
libdir=`${exec_prefix}/lib
includedir=`${prefix}/include

Name: $Name
Description: $Description
Version: $Version
"@
    
  if ($Requires) {
    $content += "`nRequires: $Requires"
  }
    
  $content += "`nLibs: -L`${libdir} $Libs"
    
  if ($Cflags) {
    $content += "`nCflags: $Cflags"
  }
    
  Set-Content -Path $OutputPath -Value $content -Encoding ASCII
}

<#
.SYNOPSIS
  Gets the list of dependency download URLs
.DESCRIPTION
  Returns an object containing package URLs and Git repository URLs for all dependencies.
  URLs are organized in a hashtable with package names as keys.
  This centralizes the download configuration so it can be used by both download.ps1 and build.ps1.
.EXAMPLE
  $deps = Get-DependencyUrls
  foreach ($packageName in $deps.PackageUrls.Keys) { ... }
  foreach ($repoName in $deps.GitRepos.Keys) { ... }
#>
function Get-DependencyUrls {
  [CmdletBinding()]
  param()
  
  # Note: Requires versions.ps1 to be loaded by the caller
  # Both download.ps1 and build.ps1 already do this
  
  # Return hashtable mapping package names to download URLs
  $packageUrls = @{
    'ccache' = "https://github.com/ccache/ccache/releases/download/v$CCACHE_VERSION/ccache-$CCACHE_VERSION.tar.gz"
    'boost' = "https://archives.boost.io/release/$BOOST_VERSION/source/boost_$BOOST_VERSION_UNDERSCORE.tar.gz"
    'pkg-config' = "https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
    'pkgconf' = "https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-$PKGCONF_VERSION.tar.gz"
    'mimalloc' = "https://github.com/microsoft/mimalloc/archive/refs/tags/v$MIMALLOC_VERSION/mimalloc-$MIMALLOC_VERSION.tar.gz"
    'zlib' = "https://zlib.net/zlib-$ZLIB_VERSION.tar.gz"
    'openssl' = "https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/openssl-$OPENSSL_VERSION.tar.gz"
    'gnutls-prebuilt' = "https://github.com/ShiftMediaProject/gnutls/releases/download/$GNUTLS_VERSION/libgnutls_$($GNUTLS_VERSION)_msvc17.zip"
    'libpng' = "https://downloads.sourceforge.net/project/libpng/libpng16/$LIBPNG_VERSION/libpng-$LIBPNG_VERSION.tar.gz"
    'libjpeg-turbo' = "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/$LIBJPEG_VERSION/libjpeg-turbo-$LIBJPEG_VERSION.tar.gz"
    'pcre2' = "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$PCRE2_VERSION/pcre2-$PCRE2_VERSION.tar.gz"
    'bzip2' = "https://sourceware.org/pub/bzip2/bzip2-$BZIP2_VERSION.tar.gz"
    'xz' = "https://downloads.sourceforge.net/project/lzmautils/xz-$XZ_VERSION.tar.gz"
    'brotli' = "https://github.com/google/brotli/archive/refs/tags/v$BROTLI_VERSION/brotli-$BROTLI_VERSION.tar.gz"
    'pixman' = "https://www.cairographics.org/releases/pixman-$PIXMAN_VERSION.tar.gz"
    'libxml2' = "https://gitlab.gnome.org/GNOME/libxml2/-/archive/v$LIBXML2_VERSION/libxml2-v$LIBXML2_VERSION.tar.gz"
    'nghttp2' = "https://github.com/nghttp2/nghttp2/releases/download/v$NGHTTP2_VERSION/nghttp2-$NGHTTP2_VERSION.tar.gz"
    'sqlite' = "https://sqlite.org/2025/sqlite-autoconf-$SQLITE_VERSION.tar.gz"
    'libogg' = "https://downloads.xiph.org/releases/ogg/libogg-$LIBOGG_VERSION.tar.gz"
    'libvorbis' = "https://downloads.xiph.org/releases/vorbis/libvorbis-$LIBVORBIS_VERSION.tar.gz"
    'flac' = "https://ftp.osuosl.org/pub/xiph/releases/flac/flac-$FLAC_VERSION.tar.xz"
    'wavpack' = "https://www.wavpack.com/wavpack-$WAVPACK_VERSION.tar.bz2"
    'opus' = "https://downloads.xiph.org/releases/opus/opus-$OPUS_VERSION.tar.gz"
    'opusfile' = "https://ftp.osuosl.org/pub/xiph/releases/opus/opusfile-$OPUSFILE_VERSION.tar.gz"
    'speex' = "https://gitlab.xiph.org/xiph/speex/-/archive/Speex-$SPEEX_VERSION/speex-Speex-$SPEEX_VERSION.tar.gz"
    'mpg123' = "https://downloads.sourceforge.net/project/mpg123/mpg123/$MPG123_VERSION/mpg123-$MPG123_VERSION.tar.bz2"
    'lame' = "https://downloads.sourceforge.net/project/lame/lame/$LAME_VERSION/lame-$LAME_VERSION.tar.gz"
    'utfcpp' = "https://github.com/nemtrif/utfcpp/archive/refs/tags/v$UTFCPP_VERSION/utfcpp-$UTFCPP_VERSION.tar.gz"
    'taglib' = "https://taglib.org/releases/taglib-$TAGLIB_VERSION.tar.gz"
    'dlfcn-win32' = "https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/v$DLFCN_VERSION/dlfcn-win32-$DLFCN_VERSION.tar.gz"
    'fftw-debug' = "https://files.strawberrymusicplayer.org/fftw-$FFTW_VERSION-x64-debug.zip"
    'fftw-release' = "https://files.strawberrymusicplayer.org/fftw-$FFTW_VERSION-x64-release.zip"
    'chromaprint' = "https://github.com/acoustid/chromaprint/releases/download/v$CHROMAPRINT_VERSION/chromaprint-$CHROMAPRINT_VERSION.tar.gz"
    'glib' = "https://download.gnome.org/sources/glib/2.87/glib-$GLIB_VERSION.tar.xz"
    'glib-networking' = "https://download.gnome.org/sources/glib-networking/2.80/glib-networking-$GLIB_NETWORKING_VERSION.tar.xz"
    'libpsl' = "https://github.com/rockdaboot/libpsl/releases/download/$LIBPSL_VERSION/libpsl-$LIBPSL_VERSION.tar.gz"
    'libproxy' = "https://github.com/libproxy/libproxy/archive/refs/tags/$LIBPROXY_VERSION/libproxy-$LIBPROXY_VERSION.tar.gz"
    'libsoup' = "https://download.gnome.org/sources/libsoup/3.6/libsoup-$LIBSOUP_VERSION.tar.xz"
    'orc' = "https://gstreamer.freedesktop.org/src/orc/orc-$ORC_VERSION.tar.xz"
    'musepack' = "https://files.musepack.net/source/musepack_src_r$MUSEPACK_VERSION.tar.gz"
    'libopenmpt' = "https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-$LIBOPENMPT_VERSION+release.msvc.zip"
    'faad2' = "https://github.com/knik0/faad2/tarball/$FAAD2_VERSION/faad2-$FAAD2_VERSION.tar.gz"
    'faac' = "https://github.com/knik0/faac/archive/refs/tags/faac-$FAAC_VERSION.tar.gz"
    'fdk-aac' = "https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-$FDK_AAC_VERSION.tar.gz"
    'libbs2b' = "https://downloads.sourceforge.net/project/bs2b/libbs2b/$LIBBS2B_VERSION/libbs2b-$LIBBS2B_VERSION.tar.bz2"
    'libebur128' = "https://github.com/jiixyj/libebur128/archive/refs/tags/v$LIBEBUR128_VERSION/libebur128-$LIBEBUR128_VERSION.tar.gz"
    'gstreamer' = "https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-$GSTREAMER_VERSION.tar.xz"
    'gst-plugins-base' = "https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-$GSTREAMER_VERSION.tar.xz"
    'gst-plugins-good' = "https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-$GSTREAMER_VERSION.tar.xz"
    'gst-plugins-bad' = "https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-$GSTREAMER_VERSION.tar.xz"
    'gst-plugins-ugly' = "https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-$GSTREAMER_VERSION.tar.xz"
    'gst-libav' = "https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-$GSTREAMER_VERSION.tar.xz"
    'protobuf' = "https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOBUF_VERSION/protobuf-$PROTOBUF_VERSION.tar.gz"
    'glew' = "https://downloads.sourceforge.net/project/glew/glew/$GLEW_VERSION/glew-$GLEW_VERSION.tgz"
    'libprojectm' = "https://github.com/projectM-visualizer/projectm/releases/download/v$LIBPROJECTM_VERSION/libprojectm-$LIBPROJECTM_VERSION.tar.gz"
    'expat' = "https://github.com/libexpat/libexpat/releases/download/R_$EXPAT_VERSION_UNDERSCORE/expat-$EXPAT_VERSION.tar.gz"
    'freetype' = "https://downloads.sourceforge.net/project/freetype/freetype2/$FREETYPE_VERSION/freetype-$FREETYPE_VERSION.tar.gz"
    'icu4c' = "https://github.com/unicode-org/icu/releases/download/release-$ICU4C_VERSION/icu4c-$ICU4C_VERSION-sources.tgz"
    'cairo' = "https://cairographics.org/releases/cairo-$CAIRO_VERSION.tar.xz"
    'harfbuzz' = "https://github.com/harfbuzz/harfbuzz/releases/download/$HARFBUZZ_VERSION/harfbuzz-$HARFBUZZ_VERSION.tar.xz"
    'qtbase' = "https://download.qt.io/official_releases/qt/6.10/$QT_VERSION/submodules/qtbase-everywhere-src-$QT_VERSION.tar.xz"
    'qttools' = "https://download.qt.io/official_releases/qt/6.10/$QT_VERSION/submodules/qttools-everywhere-src-$QT_VERSION.tar.xz"
    'qtgrpc' = "https://download.qt.io/official_releases/qt/6.10/$QT_VERSION/submodules/qtgrpc-everywhere-src-$QT_VERSION.tar.xz"
    'libgme' = "https://github.com/libgme/game-music-emu/releases/download/$LIBGME_VERSION/libgme-$LIBGME_VERSION-src.tar.gz"
    'twolame' = "https://downloads.sourceforge.net/twolame/twolame-$TWOLAME_VERSION.tar.gz"
    'sparsehash' = "https://github.com/sparsehash/sparsehash/archive/refs/tags/sparsehash-$SPARSEHASH_VERSION.tar.gz"
    'rapidjson' = "https://github.com/Tencent/rapidjson/archive/refs/tags/v$RAPIDJSON_VERSION/rapidjson-$RAPIDJSON_VERSION.tar.gz"
    'abseil-cpp' = "https://github.com/abseil/abseil-cpp/archive/refs/tags/$ABSEIL_VERSION/abseil-cpp-$ABSEIL_VERSION.tar.gz"
    'kdsingleapplication' = "https://github.com/KDAB/KDSingleApplication/releases/download/v$KDSINGLEAPPLICATION_VERSION/kdsingleapplication-$KDSINGLEAPPLICATION_VERSION.tar.gz"
    'getopt-win' = "https://github.com/ludvikjerabek/getopt-win/archive/refs/tags/v$GETOPT_WIN_VERSION/getopt-win-$GETOPT_WIN_VERSION.tar.gz"
    'pe-parse' = "https://github.com/trailofbits/pe-parse/archive/refs/tags/v$PEPARSE_VERSION/pe-parse-$PEPARSE_VERSION.tar.gz"
    'curl' = "https://github.com/curl/curl/releases/download/curl-$CURL_VERSION_UNDERSCORE/curl-$CURL_VERSION.tar.gz"
    'gettext' = "https://github.com/mlocati/gettext-iconv-windows/releases/download/v$GETTEXT_VERSION-v1.17/gettext$GETTEXT_VERSION-iconv1.17-static-64.zip"
    'git' = "https://github.com/git-for-windows/git/releases/download/v$GIT_VERSION.windows.1/Git-$GIT_VERSION-64-bit.exe"
    'cmake' = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"
    'nasm' = "https://www.nasm.us/pub/nasm/releasebuilds/$NASM_VERSION/win64/nasm-$NASM_VERSION-installer-x64.exe"
    'winflexbison' = "https://github.com/lexxmark/winflexbison/releases/download/v$WINFLEXBISON_VERSION/win_flex_bison-$WINFLEXBISON_VERSION.zip"
    'strawberry-perl' = "https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_$($STRAWBERRY_PERL_VERSION_STRIPPED)_64bit_UCRT/strawberry-perl-$STRAWBERRY_PERL_VERSION-64bit.msi"
    'python' = "https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-amd64.exe"
    '7zip' = "https://7-zip.org/a/7z$_7ZIP_VERSION-x64.exe"
    'nsis' = "https://prdownloads.sourceforge.net/nsis/nsis-$NSIS_VERSION-setup.exe"
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
  
  $gitRepos = @{
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
    PackageUrls = $packageUrls
    GitRepos = $gitRepos
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
    [string]$PackageName
  )
  
  $deps = Get-DependencyUrls
  
  if ($deps.PackageUrls.ContainsKey($PackageName)) {
    return $deps.PackageUrls[$PackageName]
  }
  elseif ($deps.GitRepos.ContainsKey($PackageName)) {
    return $deps.GitRepos[$PackageName]
  }
  else {
    throw "Package '$PackageName' not found in dependency URLs"
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
    [string]$PackageName,
    
    [Parameter(Mandatory=$true)]
    [string]$DownloadsPath
  )
  
  Write-Host "Checking package: $PackageName" -ForegroundColor Cyan
  
  # Ensure downloads directory exists
  if (-not (Test-Path $DownloadsPath)) {
    New-Item -ItemType Directory -Path $DownloadsPath -Force | Out-Null
  }
  
  try {
    $deps = Get-DependencyUrls
    
    # Check if it's a regular download URL
    if ($deps.PackageUrls.ContainsKey($PackageName)) {
      $url = $deps.PackageUrls[$PackageName]
      Get-FileIfNotExists -Url $url -DestinationPath $DownloadsPath
      Write-Host "✓ Package $PackageName is available" -ForegroundColor Green
    }
    # Check if it's a Git repository
    elseif ($deps.GitRepos.ContainsKey($PackageName)) {
      $url = $deps.GitRepos[$PackageName]
      Sync-GitRepository -Url $url -DestinationPath $DownloadsPath
      Write-Host "✓ Repository $PackageName is available" -ForegroundColor Green
    }
    else {
      Write-Warning "Package '$PackageName' not found in dependency configuration"
    }
  }
  catch {
    Write-Warning "Failed to download package $PackageName : $_"
    throw
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
    [string]$DownloadsPath
  )
  
  Write-Host "Downloading dependencies to: $DownloadsPath" -ForegroundColor Cyan
  
  # Ensure downloads directory exists
  if (-not (Test-Path $DownloadsPath)) {
    New-Item -ItemType Directory -Path $DownloadsPath -Force | Out-Null
  }
  
  # Get dependency URLs
  $deps = Get-DependencyUrls
  
  # Download files
  Write-Host "`nDownloading dependency files..." -ForegroundColor Green
  foreach ($packageName in $deps.PackageUrls.Keys) {
    try {
      $url = $deps.PackageUrls[$packageName]
      Get-FileIfNotExists -Url $url -DestinationPath $DownloadsPath
    }
    catch {
      Write-Warning "Failed to download $packageName : $_"
    }
  }
  
  # Clone/update Git repositories
  Write-Host "`nCloning/updating Git repositories..." -ForegroundColor Green
  foreach ($repoName in $deps.GitRepos.Keys) {
    try {
      $url = $deps.GitRepos[$repoName]
      Sync-GitRepository -Url $url -DestinationPath $DownloadsPath
    }
    catch {
      Write-Warning "Failed to sync repository $repoName : $_"
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
