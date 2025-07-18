@echo off
setlocal enabledelayedexpansion

:: 检查必要的工具
echo 正在检查环境依赖...
echo.

:: 检查 Git
where git >nul 2>&1
if errorlevel 1 (
    echo [错误] Git 未安装或未添加到环境变量
    echo 请从 https://git-scm.com/downloads 安装 Git
) else (
    echo [成功] Git 已安装
)

:: 检查 Python
where python >nul 2>&1
if errorlevel 1 (
    echo [错误] Python 未安装或未添加到环境变量
    echo 请从 https://www.python.org/downloads/ 安装 Python 3.10
) else (
    python -c "import sys; print('[成功] Python 版本:', sys.version)" 2>nul
)

:: 检查 FFmpeg
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo [错误] FFmpeg 未安装或未添加到环境变量
    echo 请从 https://ffmpeg.org/download.html 安装 FFmpeg
) else (
    echo [成功] FFmpeg 已安装
)

:: 检查 Miniconda
where conda >nul 2>&1
if errorlevel 1 (
    echo [警告] Miniconda 未安装
    echo 运行 download.bat 可自动安装 Miniconda
) else (
    echo [成功] Miniconda 已安装
)

:: 检查 Python 依赖
echo.
echo 正在检查 Python 依赖...
pip list | findstr /i "torch opencv-python comfy-cli Pillow" >nul
if errorlevel 1 (
    echo [警告] 部分 Python 依赖未安装
    echo 运行 setup.cmd 安装所有依赖
) else (
    echo [成功] Python 依赖已安装
)

echo.
echo 环境检查完成
pause
exit /b 0