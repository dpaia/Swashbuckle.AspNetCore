@echo off
REM Runs all tests in the Swashbuckle.AspNetCore solution.

setlocal

REM Move to the directory this script lives in so it works from anywhere.
cd /d "%~dp0"

REM Prefer the SDK installed locally in .dotnet (pinned by global.json); fall back to PATH.
REM Also expose it via DOTNET_ROOT/PATH so child "dotnet" calls in the build
REM (e.g. the dotnet-swagger MSBuild step) resolve the local runtime too.
set "DOTNET=dotnet"
if exist "%~dp0.dotnet\dotnet.exe" (
    set "DOTNET=%~dp0.dotnet\dotnet.exe"
    set "DOTNET_ROOT=%~dp0.dotnet"
    set "PATH=%~dp0.dotnet;%PATH%"
)

echo Running .NET 10 (net10.0) tests for Swashbuckle.AspNetCore...
echo Using: %DOTNET%
echo.

"%DOTNET%" test "Swashbuckle.AspNetCore.slnx" --configuration Release --framework net10.0 %*

set EXITCODE=%ERRORLEVEL%

echo.
if %EXITCODE% equ 0 (
    echo All tests passed.
) else (
    echo Tests failed with exit code %EXITCODE%.
)

endlocal & exit /b %EXITCODE%
