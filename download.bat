@echo off
setlocal enabledelayedexpansion

:: 定义基础目录
set "BASE_DIR=%~dp0"
:: 检查并安装 Miniconda
echo Checking for Miniconda installation...
conda --version >nul 2>&1
if errorlevel 1 (
    echo Miniconda not found. Downloading and installing Miniconda...
    set "MINICONDA_INSTALLER_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
    set "MINICONDA_INSTALLER=miniconda_installer.exe"

    :: 确保变量正确设置
    echo Downloading Miniconda from: %MINICONDA_INSTALLER_URL%

    :: 使用 curl 下载 Miniconda 安装程序
    curl -L -o miniconda_installer.exe https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
    if errorlevel 1 (
        echo Failed to download Miniconda installer. Please check your internet connection.
        exit /b 1
    )

    :: 静默安装 Miniconda
    start /wait "" "%MINICONDA_INSTALLER%" /InstallationType=JustMe /AddToPath=1 /RegisterPython=0 /S /D=%USERPROFILE%\Miniconda3
    if errorlevel 1 (
        echo Failed to install Miniconda. Please install it manually.
        exit /b 1
    )

    echo Miniconda has been successfully installed.
) else (
    echo Miniconda is already installed.
)
pause
exit /b 0