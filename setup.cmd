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
    echo Python not found. Please install Python 3.10 first.
    pause
    exit /b 1
)

:: 克隆 frame_extractor 项目
echo Cloning frame_extractor repository...
if not exist "%FRAME_EXTRACTION_DIR%\frame_extractor" (
    git clone https://github.com/OldDriver258/frame_extractor.git "%FRAME_EXTRACTION_DIR%\frame_extractor"
    if errorlevel 1 (
        echo Failed to clone frame_extractor.
        exit /b 1
    )
)

:: 克隆 Anime2Sketch 项目
echo Cloning Anime2Sketch repository...
if not exist "%SKETCH_CONVERSION_DIR%\Anime2Sketch" (
    git clone https://github.com/Mukosame/Anime2Sketch.git "%SKETCH_CONVERSION_DIR%\Anime2Sketch"
    if errorlevel 1 (
        echo Failed to clone Anime2Sketch.
        exit /b 1
    )
)

:: 克隆 ComfyUI 项目
echo Cloning ComfyUI repository...
if not exist "%IMAGE_RECREATION_DIR%\ComfyUI" (
    git clone https://github.com/comfyanonymous/ComfyUI.git "%IMAGE_RECREATION_DIR%\ComfyUI"
    if errorlevel 1 (
        echo Failed to clone ComfyUI.
        exit /b 1
    )
)

:: 克隆 FFmpeg-Builds 项目
echo Cloning FFmpeg-Builds repository...
if not exist "%VIDEO_SYNTHESIS_DIR%\FFmpeg-Builds" (
    git clone https://github.com/BtbN/FFmpeg-Builds.git "%VIDEO_SYNTHESIS_DIR%\FFmpeg-Builds"
    if errorlevel 1 (
        echo Failed to clone FFmpeg-Builds.
        exit /b 1
    )
)

:: 选择 pip 源
echo.
echo 请选择 pip 源加速下载:
echo 1. 豆瓣源 (推荐国内使用)
echo 2. 清华大学源
echo 3. 阿里云源
echo 4. 官方源 (国际用户)
echo.
set /p choice="请输入选项 (1-4): "
set "PIP_SOURCE="
if "%choice%"=="1" set "PIP_SOURCE= -i https://pypi.doubanio.com/simple/"
if "%choice%"=="2" set "PIP_SOURCE= -i https://pypi.tuna.tsinghua.edu.cn/simple"
if "%choice%"=="3" set "PIP_SOURCE= -i https://mirrors.aliyun.com/pypi/simple/"

:: 安装依赖
echo.
echo 正在安装 Python 依赖...
cd /d "%BASE_DIR%"
pip install %PIP_SOURCE% -r requirement.txt
if errorlevel 1 (
    echo 依赖安装失败，请检查网络连接
    exit /b 1
)

:: 下载 Stable Diffusion 3.5 模型
echo.
echo 正在下载 Stable Diffusion 3.5 模型...
set "MODEL_DIR=%IMAGE_RECREATION_DIR%\ComfyUI\models\checkpoints"
if not exist "%MODEL_DIR%" mkdir "%MODEL_DIR%"

curl -L -o "%MODEL_DIR%\stable-diffusion-3.5.safetensors" https://huggingface.co/stabilityai/stable-diffusion-3-medium/resolve/main/sd3_medium.safetensors
if errorlevel 1 (
    echo 模型下载失败，请手动下载:
    echo https://huggingface.co/stabilityai/stable-diffusion-3-medium/resolve/main/sd3_medium.safetensors
    echo 并保存到: %MODEL_DIR%
)

echo.
echo ===== 安装完成! =====
echo 请将输入视频放入 input 文件夹
echo 运行 start.bat 开始处理
echo.
pause
exit /b 0