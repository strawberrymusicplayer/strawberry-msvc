@echo off
@setlocal enabledelayedexpansion

rem Read package versions from package-versions.txt
for /f "usebackq tokens=1,2 delims== eol=#" %%a in ("%~dp0package-versions.txt") do (
  @set %%a=%%b
)

rem Derived versions (calculated from base versions)
@set BOOST_VERSION_UNDERSCORE=%BOOST_VERSION:.=_%
@set EXPAT_VERSION_UNDERSCORE=%EXPAT_VERSION:.=_%
@set STRAWBERRY_PERL_VERSION_STRIPPED=%STRAWBERRY_PERL_VERSION:.=%
@set CURL_VERSION_UNDERSCORE=%CURL_VERSION:.=_%
