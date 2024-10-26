@echo on

@setlocal

@set DOWNLOADS_PATH=c:\data\projects\strawberry\msvc_\downloads

@call versions.bat


:install

@if not exist "C:\Program Files\Git\bin\git.exe" goto git
@if not exist "c:\Program Files\CMake\bin\cmake.exe" goto cmake
@if not exist "c:\Program Files\meson\meson.exe" goto meson
@if not exist "c:\Program Files\nasm\nasm.exe" goto nasm
@if not exist "c:\Program Files\7-zip\7z.exe" goto 7z
@if not exist "C:\Strawberry\perl\bin" goto perl
@if not exist "C:\Program Files\Python311\python.exe" goto python
@if not exist "c:\win_flex_bison\win_bison.exe" goto win_flex_bison
@if not exist "c:\win_flex_bison\win_flex.exe" goto win_flex_bison

goto end


:git

@echo Installing Git...

"%DOWNLOADS_PATH%\Git-%GIT_VERSION%-64-bit.exe" /silent /norestart || goto end

@goto install


:cmake

@echo Installing CMake...

"%DOWNLOADS_PATH%\cmake-%CMAKE_VERSION%-windows-x86_64.msi" /quiet /norestart || goto end

@goto install


:meson

@echo Installing Meson...

"%DOWNLOADS_PATH%\meson-%MESON_VERSION%-64.msi" /quiet /norestart || goto end

@goto install


:nasm

@echo Installing NASM...

"%DOWNLOADS_PATH%\nasm-%NASM_VERSION%-installer-x64.exe" /S || goto end

@goto install


:7z

@echo Installing 7-Zip...

"%DOWNLOADS_PATH%\7z%_7ZIP_VERSION%-x64.exe" /S || goto end

@goto install



:perl

@echo Installing Perl...

"%DOWNLOADS_PATH%\strawberry-perl-%PERL_VERSION%-64bit.msi" /quiet /norestart || goto end

@goto install


:python

@echo Installing Python...

"%DOWNLOADS_PATH%\python-%PYTHON_VERSION%-amd64.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 || goto end

@goto install


:win_flex_bison

c: || goto end
cd \ || goto end
if not exist "win_flex_bison" mkdir "win_flex_bison" || goto end
cd "win_flex_bison" || goto end
@7z --version >NUL 2>&1 || set PATH=%PATH%;C:\Program Files\7-Zip
"c:\Program Files\7-zip\7z.exe" x -aoa "%DOWNLOADS_PATH%\win_flex_bison-%WINFLEXBISON_VERSION%.zip" || goto end


@goto end


:end

@endlocal
