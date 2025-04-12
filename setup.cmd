
:: 检查 Node.js 是否已安装
::node -v >nul 2>&1
::if errorlevel 1 (
::   echo Node.js not found. Downloading and installing Node.js...
::    set "NODE_INSTALLER_URL=https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi"
::    set "NODE_INSTALLER=node_installer.msi"
::    
::    powershell -Command "Invoke-WebRequest -Uri '%NODE_INSTALLER_URL%' -OutFile '%NODE_INSTALLER%'"
 ::   if errorlevel 1 (
::        echo Failed to download Node.js installer. Please check your internet connection.
::        exit /b 1
 ::   )
 ::   
 ::   msiexec /i "%NODE_INSTALLER%" /quiet /norestart
 ::   if errorlevel 1 (
  ::      echo Failed to install Node.js. Please install it manually.
 ::       exit /b 1
 ::   )
 ::   
   :: del "%NODE_INSTALLER%"
  ::  if errorlevel 1 (
  ::      echo Failed to delete Node.js installer.
   ::     exit /b 1
  ::  )
    
   :: echo Node.js and npm have been successfully installed.
::) else (
 ::   echo Node.js is already installed.
::)
:: 检查 npm 是否已安装
::npm -v >nul 2>&1
::if errorlevel 1 (
 ::   echo npm not found. Attempting to install npm...
 ::   node -v >nul 2>&1
 ::   if errorlevel 1 (
  ::      echo Node.js is not installed. Please install Node.js first.
  ::      exit /b 1
  ::  )
  ::  echo npm is included with Node.js. Updating npm to the latest version...
  ::  npm install -g npm
  ::  if errorlevel 1 (
  ::      echo Failed to install or update npm. Please check your Node.js installation.
  ::      exit /b 1
  ::  )
  ::  echo npm has been successfully installed or updated.
::) else (
   :: echo npm is already installed.
  ::  echo Updating npm to the latest version...
  ::  npm install -g npm
 ::   if errorlevel 1 (
  ::      echo Failed to update npm. Please check your Node.js installation.
  ::      exit /b 1
  ::  )
  ::  echo npm has been successfully updated.
::)
:: 删除虚拟环境的代码
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

:: 检查并清空 frame_extractor 目录
if exist "%FRAME_EXTRACTION_DIR%\frame_extractor" (
    echo Directory for frame_extractor already exists. Cleaning up...
    rmdir /s /q "%FRAME_EXTRACTION_DIR%\frame_extractor"
    if errorlevel 1 (
        echo Failed to clean up frame_extractor directory.
        exit /b 1
    )
)

:: 克隆 frame_extractor 项目
echo Cloning frame_extractor repository...
git clone https://github.com/OldDriver258/frame_extractor.git "%FRAME_EXTRACTION_DIR%\frame_extractor"
if errorlevel 1 (
    echo Failed to clone frame_extractor.
    exit /b 1
)

:: 检查并清空 Anime2Sketch 目录
if exist "%SKETCH_CONVERSION_DIR%\Anime2Sketch" (
    echo Directory for Anime2Sketch already exists. Cleaning up...
    rmdir /s /q "%SKETCH_CONVERSION_DIR%\Anime2Sketch"
    if errorlevel 1 (
        echo Failed to clean up Anime2Sketch directory.
        exit /b 1
    )
)

:: 克隆 Anime2Sketch 项目
echo Cloning Anime2Sketch repository...
git clone https://github.com/Mukosame/Anime2Sketch.git "%SKETCH_CONVERSION_DIR%\Anime2Sketch"
if errorlevel 1 (
    echo Failed to clone Anime2Sketch.
    exit /b 1
)

:: 检查并清空 FFmpeg-Builds 目录
if exist "%VIDEO_SYNTHESIS_DIR%\FFmpeg-Builds" (
    echo Directory for FFmpeg-Builds already exists. Cleaning up...
    rmdir /s /q "%VIDEO_SYNTHESIS_DIR%\FFmpeg-Builds"
    if errorlevel 1 (
        echo Failed to clean up FFmpeg-Builds directory.
        exit /b 1
    )
)

