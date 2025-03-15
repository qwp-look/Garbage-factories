@echo off
setlocal enabledelayedexpansion

:: 定义基础目录
set "BASE_DIR=%~dp0"

:: 创建功能文件夹
set "FRAME_EXTRACTION_DIR=%BASE_DIR%Frame_Extraction"
set "SKETCH_CONVERSION_DIR=%BASE_DIR%Sketch_Conversion"
set "IMAGE_RECREATION_DIR=%BASE_DIR%Image_Recreation"
set "VIDEO_SYNTHESIS_DIR=%BASE_DIR%Video_Synthesis"

md "%FRAME_EXTRACTION_DIR%" 2>nul
md "%SKETCH_CONVERSION_DIR%" 2>nul
md "%IMAGE_RECREATION_DIR%" 2>nul
md "%VIDEO_SYNTHESIS_DIR%" 2>nul

:: 检查 Python 是否已安装
python -V >nul 2>&1
if errorlevel 1 (
    echo Python not found. Installing Python...
    start /wait "" "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe" /quiet InstallAllUsers=1 PrependPath=1
    if errorlevel 1 (
        echo Failed to install Python. Please install it manually.
        exit /b 1
    )
)

:: 删除以下创建虚拟环境的代码
:: echo Creating virtual environment...
:: python -m venv .venv
:: if errorlevel 1 (
::     echo Failed to create virtual environment.
::     exit /b 1
:: )
:: call .venv\Scripts\activate.bat
:: if errorlevel 1 (
::     echo Failed to activate virtual environment.
::     exit /b 1
:: )

:: 克隆项目
echo Cloning projects...
git clone https://github.com/OldDriver258/frame_extractor.git "%FRAME_EXTRACTION_DIR%\frame_extractor"
if errorlevel 1 (
    echo Failed to clone frame_extractor.
    exit /b 1
)
git clone https://github.com/Mukosame/Anime2Sketch.git "%SKETCH_CONVERSION_DIR%\Anime2Sketch"
if errorlevel 1 (
    echo Failed to clone Anime2Sketch.
    exit /b 1
)
git clone https://github.com/BtbN/FFmpeg-Builds.git "%VIDEO_SYNTHESIS_DIR%\FFmpeg-Builds"
if errorlevel 1 (
    echo Failed to clone FFmpeg-Builds.
    exit /b 1
)

:: 选择 pip 源
echo Please select a pip source:
echo 1. Douban: https://pypi.doubanio.com/simple/
echo 2. Tsinghua: https://pypi.tuna.tsinghua.edu.cn/simple
echo 3. Alibaba: https://mirrors.aliyun.com/pypi/simple/
echo 4. Default: https://pypi.org/simple/
set /p choice="Enter the number of your choice (1-4): "
set "PIP_SOURCE="
if "%choice%"=="1" set "PIP_SOURCE= -i https://pypi.doubanio.com/simple/"
if "%choice%"=="2" set "PIP_SOURCE= -i https://pypi.tuna.tsinghua.edu.cn/simple"
if "%choice%"=="3" set "PIP_SOURCE= -i https://mirrors.aliyun.com/pypi/simple/"

:: 安装依赖
echo Installing dependencies...
cd /d "C:\factory"
pip install %PIP_SOURCE% -r requirement.txt
if errorlevel 1 (
    echo Failed to install requirements in frame_extractor.
    exit /b 1
)

:: 初始化 ComfyUI
echo Initializing ComfyUI...
cd /d "%IMAGE_RECREATION_DIR%\comfy-cli"
powershell -Command "comfy install"
if errorlevel 1 (
    echo Failed to initialize ComfyUI.
    exit /b 1
)

:: 下载 FFmpeg 预编译版本
:: echo Downloading FFmpeg...
:: cd /d "%VIDEO_SYNTHESIS_DIR%\FFmpeg-Builds"
:: :ffmpeg_download_loop
:: powershell -Command "Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/packages/ffmpeg-2025-02-02-git-957eb2323a-essentials_build.7z' -OutFile 'ffmpeg.zip'"
:: if errorlevel 1 (
::     echo Failed to download FFmpeg. Retrying...
::    goto ffmpeg_download_loop
:: )
:: powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg'"
:: if errorlevel 1 (
::     echo Failed to extract FFmpeg.
::     exit /b 1
:: )
:: del ffmpeg.zip
:: if errorlevel 1 (
::     echo Failed to delete FFmpeg zip file.
::     exit /b 1
:: )

