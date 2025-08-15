@echo off
echo ==============================================
echo          Garbage Factories 环境检测
echo ==============================================

:: 检测 Git
echo [1/4] 检测 Git...
where git >nul 2>nul
if %errorLevel% equ 0 (
    echo [√] Git 已安装:
    git --version | findstr "version"
) else (
    echo [×] Git 未安装或未添加到环境变量，请先安装 Git！
    pause
    exit /b 1
)

:: 检测 Python 3.10+
echo.
echo [2/4] 检测 Python 3.10+...
where python >nul 2>nul
if %errorLevel% equ 0 (
    for /f "delims=" %%v in ('python --version 2^>^&1 ^| findstr /i "python 3.10"') do (
        set "py_ver=%%v"
    )
    if defined py_ver (
        echo [√] Python 版本符合要求: %py_ver%
    ) else (
        echo [×] Python 版本需 3.10+，当前版本:
        python --version
        pause
        exit /b 1
    )
) else (
    echo [×] Python 未安装或未添加到环境变量，请先安装 Python 3.10！
    pause
    exit /b 1
)

:: 检测 FFmpeg
echo.
echo [3/4] 检测 FFmpeg...
where ffmpeg >nul 2>nul
if %errorLevel% equ 0 (
    echo [√] FFmpeg 已安装:
    ffmpeg -version | findstr "ffmpeg version"
) else (
    echo [×] FFmpeg 未安装或未添加到环境变量，请先安装 FFmpeg！
    pause
    exit /b 1
)

:: 检测依赖库（核心库示例）
echo.
echo [4/4] 检测核心 Python 依赖...
python -c "import cv2, torch, numpy, pillow, json" >nul 2>nul
if %errorLevel% equ 0 (
    echo [√] 基础依赖已安装
) else (
    echo [×] 部分基础依赖缺失，请运行 setup.cmd 安装！
    pause
    exit /b 1
)

echo.
echo ==============================================
echo          环境检测通过，可正常启动项目！
echo ==============================================
pause