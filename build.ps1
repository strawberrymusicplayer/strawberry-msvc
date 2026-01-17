# build.ps1
# Strawberry MSVC dependencies build script
# PowerShell version of build.bat

<#
.SYNOPSIS
    Build script for Strawberry MSVC dependencies
.DESCRIPTION
    Builds all dependencies required for Strawberry Music Player on Windows using MSVC
.PARAMETER BuildType
    Build type: debug or release (default: debug)
.EXAMPLE
    .\build.ps1 -BuildType release
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("debug", "release")]
    [string]$BuildType = "debug"
)

# Set strict mode
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Green
Write-Host "Strawberry MSVC Dependencies Build Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Import versions and build functions
try {
    . "$PSScriptRoot\versions.ps1"
    Import-Module "$PSScriptRoot\BuildFunctions.psm1" -Force
} catch {
    Write-Error "Failed to import versions.ps1 or BuildFunctions.psm1: $_"
    exit 1
}

# Set build configuration
if ($BuildType -eq "debug") {
    $CMAKE_BUILD_TYPE = "Debug"
    $MESON_BUILD_TYPE = "debug"
    $LIB_POSTFIX = "d"
} elseif ($BuildType -eq "release") {
    $CMAKE_BUILD_TYPE = "Release"
    $MESON_BUILD_TYPE = "release"
    $LIB_POSTFIX = ""
}

# Set paths
$DOWNLOADS_PATH = "c:\data\projects\strawberry\msvc_\downloads"
$BUILD_PATH = "c:\data\projects\strawberry\msvc_\build_$BuildType"
$PREFIX_PATH = "c:\strawberry_msvc_x86_64_$BuildType"
$PREFIX_PATH_FORWARD = $PREFIX_PATH -replace '\\', '/'
$PREFIX_PATH_ESCAPE = $PREFIX_PATH -replace '\\', '\\'
$QT_DEV = "OFF"
$GST_DEV = "OFF"

# Set CMake generator
$CMAKE_GENERATOR = "Ninja"

# Display configuration
Write-Host "Build Configuration:" -ForegroundColor Cyan
Write-Host "  Downloads path:      $DOWNLOADS_PATH"
Write-Host "  Build path:          $BUILD_PATH"
Write-Host "  Build type:          $BuildType"
Write-Host "  CMake build type:    $CMAKE_BUILD_TYPE"
Write-Host "  Meson build type:    $MESON_BUILD_TYPE"
Write-Host "  Prefix path:         $PREFIX_PATH"
Write-Host "  Prefix path forward: $PREFIX_PATH_FORWARD"
Write-Host "  Prefix path escape:  $PREFIX_PATH_ESCAPE"
Write-Host ""

# Create directories
Write-Host "Creating directories..." -ForegroundColor Cyan
try {
    @($DOWNLOADS_PATH, $BUILD_PATH, $PREFIX_PATH,
      "$PREFIX_PATH\bin", "$PREFIX_PATH\lib", "$PREFIX_PATH\include") | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
            Write-Host "  Created: $_" -ForegroundColor Green
        }
    }
} catch {
    Write-Error "Failed to create directories: $_"
    exit 1
}

# Copy sed.exe if needed
if (-not (Test-Path "$PREFIX_PATH\bin\sed.exe")) {
    if (Test-Path "$DOWNLOADS_PATH\sed.exe") {
        Copy-Item "$DOWNLOADS_PATH\sed.exe" "$PREFIX_PATH\bin\" -Force
    }
}

# Setup environment variables
Write-Host "Setting up environment variables..." -ForegroundColor Cyan
$env:PKG_CONFIG_EXECUTABLE = "$PREFIX_PATH\bin\pkgconf.exe"
$env:PKG_CONFIG_PATH = "$PREFIX_PATH\lib\pkgconfig"
$env:CL = "-MP"
$env:PATH = "$PREFIX_PATH\bin;$env:PATH"
$env:YASMPATH = "$PREFIX_PATH\bin"

# Check for required tools
Write-Host "Checking requirements..." -ForegroundColor Cyan

$toolChecks = @(
    @{ Command = "patch"; Paths = @("C:\Program Files\Git\usr\bin"); Message = "Missing patch" }
    @{ Command = "sed"; Paths = @("C:\Program Files\Git\usr\bin"); Message = "Missing sed" }
    @{ Command = "nasm"; Paths = @("C:\Program Files\nasm"); Message = "Missing nasm. Download from https://www.nasm.us/" }
    @{ Command = "win_flex"; Paths = @("C:\win_flex_bison"); Message = "Missing win_flex. Download from https://sourceforge.net/projects/winflexbison/" }
    @{ Command = "win_bison"; Paths = @("C:\win_flex_bison"); Message = "Missing win_bison. Download from https://sourceforge.net/projects/winflexbison/" }
    @{ Command = "perl"; Paths = @("C:\Strawberry\perl\bin"); Message = "Missing perl. Download Strawberry Perl from https://strawberryperl.com/" }
    @{ Command = "python"; Paths = @("C:\Program Files\Python314", "C:\Program Files\Python313", "C:\Program Files\Python312", "C:\Program Files\Python311", "C:\Program Files\Python310"); Message = "Missing python. Download from https://www.python.org/" }
    @{ Command = "tar"; Paths = @("C:\Program Files\Git\usr\bin"); Message = "Missing tar" }
    @{ Command = "bzip2"; Paths = @("C:\Program Files\Git\usr\bin"); Message = "Missing bzip2" }
    @{ Command = "7z"; Paths = @("C:\Program Files\7-Zip"); Message = "Missing 7z. Download 7-Zip from https://www.7-zip.org/download.html" }
    @{ Command = "cmake"; Paths = @("C:\Program Files\CMake\bin"); Message = "Missing cmake. Download from https://cmake.org/" }
    @{ Command = "meson"; Paths = @("C:\Program Files\Meson"); Message = "Missing meson. Download from https://mesonbuild.com/" }
    @{ Command = "nmake"; Paths = @(); Message = "Missing nmake. Install Visual Studio 2022" }
)

foreach ($check in $toolChecks) {
    if (-not (Test-Command $check.Command)) {
        foreach ($path in $check.Paths) {
            if (Test-Path $path) {
                $env:PATH = "$path;$env:PATH"
                break
            }
        }
        
        if (-not (Test-Command $check.Command)) {
            Write-Error $check.Message
            exit 1
        }
    }
    Write-Host "  $($check.Command) found" -ForegroundColor Green
}