:: 将 FFmpeg 的 bin 目录添加到系统环境变量的 Path 中
:: set "FFMPEG_BIN_DIR=%VIDEO_SYNTHESIS_DIR%\FFmpeg-Builds\ffmpeg\ffmpeg-master-latest-win64-gpl\bin"
:: setx PATH "%PATH%;%FFMPEG_BIN_DIR%" /M
:: if errorlevel 1 (
::     echo Failed to add FFmpeg to system environment variables.
::     exit /b 1
:: )
:: echo FFmpeg has been added to system environment variables.

:: 下载 Anime2Sketch 模型权重
echo Downloading Anime2Sketch model weights...
set "ANIME2SKETCH_DIR=%SKETCH_CONVERSION_DIR%\Anime2Sketch"
set "WEIGHTS_DIR=%ANIME2SKETCH_DIR%\weights"
if not exist "%WEIGHTS_DIR%" mkdir "%WEIGHTS_DIR%"

:model_download_menu
echo Please select a download source for Anime2Sketch model:
echo 1. Google Drive: https://drive.google.com/uc?id=1Srf-WYUixK0wiUddc9y3pNKHHno5PN6R
echo 2. Alternative Link: https://2a4f56d4.r25.cpolar.top/netG.pth
set /p model_choice="Enter the number of your choice (1-2): "

if "%model_choice%"=="1" (
    set "MODEL_URL=https://drive.google.com/uc?id=1Srf-WYUixK0wiUddc9y3pNKHHno5PN6R"
    set "MODEL_FILE=%WEIGHTS_DIR%\model.zip"
    :google_drive_download_loop
    powershell -Command "Invoke-WebRequest -Uri '%MODEL_URL%' -OutFile '%MODEL_FILE%'"
    if errorlevel 1 (
        echo Failed to download normal version of Anime2Sketch model weights from Google Drive. Retrying...
        goto google_drive_download_loop
    )
    powershell -Command "Expand-Archive -Path '%MODEL_FILE%' -DestinationPath '%WEIGHTS_DIR%'"
    if errorlevel 1 (
        echo Failed to extract normal version of Anime2Sketch model weights.
        exit /b 1
    )
    del "%MODEL_FILE%"
    if errorlevel 1 (
        echo Failed to delete normal version of Anime2Sketch model zip file.
        exit /b 1
    )
) else if "%model_choice%"=="2" (
    set "MODEL_URL=https://2a4f56d4.r25.cpolar.top/netG.pth"
    set "MODEL_FILE=%WEIGHTS_DIR%\netG.pth"
    :alternative_link_download_loop
    powershell -Command "Invoke-WebRequest -Uri '%MODEL_URL%' -OutFile '%MODEL_FILE%'"
    if errorlevel 1 (
        echo Failed to download Anime2Sketch model weights from alternative link. Retrying...
        goto alternative_link_download_loop
    )
) else (
    echo Invalid choice. Please try again.
    goto model_download_menu
)

:: 下载 artifact-free 版本权重
set "ARTIFACT_FREE_URL=https://drive.google.com/uc?id=1cf90_fPW-elGOKu5mTXT5N1dum-XY_46"
set "ARTIFACT_FREE_FILE=%WEIGHTS_DIR%\artifact_free_model.pth"
:artifact_free_download_loop
powershell -Command "Invoke-WebRequest -Uri '%ARTIFACT_FREE_URL%' -OutFile '%ARTIFACT_FREE_FILE%'"
if errorlevel 1 (
    echo Failed to download artifact-free version of Anime2Sketch model weights. Retrying...
    goto artifact_free_download_loop
)

echo All projects have been deployed successfully!
pause
exit /b 0