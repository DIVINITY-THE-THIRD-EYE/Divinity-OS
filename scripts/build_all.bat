@echo off
title Divinity Unified Builder
echo =========================================================
echo        DIVINITY ACADEMY OPERATING SYSTEM - BUILDER
echo =========================================================
echo   Location: %~dp0
echo.

set START_TIME=%time%

:: 1. Next.js Website Build
echo [1/3] Building Next.js Website...
if exist "%~dp0..\website" (
    pushd "%~dp0..\website"
    echo   Installing dependencies...
    call npm install
    echo   Running Next.js production compilation...
    call npm run build
    if %errorlevel% equ 0 (
        echo   [OK] Website built successfully!
    ) else (
        echo   [ERROR] Website compilation failed!
    )
    popd
) else (
    echo   [WARN] 'website' folder not found.
)
echo.

:: 2. Flutter Android Build
echo [2/3] Building Flutter Android App (APK)...
if exist "%~dp0..\flutter-app" (
    pushd "%~dp0..\flutter-app"
    echo   Running flutter pub get...
    call flutter pub get
    echo   Compiling release APK...
    call flutter build apk --release --dart-define-from-file=dart_defines.json
    if %errorlevel% equ 0 (
        echo   [OK] Android release APK generated successfully!
        echo   Output: flutter-app\build\app\outputs\flutter-apk\app-release.apk
    ) else (
        echo   [ERROR] Flutter Android build failed!
    )
    popd
) else (
    echo   [WARN] 'flutter-app' folder not found.
)
echo.

:: 3. Flutter iOS Build
echo [3/3] Building Flutter iOS App...
echo   [INFO] iOS build skipped (Requires macOS and Xcode).
echo   To build for iOS, copy the repo to a macOS machine and run:
echo     cd flutter-app
echo     flutter build ios --no-codesign --dart-define-from-file=dart_defines.json
echo.

echo =========================================================
echo   Build Finished. Start: %START_TIME% - End: %time%
echo =========================================================
pause
