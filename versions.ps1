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
      if ($line -match '^([^=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        # Only set variable if value is not empty
        if ($value) {
          # Set as global variable
          Set-Variable -Name $name -Value $value -Scope Global
        }
      }
    }
  }
}
else {
  Write-Error "Package versions file not found: $versionFile"
  exit 1
}

# Derived versions (calculated from base versions)
if ($global:BOOST_VERSION) {
  $global:BOOST_VERSION_UNDERSCORE = $global:BOOST_VERSION.Replace(".", "_")
}
if ($global:EXPAT_VERSION) {
  $global:EXPAT_VERSION_UNDERSCORE = $global:EXPAT_VERSION.Replace(".", "_")
}
if ($global:STRAWBERRY_PERL_VERSION) {
  $global:STRAWBERRY_PERL_VERSION_STRIPPED = $global:STRAWBERRY_PERL_VERSION.Replace(".", "")
}
if ($global:CURL_VERSION) {
  $global:CURL_VERSION_UNDERSCORE = $global:CURL_VERSION.Replace(".", "_")
}

