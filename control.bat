@echo off
setlocal enabledelayedexpansion

:: 项目基础目录
set "BASE_DIR=%~dp0"

:menu
cls
echo.
echo  ===== 垃圾工厂流程控制 =====
echo.
echo  1. 视频拆帧 (提取所有帧)
echo  2. 图片转线稿
echo  3. AI重绘线稿
echo  4. 合成视频
echo  5. 全自动处理
echo  0. 退出
echo.
set /p choice=请选择操作 (0-5): 

if "%choice%"=="1" goto extract_frames
if "%choice%"=="2" goto convert_sketch
if "%choice%"=="3" goto recreate_images
if "%choice%"=="4" goto synthesize_video
if "%choice%"=="5" goto full_process
if "%choice%"=="0" exit /b 0

goto menu

:extract_frames
echo 正在执行视频拆帧...
python "%BASE_DIR%Frame_Extraction\frame_extractor\extractor.py" -v "%BASE_DIR%input" -o "%BASE_DIR%output\frames"
if errorlevel 1 (
    echo 拆帧失败，请检查输入视频
) else (
    echo 拆帧完成！帧保存在: %BASE_DIR%output\frames
)
pause
goto menu

:convert_sketch
echo 正在转换为线稿...
python "%BASE_DIR%Sketch_Conversion\Anime2Sketch\test.py" --dataroot "%BASE_DIR%output\frames" --load_size 512 --output_dir "%BASE_DIR%output\sketches"
if errorlevel 1 (
    echo 线稿转换失败
) else (
    echo 线稿转换完成！保存在: %BASE_DIR%output\sketches
)
pause
goto menu

:recreate_images
echo 正在使用AI重绘线稿...
comfy launch --workspace "%BASE_DIR%Image_Recreation\ComfyUI" --input_dir "%BASE_DIR%output\sketches" --output "%BASE_DIR%output\recreated" --model stabilityai/stable-diffusion-3.5-large
if errorlevel 1 (
    echo AI重绘失败
) else (
    echo AI重绘完成！保存在: %BASE_DIR%output\recreated
)
pause
goto menu

:synthesize_video
echo 正在合成视频...
set "ffmpeg_path="
where ffmpeg >nul && set ffmpeg_path=ffmpeg

if not defined ffmpeg_path (
    if exist "%BASE_DIR%Video_Synthesis\FFmpeg-Builds\bin\ffmpeg.exe" (
        set "ffmpeg_path=%BASE_DIR%Video_Synthesis\FFmpeg-Builds\bin\ffmpeg.exe"
    ) else (
        echo 找不到FFmpeg可执行文件
        pause
        goto menu
    )
)

%ffmpeg_path% -framerate 24 -i "%BASE_DIR%output\recreated\frame%%04d.png" -c:v libx264 -pix_fmt yuv420p "%BASE_DIR%output\final_video.mp4" -y
if errorlevel 1 (
    echo 视频合成失败
) else (
    echo 视频合成完成！保存为: %BASE_DIR%output\final_video.mp4
)
pause
goto menu

:full_process
call :extract_frames
call :convert_sketch
call :recreate_images
call :synthesize_video
goto menu