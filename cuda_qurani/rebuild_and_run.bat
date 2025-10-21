@echo off
echo ================================================
echo REBUILD COMPLETE - Cuda Qurani Mushaf Mode
echo ================================================
echo.
echo This will:
echo  1. Clean all build caches
echo  2. Get dependencies
echo  3. Build fresh APK with all 604 fonts
echo  4. Install to device CPH2083
echo.
echo Time estimate: 3-5 minutes (bundling fonts)
echo.
pause

cd /d "%~dp0"

echo [1/4] Cleaning build cache...
call flutter clean
if errorlevel 1 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)
echo.

echo [2/4] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)
echo.

echo [3/4] Building APK with all fonts (this takes 3-5 minutes)...
call flutter build apk --debug
if errorlevel 1 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)
echo.

echo [4/4] Installing to device CPH2083...
call adb install -r build\app\outputs\flutter-apk\app-debug.apk
if errorlevel 1 (
    echo ERROR: ADB install failed! Is device connected?
    pause
    exit /b 1
)
echo.

echo ================================================
echo SUCCESS! App installed with all mushaf fonts.
echo ================================================
echo.
echo APK path: build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Now launching app...
call adb shell am start -n com.example.cuda_qurani/com.example.cuda_qurani.MainActivity
echo.
echo DONE! Check your phone.
pause
