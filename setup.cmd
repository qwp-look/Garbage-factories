@echo off
echo ==============================================
echo          Garbage Factories 依赖安装
echo ==============================================

:: 升级 pip
echo [1/2] 升级 pip...
python -m pip install --upgrade pip -q

:: 安装依赖（从 requirement.txt 读取）
echo [2/2] 安装项目依赖...
if exist requirement.txt (
    python -m pip install -r requirement.txt -q
    if %errorLevel% equ 0 (
        echo [√] 所有依赖安装完成！
    ) else (
        echo [×] 依赖安装失败，请检查网络或 requirement.txt 文件！
        pause
        exit /b 1
    )
) else (
    echo [×] requirement.txt 文件不存在！
    pause
    exit /b 1
)

pause