:: 克隆 FFmpeg-Builds 项目
echo Cloning FFmpeg-Builds repository...
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
cd /d "%BASE_DIR%"
pip install %PIP_SOURCE% -r requirement.txt
if errorlevel 1 (
    echo Failed to install requirements in frame_extractor.
    exit /b 1
)

:: 定义 Stable Diffusion 目录
set "STABLE_DIFFUSION_DIR=%BASE_DIR%stable-diffusion"

:: 检查并清空 Stable Diffusion 目录
if exist "%STABLE_DIFFUSION_DIR%" (
    echo Directory for Stable Diffusion already exists. Cleaning up...
    rmdir /s /q "%STABLE_DIFFUSION_DIR%"
    if errorlevel 1 (
        echo Failed to clean up Stable Diffusion directory.
        exit /b 1
    )
)

:: 克隆 Stable Diffusion 仓库
echo Cloning Stable Diffusion repository...
git clone https://github.com/CompVis/stable-diffusion.git "%STABLE_DIFFUSION_DIR%"
if errorlevel 1 (
    echo Failed to clone Stable Diffusion repository. Please check your network connection.
    exit /b 1
)

:: 检查 Stable Diffusion 目录是否有效
if not exist "%STABLE_DIFFUSION_DIR%\environment.yaml" (
    echo Stable Diffusion directory is invalid or environment.yaml is missing. Please check the repository.
    exit /b 1
)

:: 切换到 Stable Diffusion 目录
cd /d "%STABLE_DIFFUSION_DIR%"
:: 添加 Miniconda 到环境变量
set "CONDA_PATH=%USERPROFILE%\Miniconda3"
set "CONDA_SCRIPTS_PATH=%CONDA_PATH%\Scripts"
set "CONDA_BIN_PATH=%CONDA_PATH%\Library\bin"

:: 检查 Miniconda 路径是否存在
if not exist "%CONDA_SCRIPTS_PATH%\conda.exe" (
    echo Miniconda installation is invalid. Please reinstall Miniconda.
    exit /b 1
)

:: 动态添加到当前会话的 PATH
set "PATH=%CONDA_SCRIPTS_PATH%;%CONDA_BIN_PATH%;%PATH%"

:: 验证 Conda 是否可用
conda --version >nul 2>&1
if errorlevel 1 (
    echo Failed to add Miniconda to PATH. Please check your installation.
    exit /b 1
)

echo Miniconda has been successfully added to PATH.
:: 检查并安装 Conda
echo Checking for Conda installation...
conda --version >nul 2>&1
if errorlevel 1 (
    echo Conda is not installed. Please install Miniconda or Anaconda first.
    exit /b 1
)

:: 创建并激活 Conda 环境
echo Creating Conda environment for Stable Diffusion...
conda env create -f environment.yaml
if errorlevel 1 (
    echo Failed to create Conda environment. Please check the environment.yaml file.
    exit /b 1
)

echo Activating Conda environment...
conda activate ldm
if errorlevel 1 (
    echo Failed to activate Conda environment. Please ensure Conda is properly installed.
    exit /b 1
)

:: 下载预训练模型
set "MODEL_DIR=%STABLE_DIFFUSION_DIR%\models\ldm\stable-diffusion-v1"
if not exist "%MODEL_DIR%" mkdir "%MODEL_DIR%"

echo Downloading Stable Diffusion pretrained model...
powershell -Command "Invoke-WebRequest -Uri 'https://huggingface.co/CompVis/stable-diffusion-v-1-4/resolve/main/sd-v1-4.ckpt' -OutFile '%MODEL_DIR%\model.ckpt'"
if errorlevel 1 (
    echo Failed to download Stable Diffusion pretrained model. Please check your network connection.
    exit /b 1
)

:: 部署完成
echo Stable Diffusion has been successfully deployed!

pause
exit /b 0