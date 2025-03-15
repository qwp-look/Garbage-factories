@echo off
setlocal enabledelayedexpansion

:: 定义基础目录
set "BASE_DIR=%~dp0"

:: 初始化 ComfyUI
echo Initializing ComfyUI...
cd /d "%IMAGE_RECREATION_DIR%\comfy-cli"
powershell -Command "comfy install"
if errorlevel 1 (
    echo Failed to initialize ComfyUI.
    exit /b 1
)

pause
exit /b 0