@echo off
cls
echo ==============================================
echo          Garbage Factories ���̿���
echo ==============================================
echo ��ѡ�������
echo 1. ����֡��������Ƶ �� ͼƬ���У�
echo 2. �� AI ����ͼƬ���� �� �����ͼƬ��
echo 3. ���ϳ���Ƶ�������ͼƬ �� �����Ƶ��
echo 4. һ���������̣���֡��AI���ϳɣ�
echo 5. �˳�
echo ==============================================
set /p choice=������ѡ�1-5����

if "%choice%"=="1" (
    python main.py --action extract --input_video input/input.mp4 --frame_dir output/frames
    echo ��֡��ɣ�ͼƬ������ output/frames
) else if "%choice%"=="2" (
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
        call control.bat
        exit /b 1
    )
    
    python main.py --action ai_process --frame_dir output/frames --processed_dir output/processed --model %model%
    echo AI ������ɣ�ͼƬ������ output/processed
) else if "%choice%"=="3" (
    python main.py --action synthesize --processed_dir output/processed --output_video output/final.mp4 --fps 30
    echo ��Ƶ�ϳ���ɣ��ļ������� output/final.mp4
) else if "%choice%"=="4" (
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
        call control.bat
        exit /b 1
    )
    
    python main.py --action full --input_video input/input.mp4 --frame_dir output/frames --processed_dir output/processed --output_video output/final.mp4 --model %model% --fps 30
    echo ����������ɣ�������Ƶ������ output/final.mp4
) else if "%choice%"=="5" (
    echo �˳�����...
    exit /b 0
) else (
    echo ��Чѡ����������룡
    pause
    call control.bat
)

pause