@echo off
echo ==============================================
echo          ���� Garbage Factories
echo ==============================================
echo ��ʾ�����Ƚ�ԭʼ��Ƶ���� input/ Ŀ¼��������Ϊ input.mp4
echo �����޸� main.py �е�����·����
echo.

:: �ȼ�⻷������������������
call check.bat
if %errorLevel% equ 0 (
    echo.
    echo ��ѡ��AIģ�ͣ�
    echo 1. Anime2Sketch��������
    echo 2. AnimeGANv2���������
    echo 3. Stable Diffusion 3.5��������
    set /p model_choice=������ģ��ѡ�1-3����
    
    if "%model_choice%"=="1" (
        set model=anime2sketch
    ) else if "%model_choice%"=="2" (
        set model=animeganv2
    ) else if "%model_choice%"=="3" (
        set model=stable_diffusion_3.5
    ) else (
        echo ��Чģ��ѡ�
        pause
        exit /b 1
    )
    
    echo ��ʼ��������...
    python main.py --action full --input_video input/input.mp4 --frame_dir output/frames --processed_dir output/processed --output_video output/final.mp4 --model %model% --fps 30
    echo.
    echo ������ɣ�������Ƶ��output/final.mp4
) else (
    echo �������ʧ�ܣ��޷�������Ŀ��
)

pause