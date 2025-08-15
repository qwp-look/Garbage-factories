@echo off
echo ==============================================
echo          Garbage Factories �������
echo ==============================================

:: ��� Git
echo [1/4] ��� Git...
where git >nul 2>nul
if %errorLevel% equ 0 (
    echo [��] Git �Ѱ�װ:
    git --version | findstr "version"
) else (
    echo [��] Git δ��װ��δ��ӵ��������������Ȱ�װ Git��
    pause
    exit /b 1
)

:: ��� Python 3.10+
echo.
echo [2/4] ��� Python 3.10+...
where python >nul 2>nul
if %errorLevel% equ 0 (
    for /f "delims=" %%v in ('python --version 2^>^&1 ^| findstr /i "python 3.10"') do (
        set "py_ver=%%v"
    )
    if defined py_ver (
        echo [��] Python �汾����Ҫ��: %py_ver%
    ) else (
        echo [��] Python �汾�� 3.10+����ǰ�汾:
        python --version
        pause
        exit /b 1
    )
) else (
    echo [��] Python δ��װ��δ��ӵ��������������Ȱ�װ Python 3.10��
    pause
    exit /b 1
)

:: ��� FFmpeg
echo.
echo [3/4] ��� FFmpeg...
where ffmpeg >nul 2>nul
if %errorLevel% equ 0 (
    echo [��] FFmpeg �Ѱ�װ:
    ffmpeg -version | findstr "ffmpeg version"
) else (
    echo [��] FFmpeg δ��װ��δ��ӵ��������������Ȱ�װ FFmpeg��
    pause
    exit /b 1
)

:: ��������⣨���Ŀ�ʾ����
echo.
echo [4/4] ������ Python ����...
python -c "import cv2, torch, numpy, pillow, json" >nul 2>nul
if %errorLevel% equ 0 (
    echo [��] ���������Ѱ�װ
) else (
    echo [��] ���ֻ�������ȱʧ�������� setup.cmd ��װ��
    pause
    exit /b 1
)

echo.
echo ==============================================
echo          �������ͨ����������������Ŀ��
echo ==============================================
pause