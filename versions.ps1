# versions.ps1
# Version definitions for Strawberry MSVC dependencies
# Reads versions from package-versions.txt

$script_path = Split-Path -Parent $MyInvocation.MyCommand.Path
$version_file = Join-Path $script_path "package-versions.txt"

if (Test-Path $version_file) {
  Get-Content $version_file | ForEach-Object {
    $line = $_.Trim()
    # Skip empty lines and comments
    if ($line -and -not $line.StartsWith('#')) {
      if ($line -match '^([^=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        # Only set variable if value is not empty
        if ($value) {
          # Convert variable name to lowercase
          $name_lower = $name.ToLower()
          # Set as global variable with lowercase name
          Set-Variable -Name $name_lower -Value $value -Scope Global
        }
      }
    }
  }
}
else {
  Write-Error "Package versions file not found: $version_file"
  exit 1
}

# Derived versions (calculated from base versions)
if ($global:boost_version) {
  $global:boost_version_underscore = $global:boost_version.Replace(".", "_")
}
if ($global:expat_version) {
  $global:expat_version_underscore = $global:expat_version.Replace(".", "_")
}
if ($global:strawberry_perl_version) {
  $global:strawberry_perl_version_stripped = $global:strawberry_perl_version.Replace(".", "")
}
if ($global:curl_version) {
  $global:curl_version_underscore = $global:curl_version.Replace(".", "_")
}