Write-Host ""
Write-Host "All requirements satisfied!" -ForegroundColor Green
Write-Host ""

#region Build Functions

function Build-Yasm {
    Write-Host "Building yasm" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "yasm")) {
            New-Item -ItemType Directory -Path "yasm" -Force | Out-Null
            Copy-Item "$DOWNLOADS_PATH\yasm\*" "yasm\" -Recurse -Force
        }
        
        Set-Location "yasm"
        & patch -p1 -N -i "$DOWNLOADS_PATH\yasm-cmake.patch" 2>&1 | Out-Null
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @("-DBUILD_SHARED_LIBS=ON")
    } finally {
        Pop-Location
    }
}

function Build-Pkgconf {
    Write-Host "Building pkgconf" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        $pkgDir = Get-ChildItem -Directory -Filter "pkgconf-pkgconf-$PKGCONF_VERSION" -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $pkgDir) {
            & tar -xvf "$DOWNLOADS_PATH\pkgconf-$PKGCONF_VERSION.tar.gz"
            $pkgDir = Get-ChildItem -Directory -Filter "pkgconf-pkgconf-$PKGCONF_VERSION" | Select-Object -First 1
        }
        
        Set-Location $pkgDir.FullName
        
        Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
            -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
            -PkgConfigPath "$PREFIX_PATH\lib\pkgconfig" `
            -AdditionalArgs @("-Dtests=disabled")
        
        Copy-Item "$PREFIX_PATH\bin\pkgconf.exe" "$PREFIX_PATH\bin\pkg-config.exe" -Force
    } finally {
        Pop-Location
    }
}

function Build-GetoptWin {
    Write-Host "Building getopt-win" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "getopt-win-$GETOPT_WIN_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\getopt-win-$GETOPT_WIN_VERSION.tar.gz"
        }
        
        Set-Location "getopt-win-$GETOPT_WIN_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DBUILD_SHARED_LIB=ON",
                "-DBUILD_STATIC_LIBS=OFF",
                "-DBUILD_STATIC_LIB=OFF",
                "-DBUILD_TESTING=OFF"
            )
    } finally {
        Pop-Location
    }
}

function Build-Zlib {
    Write-Host "Building zlib" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "zlib-$ZLIB_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\zlib-$ZLIB_VERSION.tar.gz"
        }
        
        Set-Location "zlib-$ZLIB_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DBUILD_STATIC_LIBS=OFF"
            )
        
        Copy-Item "$PREFIX_PATH\share\pkgconfig\zlib.pc" "$PREFIX_PATH\lib\pkgconfig\" -Force
        (Get-Content "$PREFIX_PATH\lib\pkgconfig\zlib.pc") -replace '-lz', "-lzlib$LIB_POSTFIX" | Set-Content "$PREFIX_PATH\lib\pkgconfig\zlib.pc"
        
        Copy-Item "$PREFIX_PATH\lib\zlib$LIB_POSTFIX.lib" "$PREFIX_PATH\lib\z.lib" -Force
        
        Remove-Item "$PREFIX_PATH\lib\zlibstatic*.lib" -ErrorAction SilentlyContinue
    } finally {
        Pop-Location
    }
}

function Build-OpenSSL {
    Write-Host "Building openssl" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "openssl-$OPENSSL_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\openssl-$OPENSSL_VERSION.tar.gz"
        }
        
        Set-Location "openssl-$OPENSSL_VERSION"
        
        if ($BuildType -eq "debug") {
            & perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix="$PREFIX_PATH" --libdir=lib --openssldir="$PREFIX_PATH\ssl" --debug --with-zlib-include="$PREFIX_PATH\include" --with-zlib-lib="$PREFIX_PATH\lib\zlibd.lib"
        } else {
            & perl Configure VC-WIN64A shared zlib no-capieng no-tests --prefix="$PREFIX_PATH" --libdir=lib --openssldir="$PREFIX_PATH\ssl" --release --with-zlib-include="$PREFIX_PATH\include" --with-zlib-lib="$PREFIX_PATH\lib\zlib.lib"
        }
        
        if ($LASTEXITCODE -ne 0) { throw "OpenSSL configure failed" }
        
        & nmake
        if ($LASTEXITCODE -ne 0) { throw "OpenSSL build failed" }
        
        & nmake install_sw
        if ($LASTEXITCODE -ne 0) { throw "OpenSSL install failed" }
        
        Copy-Item "$PREFIX_PATH\lib\libssl.lib" "$PREFIX_PATH\lib\ssl.lib" -Force
        Copy-Item "$PREFIX_PATH\lib\libcrypto.lib" "$PREFIX_PATH\lib\crypto.lib" -Force
        
        # Create pkg-config files
        New-PkgConfigFile -Name "OpenSSL-libcrypto" -Description "OpenSSL cryptography library" `
            -Version $OPENSSL_VERSION -Prefix $PREFIX_PATH_FORWARD `
            -Libs "-lcrypto" -Cflags "-DOPENSSL_LOAD_CONF -I`${includedir}" `
            -OutputPath "$PREFIX_PATH\lib\pkgconfig\libcrypto.pc"
        
        New-PkgConfigFile -Name "OpenSSL-libssl" -Description "Secure Sockets Layer and cryptography libraries" `
            -Version $OPENSSL_VERSION -Prefix $PREFIX_PATH_FORWARD `
            -Libs "-lssl" -Cflags "-DOPENSSL_LOAD_CONF -I`${includedir}" `
            -Requires "libcrypto" -OutputPath "$PREFIX_PATH\lib\pkgconfig\libssl.pc"
        
        New-PkgConfigFile -Name "OpenSSL" -Description "Secure Sockets Layer and cryptography libraries and tools" `
            -Version $OPENSSL_VERSION -Prefix $PREFIX_PATH_FORWARD `
            -Libs "" -Requires "libssl libcrypto" `
            -OutputPath "$PREFIX_PATH\lib\pkgconfig\openssl.pc"
    } finally {
        Pop-Location
    }
}

