@echo off
cls
echo ==============================================
echo          Garbage Factories 流程控制
echo ==============================================
echo 请选择操作：
echo 1. 仅拆帧（输入视频 → 图片序列）
echo 2. 仅 AI 处理（图片序列 → 处理后图片）
echo 3. 仅合成视频（处理后图片 → 输出视频）
echo 4. 一键完整流程（拆帧→AI→合成）
echo 5. 退出
echo ==============================================
set /p choice=请输入选项（1-5）：

if "%choice%"=="1" (
    python main.py --action extract --input_video input/input.mp4 --frame_dir output/frames
    echo 拆帧完成，图片保存至 output/frames
) else if "%choice%"=="2" (
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
        call control.bat
        exit /b 1
    )
    
    python main.py --action ai_process --frame_dir output/frames --processed_dir output/processed --model %model%
    echo AI 处理完成，图片保存至 output/processed
) else if "%choice%"=="3" (
    python main.py --action synthesize --processed_dir output/processed --output_video output/final.mp4 --fps 30
    echo 视频合成完成，文件保存至 output/final.mp4
) else if "%choice%"=="4" (
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
        call control.bat
        exit /b 1
    )
    
    python main.py --action full --input_video input/input.mp4 --frame_dir output/frames --processed_dir output/processed --output_video output/final.mp4 --model %model% --fps 30
    echo 完整流程完成，最终视频保存至 output/final.mp4
) else if "%choice%"=="5" (
    echo 退出程序...
    exit /b 0
) else (
    echo 无效选项，请重新输入！
    pause
    call control.bat
)

pause