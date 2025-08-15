@echo off
echo ==============================================
echo          启动 Garbage Factories
echo ==============================================
echo 提示：请先将原始视频放入 input/ 目录，并命名为 input.mp4
echo （或修改 main.py 中的输入路径）
echo.

:: 先检测环境，再启动完整流程
call check.bat
if %errorLevel% equ 0 (
    echo.
    echo 请选择AI模型：
    echo 1. Anime2Sketch（素描风格）
    echo 2. AnimeGANv2（动漫风格）
    echo 3. Stable Diffusion 3.5（创意风格）
    set /p model_choice=请输入模型选项（1-3）：
    
    if "%model_choice%"=="1" (
        set model=anime2sketch
    ) else if "%model_choice%"=="2" (
        set model=animeganv2
    ) else if "%model_choice%"=="3" (
        set model=stable_diffusion_3.5
    ) else (
        echo 无效模型选项！
        pause
        exit /b 1
    )
    
    echo 开始完整流程...
    python main.py --action full --input_video input/input.mp4 --frame_dir output/frames --processed_dir output/processed --output_video output/final.mp4 --model %model% --fps 30
    echo.
    echo 处理完成！最终视频：output/final.mp4
) else (
    echo 环境检测失败，无法启动项目！
)

pause