function Build-GMP {
    Write-Host "Installing gmp" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        $smpBuildPath = "$BUILD_PATH\ShiftMediaProject\build"
        if (-not (Test-Path $smpBuildPath)) {
            New-Item -ItemType Directory -Path $smpBuildPath -Force | Out-Null
        }
        
        Set-Location $smpBuildPath
        
        if (-not (Test-Path "gmp")) {
            New-Item -ItemType Directory -Path "gmp" -Force | Out-Null
            Set-Location "gmp"
            Copy-Item "$DOWNLOADS_PATH\gmp\*" "." -Recurse -Force
            & git checkout $GMP_VERSION
            Set-Location ..
        }
        
        Set-Location "gmp\SMP"
        
        Update-VSProject -ProjectPath "libgmp.vcxproj"
        Invoke-MSBuildProject -ProjectPath "libgmp.vcxproj" -Configuration "${BuildType}DLL"
        
        Copy-Item "..\..\..\msvc\lib\x64\gmp$LIB_POSTFIX.lib" "$PREFIX_PATH\lib\" -Force
        Copy-Item "..\..\..\msvc\bin\x64\gmp$LIB_POSTFIX.dll" "$PREFIX_PATH\bin\" -Force
        Copy-Item "..\..\..\msvc\include\gmp*.h" "$PREFIX_PATH\include\" -Force
        
        New-PkgConfigFile -Name "gmp" -Description "gmp" -Version $GMP_VERSION `
            -Prefix $PREFIX_PATH_FORWARD -Libs "-lgmp$LIB_POSTFIX" `
            -Cflags "-I`${includedir}" -OutputPath "$PREFIX_PATH\lib\pkgconfig\gmp.pc"
    } finally {
        Pop-Location
    }
}

function Build-Nettle {
    Write-Host "Installing nettle" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        $smpBuildPath = "$BUILD_PATH\ShiftMediaProject\build"
        if (-not (Test-Path $smpBuildPath)) {
            New-Item -ItemType Directory -Path $smpBuildPath -Force | Out-Null
        }
        
        Set-Location $smpBuildPath
        
        if (-not (Test-Path "nettle")) {
            New-Item -ItemType Directory -Path "nettle" -Force | Out-Null
            Set-Location "nettle"
            Copy-Item "$DOWNLOADS_PATH\nettle\*" "." -Recurse -Force
            & git checkout "nettle_$NETTLE_VERSION"
            Set-Location ..
        }
        
        Set-Location "nettle\SMP"
        
        Update-VSProject -ProjectPath "libnettle.vcxproj"
        Invoke-MSBuildProject -ProjectPath "libnettle.vcxproj" -Configuration "${BuildType}DLL"
        
        Copy-Item "..\..\..\msvc\lib\x64\nettle$LIB_POSTFIX.lib" "$PREFIX_PATH\lib\" -Force
        Copy-Item "..\..\..\msvc\bin\x64\nettle$LIB_POSTFIX.dll" "$PREFIX_PATH\bin\" -Force
        
        if (-not (Test-Path "$PREFIX_PATH\include\nettle")) {
            New-Item -ItemType Directory -Path "$PREFIX_PATH\include\nettle" -Force | Out-Null
        }
        Copy-Item "..\..\..\msvc\include\nettle\*.h" "$PREFIX_PATH\include\nettle\" -Force
        
        Update-VSProject -ProjectPath "libhogweed.vcxproj"
        Invoke-MSBuildProject -ProjectPath "libhogweed.vcxproj" -Configuration "${BuildType}DLL"
        
        Copy-Item "..\..\..\msvc\lib\x64\hogweed$LIB_POSTFIX.lib" "$PREFIX_PATH\lib\" -Force
        Copy-Item "..\..\..\msvc\bin\x64\hogweed$LIB_POSTFIX.dll" "$PREFIX_PATH\bin\" -Force
        Copy-Item "..\..\..\msvc\include\nettle\*.h" "$PREFIX_PATH\include\nettle\" -Force
        
        New-PkgConfigFile -Name "nettle" -Description "nettle" -Version $NETTLE_VERSION `
            -Prefix $PREFIX_PATH_FORWARD -Libs "-lnettle$LIB_POSTFIX" `
            -Cflags "-I`${includedir}" -OutputPath "$PREFIX_PATH\lib\pkgconfig\nettle.pc"
        
        New-PkgConfigFile -Name "hogweed" -Description "hogweed" -Version $NETTLE_VERSION `
            -Prefix $PREFIX_PATH_FORWARD -Libs "-lhogweed$LIB_POSTFIX" `
            -Cflags "-I`${includedir}" -OutputPath "$PREFIX_PATH\lib\pkgconfig\hogweed.pc"
    } finally {
        Pop-Location
    }
}

function Build-GnuTLS {
    Write-Host "Installing gnutls" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        $smpBuildPath = "$BUILD_PATH\ShiftMediaProject\build"
        if (-not (Test-Path $smpBuildPath)) {
            New-Item -ItemType Directory -Path $smpBuildPath -Force | Out-Null
        }
        
        Set-Location $smpBuildPath
        
        if (-not (Test-Path "gnutls")) {
            New-Item -ItemType Directory -Path "gnutls" -Force | Out-Null
            Set-Location "gnutls"
            Copy-Item "$DOWNLOADS_PATH\gnutls\*" "." -Recurse -Force
            & git checkout $GNUTLS_VERSION
            Set-Location ..
        }
        
        Set-Location "gnutls\SMP"
        
        # Create inject_zlib.props
        $propsContent = @"
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemDefinitionGroup>
    <ClCompile>
      <AdditionalIncludeDirectories>$PREFIX_PATH\include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <AdditionalLibraryDirectories>$PREFIX_PATH\lib;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
    </Link>
  </ItemDefinitionGroup>
</Project>
"@
        Set-Content -Path "$BUILD_PATH\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props" -Value $propsContent
        
        Update-VSProject -ProjectPath "libgnutls.sln"
        
        Invoke-MSBuildProject -ProjectPath "libgnutls.sln" -Configuration "${CMAKE_BUILD_TYPE}DLL" `
            -AdditionalArgs @("/p:ForceImportBeforeCppTargets=$BUILD_PATH\ShiftMediaProject\build\gnutls\SMP\inject_zlib.props")
        
        Copy-Item "..\..\..\msvc\lib\x64\gnutls$LIB_POSTFIX.lib" "$PREFIX_PATH\lib\" -Force
        Copy-Item "..\..\..\msvc\bin\x64\gnutls$LIB_POSTFIX.dll" "$PREFIX_PATH\bin\" -Force
        
        if (-not (Test-Path "$PREFIX_PATH\include\gnutls")) {
            New-Item -ItemType Directory -Path "$PREFIX_PATH\include\gnutls" -Force | Out-Null
        }
        Copy-Item "..\..\..\msvc\include\gnutls\*.h" "$PREFIX_PATH\include\gnutls\" -Force
        
        # Workaround: Build static deps version
        & "project_get_dependencies.bat"
        
        Update-VSProject -ProjectPath "..\..\gmp\SMP\libgmp.vcxproj"
        Update-VSProject -ProjectPath "..\..\zlib\SMP\libzlib.vcxproj"
        Update-VSProject -ProjectPath "..\..\nettle\SMP\libnettle.vcxproj"
        Update-VSProject -ProjectPath "..\..\nettle\SMP\libhogweed.vcxproj"
        
        Invoke-MSBuildProject -ProjectPath "..\..\gmp\SMP\libgmp.vcxproj" -Configuration "Release"
        Invoke-MSBuildProject -ProjectPath "..\..\zlib\SMP\libzlib.vcxproj" -Configuration "Release"
        Invoke-MSBuildProject -ProjectPath "..\..\nettle\SMP\libnettle.vcxproj" -Configuration "Release"
        Invoke-MSBuildProject -ProjectPath "..\..\nettle\SMP\libhogweed.vcxproj" -Configuration "Release"
        Invoke-MSBuildProject -ProjectPath "libgnutls.vcxproj" -Configuration "ReleaseDLLStaticDeps"
        
        Remove-Item "$PREFIX_PATH\lib\gnutls$LIB_POSTFIX.lib" -Force
        Remove-Item "$PREFIX_PATH\bin\gnutls$LIB_POSTFIX.dll" -Force
        Copy-Item "..\..\..\msvc\lib\x64\gnutls.lib" "$PREFIX_PATH\lib\" -Force
        Copy-Item "..\..\..\msvc\bin\x64\gnutls.dll" "$PREFIX_PATH\bin\" -Force
        
        New-PkgConfigFile -Name "gnutls" -Description "gnutls" -Version $GNUTLS_VERSION `
            -Prefix $PREFIX_PATH_FORWARD -Libs "-lgnutls" `
            -Cflags "-I`${includedir}" -OutputPath "$PREFIX_PATH\lib\pkgconfig\gnutls.pc"
    } finally {
        Pop-Location
    }
}

