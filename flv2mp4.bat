@echo off
:: Enable UTF-8 for CMD and batch processing
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ============== 参数处理 ==============
:: 参数1：目标目录 (默认：脚本所在目录)
set "target_dir=%~1"
if "%target_dir%"=="" set "target_dir=%~dp0"

:: 参数2：输出格式 (mp4/mkv)
set "output_ext=%~2"

:: 验证目标目录存在
if not exist "%target_dir%" (
    echo 错误：目录不存在 - "%target_dir%"
    pause
    exit /b 1
)

:: ============== FFmpeg 设置 ==============
set "ffmpeg=ffmpeg.exe"
where %ffmpeg% >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：未找到FFmpeg，请安装或设置正确路径
    pause
    exit /b 1
)

:: ============== 输出格式选择 ==============
if "%output_ext%"=="" (
    choice /C:12 /M "选择输出格式：1=MP4, 2=MKV"
    set "output_ext=mp4"
    if %errorlevel% equ 2 set "output_ext=mkv"
) else (
    :: 验证参数格式
    set "output_ext=%output_ext: =%"
    if /i not "%output_ext%"=="mp4" if /i not "%output_ext%"=="mkv" (
        echo 错误：无效的输出格式 "%output_ext%"，必须是 mp4 或 mkv
        pause
        exit /b 1
    )
)

:: ============== 日志设置 ==============
set "logfile=%target_dir%\Video_Conversion_Log_%date:/=-%_%time::=-%.txt"
echo 视频转换日志 > "%logfile%"
echo 目标目录: "%target_dir%" >> "%logfile%"
echo 输出格式: %output_ext% >> "%logfile%"
echo 开始时间: %date% %time% >> "%logfile%"
echo. >> "%logfile%"

:: ============== 文件处理 ==============
set total=0
set success=0
set transcoded=0

echo 正在扫描目录: "%target_dir%"
for /r "%target_dir%" %%i in (*.flv) do (
    set /a total+=1
    set "input=%%i"
    set "output=%%~dpni.!output_ext!"
    
    echo 正在处理: "!input!"
    echo 处理文件: "!input!" >> "%logfile%"
    
    :: 第一步：尝试无损封装转换
    echo [步骤1] 尝试无损复制流... >> "%logfile%"
    %ffmpeg% -i "!input!" -c:v copy -c:a copy -map_metadata 0 -movflags +faststart -y "!output!" 2>> "%logfile%"
    
    :: 检查是否成功
    if !errorlevel! equ 0 (
        echo [成功] 无损转换完成: "!output!"
        echo [成功] 无损转换完成 >> "%logfile%"
        set /a success+=1
    ) else (
        :: 第二步：如果失败则进行转码
        echo [警告] 无损转换失败，尝试转码... >> "%logfile%"
        del "!output!" 2>nul
        
        :: 智能转码设置
        set "vcodec=libx264"
        set "acodec=aac"
        set "vparams=-preset medium -crf 23"
        set "aparams=-b:a 192k"
        
        echo [步骤2] 转码为H.264/AAC... >> "%logfile%"
        %ffmpeg% -i "!input!" -c:v !vcodec! !vparams! -c:a !acodec! !aparams! -map_metadata 0 -movflags +faststart -y "!output!" 2>> "%logfile%"
        
        if !errorlevel! equ 0 (
            echo [成功] 转码完成: "!output!"
            echo [成功] 转码完成 >> "%logfile%"
            set /a success+=1
            set /a transcoded+=1
        ) else (
            echo [失败] 转换出错: "!input!" >> "%logfile%"
            del "!output!" 2>nul
        )
    )
    echo. >> "%logfile%"
    echo -------------------------------------------------- >> "%logfile%"
    echo. >> "%logfile%"
)

:: ============== 统计报告 ==============
echo. >> "%logfile%"
echo ============= 转换统计 ============= >> "%logfile%"
echo 目标目录: "%target_dir%" >> "%logfile%"
echo 输出格式: %output_ext% >> "%logfile%"
echo 总处理文件数: !total! >> "%logfile%"
echo 成功转换文件: !success! >> "%logfile%"
echo 其中无损封装: !success! - !transcoded! >> "%logfile%"
echo 需要转码文件: !transcoded! >> "%logfile%"
echo 失败文件数: !total! - !success! >> "%logfile%"
echo 开始时间: %date% %time% >> "%logfile%"
echo 结束时间: %date% %time% >> "%logfile%"

cls
echo.
echo ===== 视频转换完成 =====
echo 目标目录: "%target_dir%"
echo 输出格式: %output_ext%
echo 总文件数:   !total!
echo 成功转换:   !success!
echo 无损封装:   !success! - !transcoded!
echo 需要转码:   !transcoded!
echo 失败文件:   !total! - !success!
echo.
echo 详细日志见: "%logfile%"
echo.
pause
