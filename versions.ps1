# versions.ps1
# Version definitions for Strawberry MSVC dependencies
# Reads versions from package-versions.txt

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$versionFile = Join-Path $scriptPath "package-versions.txt"

if (Test-Path $versionFile) {
  Get-Content $versionFile | ForEach-Object {
    $line = $_.Trim()
    # Skip empty lines and comments
    if ($line -and -not $line.StartsWith('#')) {
      if ($line -match '^([^=]+)=(.+)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        # Set as global variable
        Set-Variable -Name $name -Value $value -Scope Global
      }
    }
  }
}
else {
  Write-Error "Package versions file not found: $versionFile"
  exit 1
}

# Derived versions (calculated from base versions)
$global:BOOST_VERSION_UNDERSCORE = $global:BOOST_VERSION.Replace(".", "_")
$global:EXPAT_VERSION_UNDERSCORE = $global:EXPAT_VERSION.Replace(".", "_")
$global:STRAWBERRY_PERL_VERSION_STRIPPED = $global:STRAWBERRY_PERL_VERSION.Replace(".", "")
$global:CURL_VERSION_UNDERSCORE = $global:CURL_VERSION.Replace(".", "_")

