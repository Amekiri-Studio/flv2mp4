@echo off
:: Enable UTF-8 for CMD and batch processing
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ============================= 参数处理 =============================
:: 参数：目标目录 (默认：当前目录)
set "target_dir=%~1"
if "%target_dir%"=="" set "target_dir=%~dp0"

:: 验证目标目录存在
if not exist "%target_dir%" (
    echo 错误：目录不存在 - "%target_dir%"
    pause
    exit /b 1
)

:: ============================= 日志设置 =============================
set "logdir=%target_dir%\FLV_Cleanup_Logs"
if not exist "%logdir%" mkdir "%logdir%"

set "logfile=%logdir%\FLV_Cleanup_%date:/=-%_%time::=-%.txt"
echo FLV清理日志 > "%logfile%"
echo 目标目录: "%target_dir%" >> "%logfile%"
echo 开始时间: %date% %time% >> "%logfile%"
echo. >> "%logfile%"

:: ============================= 文件清理 =============================
set total_flv=0
set deleted=0
set skipped=0

echo 正在扫描目录: "%target_dir%"
echo 正在扫描目录: "%target_dir%" >> "%logfile%"

for /r "%target_dir%" %%i in (*.flv) do (
    set /a total_flv+=1
    set "flv_file=%%i"
    set "flv_name=%%~ni"
    set "flv_path=%%~dpi"
    
    echo 检查FLV文件: "!flv_file!" >> "%logfile%"
    
    :: 检查同名MP4或MKV是否存在
    set delete_flag=0
    if exist "!flv_path!!flv_name!.mp4" (
        echo  找到同名MP4文件 >> "%logfile%"
        set delete_flag=1
    )
    if exist "!flv_path!!flv_name!.mkv" (
        echo  找到同名MKV文件 >> "%logfile%"
        set delete_flag=1
    )
    
    if !delete_flag! equ 1 (
        echo 删除FLV文件: "!flv_file!" >> "%logfile%"
        del /f /q "!flv_file!"
        if exist "!flv_file!" (
            echo  [错误] 删除失败 >> "%logfile%"
        ) else (
            echo  [成功] 已删除 >> "%logfile%"
            set /a deleted+=1
        )
    ) else (
        echo 未找到同名MP4/MKV，跳过 >> "%logfile%"
        set /a skipped+=1
    )
    echo. >> "%logfile%"
)

:: ============================= 统计报告 =============================
echo. >> "%logfile%"
echo ===================== 清理统计 ===================== >> "%logfile%"
echo 目标目录: "%target_dir%" >> "%logfile%"
echo 扫描FLV文件数: %total_flv% >> "%logfile%"
echo 已删除FLV文件: %deleted% >> "%logfile%"
echo 跳过FLV文件: %skipped% >> "%logfile%"
echo 开始时间: %date% %time% >> "%logfile%"
echo 结束时间: %date% %time% >> "%logfile%"

cls
echo.
echo ===== FLV文件清理完成 =====
echo 目标目录: "%target_dir%"
echo 扫描FLV文件数: %total_flv%
echo 已删除FLV文件: %deleted%
echo 跳过FLV文件: %skipped%
echo.
echo 日志文件: "%logfile%"
echo.
pause
