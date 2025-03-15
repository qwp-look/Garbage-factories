@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
set "LANG=zh_CN.UTF-8"
set "PYTHONIOENCODING=utf-8"
:: 创建factory文件夹并移动项目文件
if not exist C:\factory mkdir C:\factory
xcopy /E /I "C:\path\to\frame_extractor" "C:\factory\frame_extractor"
xcopy /E /I "C:\path\to\Anime2Sketch" "C:\factory\Anime2Sketch"
xcopy /E /I "C:\path\to\ComfyUI" "C:\factory\ComfyUI"
xcopy /E /I "C:\path\to\FFmpeg-Builds" "C:\factory\FFmpeg-Builds"

:: 设置输出文件夹
set OUTPUT_DIR=C:\factory\output
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

:: 让用户输入视频文件路径
set /p INPUT_VIDEO=请输入视频文件的完整路径: 

:: 定义函数
:menu
cls
echo "(_________             ______                       _________            _____              ____  __ _______    ____ __)",
echo "(__  ____/_____ __________  /_______ _______ _____  __  ____/_____ ________  /_______________  / / / __  __ \   / // /)",
echo "(_  / __ _  __ `/_  ___/_  __ \  __ `/_  __ `/  _ \ _  /_   _  __ `/  ___/  __/  __ \_  ___/  /_/ / /  / / /  /  // /_)",
echo "(/ /_/ / / /_/ /_  /   _  /_/ / /_/ /_  /_/ //  __/   __/   / /_/ // /__ / /_ / /_/ /  /   _\__, /  / /_/ /__ /__  __/)",
echo "(\____/  \__,_/ /_/    /_.___/\__,_/ _\__, / \___/ /_/      \__,_/ \___/ \__/ \____//_/   \_____/   \____/_(_)  /_/   )"
echo Made by:
echo Code qwp LZWei
echo UI Mech_Transistor
echo.
echo  "1.视频转图片"
echo  "2.图片转线稿"
echo  "3.线稿二创"
echo  "4.合成视频"
echo  "5.自动完成所有"
echo.
set /p choice=请输入选项（1-5）：
if "%choice%"=="1" goto video_to_frames
if "%choice%"=="2" goto image_to_sketch
if "%choice%"=="3" goto sketch_to_art
if "%choice%"=="4" goto frames_to_video
if "%choice%"=="5" goto auto_all
goto menu

:video_to_frames
echo 正在处理视频转图片...
cd /d C:\factory\Frame_Extraction\frame_extractor
:: 修改为提取所有帧
C:\Users\WTG\AppData\Local\Programs\Python\Python310\python.exe extractor.py -v C:\factory\input -o C:\factory\output
goto menu

:image_to_sketch
echo 正在处理图片转线稿...
cd /d C:\factory\Sketch_Conversion\Anime2Sketch
C:\Users\WTG\AppData\Local\Programs\Python\Python310\python.exe test.py --dataroot C:\factory\output\output_123\frame --load_size 512 --output_dir C:\factory\output\output_123\output-2
goto menu

:sketch_to_art
echo 正在处理线稿二创...
cd /d C:\factory\ComfyUI
:: 使用stabilityai/stable-diffusion-3.5-large模型进行图生图
comfy launch -- --workspace C:\factory\ComfyUI --input_dir %OUTPUT_DIR%\sketches --output %OUTPUT_DIR%\art --model https://huggingface.co/stabilityai/stable-diffusion-3.5-large
goto menu

:frames_to_video
echo 正在合成视频...
cd /d C:\factory\FFmpeg-Builds\bin
ffmpeg -framerate 24 -i %OUTPUT_DIR%\art\frame%%03d.png -c:v libx264 -pix_fmt yuv420p %OUTPUT_DIR%\output_video.mp4
goto menu

:auto_all
echo 自动完成所有步骤...
call :video_to_frames
call :image_to_sketch
call :sketch_to_art
call :frames_to_video
goto menu