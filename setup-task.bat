@echo off
chcp 65001 >nul
echo ==========================================
echo 小远智 - AI模型每日监测定时任务配置
echo ==========================================
echo.
echo 请以管理员身份运行此脚本！
echo.
pause

echo 正在创建定时任务...

PowerShell -ExecutionPolicy Bypass -Command "& { 
    $taskName = '小远智-AI模型每日监测'
    $scriptPath = 'C:\Users\远智教育\.openclaw\workspace\小远智\scripts\daily_ai_report.ps1'
    $logPath = 'C:\Users\远智教育\.openclaw\workspace\小远智\logs'
    
    # 创建日志目录
    if (!(Test-Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    }
    
    # 定义触发器（每天早上9点）
    $trigger = New-ScheduledTaskTrigger -Daily -At '09:00'
    
    # 定义操作
    $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' `
        -Argument \"-ExecutionPolicy Bypass -File `$scriptPath *>> `$logPath\daily_report_`$(Get-Date -Format 'yyyyMMdd').log\"
    
    # 定义设置
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable
    
    # 注册任务
    try {
        Register-ScheduledTask `
            -TaskName $taskName `
            -Trigger $trigger `
            -Action $action `
            -Settings $settings `
            -Description '每天自动搜索AI模型新动态，如有新模型或重大升级则生成报告并推送到GitHub' `
            -Force
        
        Write-Host '✅ 定时任务创建成功！' -ForegroundColor Green
        Write-Host ''
        Write-Host '任务详情：' -ForegroundColor Cyan
        Write-Host "  名称: $taskName"
        Write-Host '  执行时间: 每天上午9:00'
        Write-Host "  脚本路径: $scriptPath"
        Write-Host "  日志路径: $logPath"
    } catch {
        Write-Error \"创建失败: `$_\"
    }
}"

echo.
echo ==========================================
echo 配置完成！
echo ==========================================
echo.
echo 管理命令：
echo   查看任务: schtasks /query /tn "小远智-AI模型每日监测"
echo   立即运行: schtasks /run /tn "小远智-AI模型每日监测"
echo   删除任务: schtasks /delete /tn "小远智-AI模型每日监测" /f
echo.
pause