function Build-LibPNG {
    Write-Host "Building libpng" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "libpng-$LIBPNG_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\libpng-$LIBPNG_VERSION.tar.gz"
        }
        
        Set-Location "libpng-$LIBPNG_VERSION"
        & patch -p1 -N -i "$DOWNLOADS_PATH\libpng-pkgconf.patch" 2>&1 | Out-Null
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD
        
        if ($BuildType -eq "debug") {
            Copy-Item "$PREFIX_PATH\lib\libpng16d.lib" "$PREFIX_PATH\lib\png16.lib" -Force
        }
    } finally {
        Pop-Location
    }
}

function Build-LibJPEG {
    Write-Host "Building libjpeg" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "libjpeg-turbo-$LIBJPEG_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\libjpeg-turbo-$LIBJPEG_VERSION.tar.gz"
        }
        
        Set-Location "libjpeg-turbo-$LIBJPEG_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DENABLE_SHARED=ON",
                "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            )
    } finally {
        Pop-Location
    }
}

function Build-PCRE2 {
    Write-Host "Building pcre2" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "pcre2-$PCRE2_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\pcre2-$PCRE2_VERSION.tar.gz"
        }
        
        Set-Location "pcre2-$PCRE2_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DBUILD_STATIC_LIBS=OFF",
                "-DPCRE2_BUILD_PCRE2_16=ON",
                "-DPCRE2_BUILD_PCRE2_32=ON",
                "-DPCRE2_BUILD_PCRE2_8=ON",
                "-DPCRE2_BUILD_TESTS=OFF",
                "-DPCRE2_SUPPORT_UNICODE=ON"
            )
    } finally {
        Pop-Location
    }
}

function Build-BZip2 {
    Write-Host "Building bzip2" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "bzip2-$BZIP2_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\bzip2-$BZIP2_VERSION.tar.gz"
        }
        
        Set-Location "bzip2-$BZIP2_VERSION"
        & patch -p1 -N -i "$DOWNLOADS_PATH\bzip2-cmake.patch" 2>&1 | Out-Null
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build2" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @("-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
    } finally {
        Pop-Location
    }
}

function Build-XZ {
    Write-Host "Building xz" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "xz-$XZ_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\xz-$XZ_VERSION.tar.gz"
        }
        
        Set-Location "xz-$XZ_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DBUILD_STATIC_LIBS=OFF",
                "-DBUILD_TESTING=OFF",
                "-DXZ_NLS=OFF"
            )
    } finally {
        Pop-Location
    }
}

function Build-Brotli {
    Write-Host "Building brotli" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "brotli-$BROTLI_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\brotli-$BROTLI_VERSION.tar.gz"
        }
        
        Set-Location "brotli-$BROTLI_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build2" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @("-DBUILD_TESTING=OFF")
    } finally {
        Pop-Location
    }
}

function Build-LibIconv {
    Write-Host "Building libiconv" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "libiconv-for-Windows")) {
            New-Item -ItemType Directory -Path "libiconv-for-Windows" -Force | Out-Null
            Copy-Item "$DOWNLOADS_PATH\libiconv-for-Windows\*" "libiconv-for-Windows\" -Recurse -Force
        }
        
        Set-Location "libiconv-for-Windows"
        
        Invoke-MSBuildProject -ProjectPath "libiconv.sln" -Configuration $BuildType
        
        Copy-Item "output\x64\$BuildType\*.lib" "$PREFIX_PATH\lib\" -Force
        Copy-Item "output\x64\$BuildType\*.dll" "$PREFIX_PATH\bin\" -Force
        Copy-Item "include\*.h" "$PREFIX_PATH\include\" -Force
        
        if ($BuildType -eq "debug") {
            Copy-Item "$PREFIX_PATH\lib\libiconvD.lib" "$PREFIX_PATH\lib\libiconv.lib" -Force
        }
    } finally {
        Pop-Location
    }
}

