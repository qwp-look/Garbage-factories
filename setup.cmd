@echo off
echo ==============================================
echo          Garbage Factories ������װ
echo ==============================================

:: ���� pip
echo [1/2] ���� pip...
python -m pip install --upgrade pip -q

:: ��װ�������� requirement.txt ��ȡ��
echo [2/2] ��װ��Ŀ����...
if exist requirement.txt (
    python -m pip install -r requirement.txt -q
    if %errorLevel% equ 0 (
        echo [��] ����������װ��ɣ�
    ) else (
        echo [��] ������װʧ�ܣ���������� requirement.txt �ļ���
        pause
        exit /b 1
    )
) else (
    echo [��] requirement.txt �ļ������ڣ�
    pause
    exit /b 1
)

pause