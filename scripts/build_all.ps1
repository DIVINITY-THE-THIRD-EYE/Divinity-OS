# Divinity Unified Build Script (PowerShell)
# Builds the Next.js website and the Flutter mobile app (Android and iOS).
# Run from anywhere -- paths are resolved relative to this script's location
# in the monorepo: <repo-root>/scripts/build_all.ps1

Clear-Host
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "       DIVINITY ACADEMY OPERATING SYSTEM - BUILDER       " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Location: $PSScriptRoot" -ForegroundColor Gray
Write-Host ""

$Start = Get-Date
$RepoRoot = Resolve-Path "$PSScriptRoot\.."

# ---------------------------------------------------------
# 1. Next.js Website Build
# ---------------------------------------------------------
Write-Host "[1/3] Building Next.js Website..." -ForegroundColor Yellow
if (Test-Path "$RepoRoot\website") {
    Push-Location "$RepoRoot\website"
    Write-Host "  Installing dependencies..." -ForegroundColor Gray
    npm install
    Write-Host "  Running Next.js production compilation..." -ForegroundColor Gray
    npm run build
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Website built successfully!" -ForegroundColor Green
    } else {
        Write-Error "  [ERROR] Website compilation failed!"
    }
    Pop-Location
} else {
    Write-Warning "  [WARN] 'website' folder not found."
}

Write-Host ""

# ---------------------------------------------------------
# 2. Flutter Android Build
# ---------------------------------------------------------
Write-Host "[2/3] Building Flutter Android App (APK + AAB)..." -ForegroundColor Yellow
if (Test-Path "$RepoRoot\flutter-app") {
    Push-Location "$RepoRoot\flutter-app"
    Write-Host "  Running flutter pub get..." -ForegroundColor Gray
    flutter pub get
    Write-Host "  Compiling release APK..." -ForegroundColor Gray
    flutter build apk --release --dart-define-from-file=dart_defines.json
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Android release APK generated successfully!" -ForegroundColor Green
        Write-Host "  Output: flutter-app\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Gray
    } else {
        Write-Error "  [ERROR] Flutter Android APK build failed!"
    }
    Write-Host "  Compiling release AAB (App Bundle)..." -ForegroundColor Gray
    flutter build appbundle --release --dart-define-from-file=dart_defines.json
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Android release AAB generated successfully!" -ForegroundColor Green
        Write-Host "  Output: flutter-app\build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Gray
    } else {
        Write-Error "  [ERROR] Flutter Android AAB build failed!"
    }
    Pop-Location
} else {
    Write-Warning "  [WARN] 'flutter-app' folder not found."
}

Write-Host ""

# ---------------------------------------------------------
# 3. Flutter iOS Build
# ---------------------------------------------------------
Write-Host "[3/3] Building Flutter iOS App..." -ForegroundColor Yellow

$IsMac = $false
if ($PSVersionTable.OS -like "*Darwin*") {
    $IsMac = $true
} elseif (Get-Command uname -ErrorAction SilentlyContinue) {
    if ((uname -s) -like "*Darwin*") {
        $IsMac = $true
    }
}

if ($IsMac) {
    if (Test-Path "$RepoRoot\flutter-app") {
        Push-Location "$RepoRoot\flutter-app"
        Write-Host "  Running flutter build ios..." -ForegroundColor Gray
        flutter build ios --no-codesign --dart-define-from-file=dart_defines.json
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] iOS Runner built successfully!" -ForegroundColor Green
            Write-Host "  Output: flutter-app/build/ios/iphoneos/Runner.app" -ForegroundColor Gray
        } else {
            Write-Error "  [ERROR] Flutter iOS build failed!"
        }
        Pop-Location
    } else {
        Write-Warning "  [WARN] 'flutter-app' folder not found."
    }
} else {
    Write-Host "  [INFO] iOS build skipped (requires macOS)." -ForegroundColor Cyan
    Write-Host "  To build the iOS target, run this script or the following commands on a Mac:" -ForegroundColor Gray
    Write-Host "    cd flutter-app" -ForegroundColor Yellow
    Write-Host "    flutter build ios --no-codesign --dart-define-from-file=dart_defines.json" -ForegroundColor Yellow
}

Write-Host ""
$Elapsed = (Get-Date) - $Start
$FormattedTime = "{0:mm}m {0:ss}s" -f $Elapsed
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Build completed in $FormattedTime" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