function Build-ICU4C {
    Write-Host "Building icu4c" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "icu")) {
            & tar -xvf "$DOWNLOADS_PATH\icu4c-$ICU4C_VERSION-sources.tgz"
        }
        
        Set-Location "icu\source\allinone"
        
        Invoke-MSBuildProject -ProjectPath "allinone.sln" -Configuration $BuildType `
            -Platform "x64" -AdditionalArgs @("/p:SkipUWP=true")
        
        Set-Location "..\..\"
        
        if (-not (Test-Path "$PREFIX_PATH\include\unicode")) {
            New-Item -ItemType Directory -Path "$PREFIX_PATH\include\unicode" -Force | Out-Null
        }
        
        Copy-Item "include\unicode\*.h" "$PREFIX_PATH\include\unicode\" -Force
        Copy-Item "lib64\*.*" "$PREFIX_PATH\lib\" -Force
        Copy-Item "bin64\*.*" "$PREFIX_PATH\bin\" -Force
        
        # Create pkg-config files
        New-PkgConfigFile -Name "icu-uc" -Description "International Components for Unicode: Common and Data libraries" `
            -Version $ICU4C_VERSION -Prefix $PREFIX_PATH_FORWARD `
            -Libs "-licuuc$LIB_POSTFIX -licudt" -Cflags "-I`${includedir}" `
            -OutputPath "$PREFIX_PATH\lib\pkgconfig\icu-uc.pc"
        
        New-PkgConfigFile -Name "icu-i18n" -Description "International Components for Unicode: Stream and I/O Library" `
            -Version $ICU4C_VERSION -Prefix $PREFIX_PATH_FORWARD `
            -Libs "-licuin$LIB_POSTFIX" -Requires "icu-uc" `
            -OutputPath "$PREFIX_PATH\lib\pkgconfig\icu-i18n.pc"
        
        New-PkgConfigFile -Name "icu-io" -Description "International Components for Unicode: Stream and I/O Library" `
            -Version $ICU4C_VERSION -Prefix $PREFIX_PATH_FORWARD `
            -Libs "-licuio$LIB_POSTFIX" -Requires "icu-i18n" `
            -OutputPath "$PREFIX_PATH\lib\pkgconfig\icu-io.pc"
    } finally {
        Pop-Location
    }
}

function Build-Pixman {
    Write-Host "Building pixman" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "pixman-$PIXMAN_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\pixman-$PIXMAN_VERSION.tar.gz"
        }
        
        Set-Location "pixman-$PIXMAN_VERSION"
        
        Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
            -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
            -PkgConfigPath "$PREFIX_PATH\lib\pkgconfig" `
            -AdditionalArgs @("-Dgtk=disabled", "-Dlibpng=enabled")
    } finally {
        Pop-Location
    }
}

function Build-Expat {
    Write-Host "Building expat" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "expat-$EXPAT_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\expat-$EXPAT_VERSION.tar.gz"
        }
        
        Set-Location "expat-$EXPAT_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DEXPAT_SHARED_LIBS=ON",
                "-DEXPAT_BUILD_DOCS=OFF",
                "-DEXPAT_BUILD_EXAMPLES=OFF",
                "-DEXPAT_BUILD_FUZZERS=OFF",
                "-DEXPAT_BUILD_TESTS=OFF",
                "-DEXPAT_BUILD_TOOLS=OFF",
                "-DEXPAT_BUILD_PKGCONFIG=ON"
            )
    } finally {
        Pop-Location
    }
}

function Build-Boost {
    Write-Host "Building boost" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "boost_$BOOST_VERSION_UNDERSCORE")) {
            & tar -xvf "$DOWNLOADS_PATH\boost_$BOOST_VERSION_UNDERSCORE.tar.gz"
        }
        
        Set-Location "boost_$BOOST_VERSION_UNDERSCORE"
        
        if (Test-Path "b2.exe") { Remove-Item "b2.exe" -Force }
        if (Test-Path "bjam.exe") { Remove-Item "bjam.exe" -Force }
        if (Test-Path "stage") { Remove-Item "stage" -Recurse -Force }
        
        Write-Host "Running bootstrap.bat" -ForegroundColor Cyan
        & .\bootstrap.bat msvc
        if ($LASTEXITCODE -ne 0) { throw "Boost bootstrap failed" }
        
        Write-Host "Running b2.exe" -ForegroundColor Cyan
        & .\b2.exe -a -q -j 4 -d1 --ignore-site-config --stagedir="stage" --layout="tagged" `
            --prefix="$PREFIX_PATH" --exec-prefix="$PREFIX_PATH\bin" --libdir="$PREFIX_PATH\lib" `
            --includedir="$PREFIX_PATH\include" --with-headers toolset=msvc architecture=x86 `
            address-model=64 link=shared runtime-link=shared threadapi=win32 threading=multi `
            variant=$BuildType install
    } finally {
        Pop-Location
    }
}

function Build-LibXML2 {
    Write-Host "Building libxml2" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "libxml2-v$LIBXML2_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\libxml2-v$LIBXML2_VERSION.tar.gz"
        }
        
        Set-Location "libxml2-v$LIBXML2_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DLIBXML2_WITH_PYTHON=OFF",
                "-DLIBXML2_WITH_ZLIB=ON",
                "-DLIBXML2_WITH_LZMA=ON",
                "-DLIBXML2_WITH_ICONV=ON",
                "-DLIBXML2_WITH_ICU=ON",
                "-DICU_ROOT=$PREFIX_PATH_FORWARD"
            )
        
        if ($BuildType -eq "debug") {
            Copy-Item "$PREFIX_PATH\lib\libxml2d.lib" "$PREFIX_PATH\lib\libxml2.lib" -Force
        }
    } finally {
        Pop-Location
    }
}

function Build-NGHttp2 {
    Write-Host "Building nghttp2" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "nghttp2-$NGHTTP2_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\nghttp2-$NGHTTP2_VERSION.tar.gz"
        }
        
        Set-Location "nghttp2-$NGHTTP2_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DBUILD_STATIC_LIBS=OFF"
            )
    } finally {
        Pop-Location
    }
}

function Build-LibFFI {
    Write-Host "Building libffi" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "libffi")) {
            New-Item -ItemType Directory -Path "libffi" -Force | Out-Null
            Copy-Item "$DOWNLOADS_PATH\libffi\*" "libffi\" -Recurse -Force
        }
        
        Set-Location "libffi"
        
        Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
            -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
            -AdditionalArgs @("-Dpkg_config_path=$PREFIX_PATH\lib\pkgconfig")
    } finally {
        Pop-Location
    }
}

function Build-DlfcnWin32 {
    Write-Host "Building dlfcn-win32" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "dlfcn-win32-$DLFCN_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\dlfcn-win32-$DLFCN_VERSION.tar.gz"
        }
        
        Set-Location "dlfcn-win32-$DLFCN_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @("-DBUILD_SHARED_LIBS=ON")
    } finally {
        Pop-Location
    }
}

function Build-LibPSL {
    Write-Host "Building libpsl" -ForegroundColor Yellow
    
    $originalCFLAGS = $env:CFLAGS
    $originalLDFLAGS = $env:LDFLAGS
    
    try {
        $env:CFLAGS = "-I$PREFIX_PATH_FORWARD/include"
        $env:LDFLAGS = "-L$PREFIX_PATH\lib"
        
        Push-Location $BUILD_PATH
        try {
            if (-not (Test-Path "libpsl-$LIBPSL_VERSION")) {
                & tar -xvf "$DOWNLOADS_PATH\libpsl-$LIBPSL_VERSION.tar.gz"
            }
            
            Set-Location "libpsl-$LIBPSL_VERSION"
            & patch -p1 -N -i "$DOWNLOADS_PATH\libpsl-time.patch" 2>&1 | Out-Null
            
            Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
                -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
                -PkgConfigPath "$PREFIX_PATH\lib\pkgconfig"
        } finally {
            Pop-Location
        }
    } finally {
        $env:CFLAGS = $originalCFLAGS
        $env:LDFLAGS = $originalLDFLAGS
    }
}

function Build-Orc {
    Write-Host "Building orc" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "orc-$ORC_VERSION")) {
            & 7z x "$DOWNLOADS_PATH\orc-$ORC_VERSION.tar.xz" -so | & 7z x -aoa -si"orc-$ORC_VERSION.tar"
        }
        
        Set-Location "orc-$ORC_VERSION"
        
        Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
            -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
            -PkgConfigPath "$PREFIX_PATH\lib\pkgconfig"
    } finally {
        Pop-Location
    }
}

function Build-SQLite {
    Write-Host "Building sqlite" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "sqlite-autoconf-$SQLITE_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\sqlite-autoconf-$SQLITE_VERSION.tar.gz"
        }
        
        Set-Location "sqlite-autoconf-$SQLITE_VERSION"
        
        & cl -DSQLITE_API="__declspec(dllexport)" -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_COLUMN_METADATA sqlite3.c -link -dll -out:sqlite3.dll
        & cl shell.c sqlite3.c -Fe:sqlite3.exe
        
        Copy-Item "*.h" "$PREFIX_PATH\include\" -Force
        Copy-Item "*.lib" "$PREFIX_PATH\lib\" -Force
        Copy-Item "*.dll" "$PREFIX_PATH\bin\" -Force
        Copy-Item "*.exe" "$PREFIX_PATH\bin\" -Force
        
        New-PkgConfigFile -Name "SQLite" -Description "SQL database engine" `
            -Version "3.38.1" -Prefix $PREFIX_PATH_FORWARD `
            -Libs "-lsqlite3" -Cflags "-I`${includedir}" `
            -OutputPath "$PREFIX_PATH\lib\pkgconfig\sqlite3.pc"
    } finally {
        Pop-Location
    }
}

