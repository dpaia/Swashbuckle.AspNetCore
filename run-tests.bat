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

REM The ReDoc/SwaggerUI front-end assets (e.g. redoc.standalone.js) are normally
REM restored by an MSBuild "npm ci" target hooked to BeforeTargets=DispatchToInnerBuilds.
REM That target only runs for multi-target builds. Because we pass --framework net10.0
REM (a single TFM), the inner-build dispatch is skipped and the restore never fires,
REM leaving node_modules absent and the build failing. Restore them here when missing.
where npm >nul 2>nul
if errorlevel 1 (
    echo ERROR: npm is required to restore ReDoc/SwaggerUI assets but was not found on PATH.
    endlocal ^& exit /b 1
)

for %%P in (Swashbuckle.AspNetCore.ReDoc Swashbuckle.AspNetCore.SwaggerUI) do (
    if not exist "%~dp0src\%%P\node_modules" (
        echo Restoring npm packages for %%P ...
        pushd "%~dp0src\%%P"
        call npm ci
        if errorlevel 1 (
            echo ERROR: 'npm ci' failed for %%P.
            popd
            endlocal ^& exit /b 1
        )
        popd
    )
)

echo.

REM Run the tests, filtering out the benign "Unhandled exception" blocks the CLI
REM negative-tests trigger on purpose: they spawn the Swashbuckle CLI with unsupported
REM --openapiversion values, the CLI throws NotSupportedException by design, and the
REM tests assert on that. The child process writes those stack traces straight to the
REM console (stderr), so dotnet test verbosity flags can't hide them — we drop them
REM from the live stream here instead. We merge stderr (2>&1) so the filter can see
REM them, and exit with $LASTEXITCODE, which keeps dotnet's real exit code because
REM Where-Object is a cmdlet, not a native command.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%DOTNET%' test 'Swashbuckle.AspNetCore.slnx' --configuration Release --framework net10.0 %* 2>&1 | Where-Object { $_ -notmatch '^(Unhandled exception\.|\s+at |--- End of stack trace)' }; exit $LASTEXITCODE"

set EXITCODE=%ERRORLEVEL%

echo.
if %EXITCODE% equ 0 (
    echo All tests passed.
) else (
    echo Tests failed with exit code %EXITCODE%.
)

endlocal & exit /b %EXITCODE%