function Build-Glib {
    Write-Host "Building glib" -ForegroundColor Yellow
    
    $originalCFLAGS = $env:CFLAGS
    $originalLDFLAGS = $env:LDFLAGS
    
    try {
        $env:CFLAGS = "-I$PREFIX_PATH_FORWARD/include"
        $env:LDFLAGS = "-L$PREFIX_PATH\lib"
        
        Push-Location $BUILD_PATH
        try {
            if (-not (Test-Path "glib-$GLIB_VERSION")) {
                & 7z x "$DOWNLOADS_PATH\glib-$GLIB_VERSION.tar.xz" -so | & 7z x -aoa -si"glib-$GLIB_VERSION.tar"
            }
            
            Set-Location "glib-$GLIB_VERSION"
            
            Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
                -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
                -AdditionalArgs @(
                    "--includedir=$PREFIX_PATH\include",
                    "--libdir=$PREFIX_PATH\lib",
                    "-Dpkg_config_path=$PREFIX_PATH\lib\pkgconfig",
                    "-Dtests=false"
                )
        } finally {
            Pop-Location
        }
    } finally {
        $env:CFLAGS = $originalCFLAGS
        $env:LDFLAGS = $originalLDFLAGS
    }
}

function Build-LibSoup {
    Write-Host "Building libsoup" -ForegroundColor Yellow
    
    $originalCFLAGS = $env:CFLAGS
    
    try {
        $env:CFLAGS = "-I$PREFIX_PATH_FORWARD/include"
        
        Push-Location $BUILD_PATH
        try {
            if (-not (Test-Path "libsoup-$LIBSOUP_VERSION")) {
                & 7z x "$DOWNLOADS_PATH\libsoup-$LIBSOUP_VERSION.tar.xz" -so | & 7z x -aoa -si"libsoup-$LIBSOUP_VERSION.tar"
            }
            
            Set-Location "libsoup-$LIBSOUP_VERSION"
            
            Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
                -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
                -PkgConfigPath "$PREFIX_PATH\lib\pkgconfig" `
                -AdditionalArgs @(
                    "-Dtests=false",
                    "-Dvapi=disabled",
                    "-Dgssapi=disabled",
                    "-Dintrospection=disabled",
                    "-Dsysprof=disabled",
                    "-Dtls_check=false"
                )
        } finally {
            Pop-Location
        }
    } finally {
        $env:CFLAGS = $originalCFLAGS
    }
}

function Build-GlibNetworking {
    Write-Host "Building glib-networking" -ForegroundColor Yellow
    
    $originalCFLAGS = $env:CFLAGS
    
    try {
        $env:CFLAGS = "-I$PREFIX_PATH_FORWARD/include"
        
        Push-Location $BUILD_PATH
        try {
            if (-not (Test-Path "glib-networking-$GLIB_NETWORKING_VERSION")) {
                & 7z x "$DOWNLOADS_PATH\glib-networking-$GLIB_NETWORKING_VERSION.tar.xz" -so | & 7z x -aoa -si"glib-networking-$GLIB_NETWORKING_VERSION.tar"
            }
            
            Set-Location "glib-networking-$GLIB_NETWORKING_VERSION"
            
            Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
                -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
                -PkgConfigPath "$PREFIX_PATH\lib\pkgconfig" `
                -AdditionalArgs @(
                    "-Dgnutls=enabled",
                    "-Dopenssl=enabled",
                    "-Dgnome_proxy=disabled",
                    "-Dlibproxy=disabled"
                )
        } finally {
            Pop-Location
        }
    } finally {
        $env:CFLAGS = $originalCFLAGS
    }
}

function Build-Freetype {
    Write-Host "Building freetype without harfbuzz" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "freetype-$FREETYPE_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\freetype-$FREETYPE_VERSION.tar.gz"
        }
        
        Set-Location "freetype-$FREETYPE_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DFT_DISABLE_HARFBUZZ=ON"
            )
        
        if ($BuildType -eq "debug") {
            Copy-Item "$PREFIX_PATH\lib\freetyped.lib" "$PREFIX_PATH\lib\freetype.lib" -Force
        }
    } finally {
        Pop-Location
    }
}

function Build-Harfbuzz {
    Write-Host "Building harfbuzz" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "harfbuzz-$HARFBUZZ_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\harfbuzz-$HARFBUZZ_VERSION.tar.gz"
        }
        
        Set-Location "harfbuzz-$HARFBUZZ_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @("-DBUILD_SHARED_LIBS=ON")
    } finally {
        Pop-Location
    }
}

# Add more audio codec build functions (abbreviated for space)
function Build-AudioCodecs {
    Write-Host "Building audio codecs..." -ForegroundColor Yellow
    
    # These would include: libogg, libvorbis, flac, wavpack, opus, opusfile,
    # speex, mpg123, lame, twolame, fftw3, musepack, libopenmpt, libgme,
    # fdk-aac, faad2, faac, etc.
    # Implementation similar to above patterns
}

function Build-FFmpeg {
    Write-Host "Building ffmpeg" -ForegroundColor Yellow
    
    $originalCFLAGS = $env:CFLAGS
    
    try {
        $env:CFLAGS = "-I$PREFIX_PATH_FORWARD/include"
        
        Push-Location $BUILD_PATH
        try {
            if (-not (Test-Path "ffmpeg")) {
                New-Item -ItemType Directory -Path "ffmpeg" -Force | Out-Null
                Copy-Item "$DOWNLOADS_PATH\ffmpeg\*" "ffmpeg\" -Recurse -Force
                Set-Location "ffmpeg"
                & git checkout "meson-$FFMPEG_VERSION"
                & git checkout .
                & git pull --rebase
                Set-Location ..
            }
            
            Set-Location "ffmpeg"
            
            Invoke-MesonBuild -SourcePath "." -BuildPath "build" `
                -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
                -PkgConfigPath "$PREFIX_PATH\lib\pkgconfig" `
                -AdditionalArgs @(
                    "-Dtests=disabled",
                    "-Dgpl=enabled"
                )
        } finally {
            Pop-Location
        }
    } finally {
        $env:CFLAGS = $originalCFLAGS
    }
}

function Build-Chromaprint {
    Write-Host "Building chromaprint" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "chromaprint-$CHROMAPRINT_VERSION")) {
            & tar -xvf "$DOWNLOADS_PATH\chromaprint-$CHROMAPRINT_VERSION.tar.gz"
        }
        
        Set-Location "chromaprint-$CHROMAPRINT_VERSION"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DFFMPEG_ROOT=$PREFIX_PATH",
                "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            )
    } finally {
        Pop-Location
    }
}

function Build-GStreamer {
    Write-Host "Building GStreamer" -ForegroundColor Yellow
    
    $originalCFLAGS = $env:CFLAGS
    
    try {
        $env:CFLAGS = "-I$PREFIX_PATH_FORWARD/include"
        
        Push-Location $BUILD_PATH
        try {
            if ($GST_DEV -eq "ON") {
                if (-not (Test-Path "gstreamer")) {
                    New-Item -ItemType Directory -Path "gstreamer" -Force | Out-Null
                    Copy-Item "$DOWNLOADS_PATH\gstreamer\subprojects\gstreamer\*" "gstreamer\" -Recurse -Force
                }
            } else {
                if (-not (Test-Path "gstreamer-$GSTREAMER_VERSION")) {
                    & 7z x "$DOWNLOADS_PATH\gstreamer-$GSTREAMER_VERSION.tar.xz" -so | & 7z x -aoa -si"gstreamer-$GSTREAMER_VERSION.tar"
                }
                Set-Location "gstreamer-$GSTREAMER_VERSION"
            }
            
            Invoke-MesonBuild -SourcePath (Get-Location).Path -BuildPath "build" `
                -BuildType $MESON_BUILD_TYPE -InstallPrefix $PREFIX_PATH `
                -PkgConfigPath "$PREFIX_PATH\lib\pkgconfig" `
                -AdditionalArgs @(
                    "-Dexamples=disabled",
                    "-Dtests=disabled",
                    "-Dbenchmarks=disabled",
                    "-Dtools=enabled",
                    "-Dintrospection=disabled",
                    "-Dnls=disabled",
                    "-Ddoc=disabled",
                    "-Dgst_debug=true",
                    "-Dgst_parse=true",
                    "-Dregistry=true"
                )
        } finally {
            Pop-Location
        }
    } finally {
        $env:CFLAGS = $originalCFLAGS
    }
}

function Build-Qt {
    Write-Host "Building qtbase" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if ($QT_DEV -eq "ON") {
            if (-not (Test-Path "qtbase")) {
                New-Item -ItemType Directory -Path "qtbase" -Force | Out-Null
                Copy-Item "$DOWNLOADS_PATH\qtbase\*" "qtbase\" -Recurse -Force
            }
            Set-Location "qtbase"
        } else {
            if (-not (Test-Path "qtbase-everywhere-src-$QT_VERSION")) {
                & 7z x "$DOWNLOADS_PATH\qtbase-everywhere-src-$QT_VERSION.tar.xz" -so | & 7z x -aoa -si"qtbase-everywhere-src-$QT_VERSION.tar"
            }
            Set-Location "qtbase-everywhere-src-$QT_VERSION"
        }
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator "Ninja" -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DBUILD_SHARED_LIBS=ON",
                "-DPKG_CONFIG_EXECUTABLE=$PREFIX_PATH_FORWARD/bin/pkgconf.exe",
                "-DQT_BUILD_EXAMPLES=OFF",
                "-DQT_BUILD_TESTS=OFF",
                "-DFEATURE_openssl=ON",
                "-DFEATURE_openssl_linked=ON",
                "-DFEATURE_system_zlib=ON",
                "-DFEATURE_system_png=ON",
                "-DFEATURE_system_jpeg=ON",
                "-DFEATURE_system_pcre2=ON",
                "-DFEATURE_system_freetype=ON",
                "-DFEATURE_system_harfbuzz=ON",
                "-DFEATURE_system_sqlite=ON",
                "-DICU_ROOT=$PREFIX_PATH_FORWARD"
            )
    } finally {
        Pop-Location
    }
}

function Build-Strawberry {
    Write-Host "Building strawberry" -ForegroundColor Yellow
    
    Push-Location $BUILD_PATH
    try {
        if (-not (Test-Path "strawberry")) {
            New-Item -ItemType Directory -Path "strawberry" -Force | Out-Null
            Copy-Item "$DOWNLOADS_PATH\strawberry\*" "strawberry\" -Recurse -Force
        }
        
        Set-Location "strawberry"
        
        Invoke-CMakeBuild -SourcePath "." -BuildPath "build" `
            -Generator $CMAKE_GENERATOR -BuildType $CMAKE_BUILD_TYPE `
            -InstallPrefix $PREFIX_PATH_FORWARD `
            -AdditionalArgs @(
                "-DCMAKE_PREFIX_PATH=$PREFIX_PATH_FORWARD/lib/cmake",
                "-DARCH=x86_64",
                "-DENABLE_TRANSLATIONS=ON",
                "-DBUILD_WERROR=ON",
                "-DENABLE_WIN32_CONSOLE=OFF",
                "-DICU_ROOT=$PREFIX_PATH",
                "-DENABLE_AUDIOCD=OFF",
                "-DENABLE_MTP=OFF",
                "-DENABLE_GPOD=OFF"
            )
        
        Write-Host "Strawberry built successfully!" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}

#endregion

#region Main Build Logic

Write-Host "Starting build process..." -ForegroundColor Cyan
Write-Host ""

try {
    # Check what needs to be built
    $buildQueue = @()
    
    if (-not (Test-Path "$PREFIX_PATH\bin\yasm.exe")) { $buildQueue += "yasm" }
    if (-not (Test-Path "$PREFIX_PATH\bin\pkgconf.exe")) { $buildQueue += "pkgconf" }
    if (-not (Test-Path "$PREFIX_PATH\lib\getopt.lib")) { $buildQueue += "getopt-win" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\zlib.pc")) { $buildQueue += "zlib" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\openssl.pc")) { $buildQueue += "openssl" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\gmp.pc")) { $buildQueue += "gmp" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\nettle.pc")) { $buildQueue += "nettle" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\gnutls.pc")) { $buildQueue += "gnutls" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libpng.pc")) { $buildQueue += "libpng" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libjpeg.pc")) { $buildQueue += "libjpeg" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libpcre2-16.pc")) { $buildQueue += "pcre2" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\bzip2.pc")) { $buildQueue += "bzip2" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\liblzma.pc")) { $buildQueue += "xz" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libbrotlicommon.pc")) { $buildQueue += "brotli" }
    if (-not (Test-Path "$PREFIX_PATH\lib\libiconv*.lib")) { $buildQueue += "libiconv" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\icu-uc.pc")) { $buildQueue += "icu4c" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\pixman-1.pc")) { $buildQueue += "pixman" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\expat.pc")) { $buildQueue += "expat" }
    if (-not (Test-Path "$PREFIX_PATH\include\boost\config.hpp")) { $buildQueue += "boost" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libxml-2.0.pc")) { $buildQueue += "libxml2" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libnghttp2.pc")) { $buildQueue += "nghttp2" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libffi.pc")) { $buildQueue += "libffi" }
    if (-not (Test-Path "$PREFIX_PATH\include\dlfcn.h")) { $buildQueue += "dlfcn-win32" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libpsl.pc")) { $buildQueue += "libpsl" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\orc-0.4.pc")) { $buildQueue += "orc" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\sqlite3.pc")) { $buildQueue += "sqlite" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\glib-2.0.pc")) { $buildQueue += "glib" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libsoup-3.0.pc")) { $buildQueue += "libsoup" }
    if (-not (Test-Path "$PREFIX_PATH\lib\gio\modules\gioopenssl.lib")) { $buildQueue += "glib-networking" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\freetype2.pc")) { $buildQueue += "freetype" }
    if (-not (Test-Path "$PREFIX_PATH\lib\harfbuzz*.lib")) { $buildQueue += "harfbuzz" }
    if (-not (Test-Path "$PREFIX_PATH\lib\avutil.lib")) { $buildQueue += "ffmpeg" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\libchromaprint.pc")) { $buildQueue += "chromaprint" }
    if (-not (Test-Path "$PREFIX_PATH\lib\pkgconfig\gstreamer-1.0.pc")) { $buildQueue += "gstreamer" }
    if (-not (Test-Path "$PREFIX_PATH\bin\qt-configure-module.bat")) { $buildQueue += "qt" }
    if (-not (Test-Path "$BUILD_PATH\strawberry\build\strawberrysetup*.exe")) { $buildQueue += "strawberry" }
    
    if ($buildQueue.Count -eq 0) {
        Write-Host "All dependencies already built!" -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Build queue: $($buildQueue -join ', ')" -ForegroundColor Cyan
    Write-Host ""
    
    # Build each component
    foreach ($component in $buildQueue) {
        Write-Host "========================================" -ForegroundColor Magenta
        Write-Host "Building: $component" -ForegroundColor Magenta
        Write-Host "========================================" -ForegroundColor Magenta
        
        switch ($component) {
            "yasm" { Build-Yasm }
            "pkgconf" { Build-Pkgconf }
            "getopt-win" { Build-GetoptWin }
            "zlib" { Build-Zlib }
            "openssl" { Build-OpenSSL }
            "gmp" { Build-GMP }
            "nettle" { Build-Nettle }
            "gnutls" { Build-GnuTLS }
            "libpng" { Build-LibPNG }
            "libjpeg" { Build-LibJPEG }
            "pcre2" { Build-PCRE2 }
            "bzip2" { Build-BZip2 }
            "xz" { Build-XZ }
            "brotli" { Build-Brotli }
            "libiconv" { Build-LibIconv }
            "icu4c" { Build-ICU4C }
            "pixman" { Build-Pixman }
            "expat" { Build-Expat }
            "boost" { Build-Boost }
            "libxml2" { Build-LibXML2 }
            "nghttp2" { Build-NGHttp2 }
            "libffi" { Build-LibFFI }
            "dlfcn-win32" { Build-DlfcnWin32 }
            "libpsl" { Build-LibPSL }
            "orc" { Build-Orc }
            "sqlite" { Build-SQLite }
            "glib" { Build-Glib }
            "libsoup" { Build-LibSoup }
            "glib-networking" { Build-GlibNetworking }
            "freetype" { Build-Freetype }
            "harfbuzz" { Build-Harfbuzz }
            "ffmpeg" { Build-FFmpeg }
            "chromaprint" { Build-Chromaprint }
            "gstreamer" { Build-GStreamer }
            "qt" { Build-Qt }
            "strawberry" { Build-Strawberry }
            default {
                Write-Warning "Unknown component: $component (skipping)"
            }
        }
        
        Write-Host "Completed: $component" -ForegroundColor Green
        Write-Host ""
    }
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}

#endregion
