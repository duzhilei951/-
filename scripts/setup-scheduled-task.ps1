# 设置每日AI模型监测定时任务
# 以管理员身份运行此脚本

$taskName = "小远智-AI模型每日监测"
$scriptPath = "C:\Users\远智教育\.openclaw\workspace\小远智\scripts\daily_ai_report.ps1"
$logPath = "C:\Users\远智教育\.openclaw\workspace\小远智\logs"

# 创建日志目录
if (!(Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
}

# 定义触发器（每天早上9点）
$trigger = New-ScheduledTaskTrigger -Daily -At "09:00"

# 定义操作
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`" *> `"$logPath\daily_report_$(Get-Date -Format 'yyyyMMdd').log`""

# 定义设置
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

# 注册任务（使用当前用户权限）
try {
    Register-ScheduledTask `
        -TaskName $taskName `
        -Trigger $trigger `
        -Action $action `
        -Settings $settings `
        -Description "每天自动搜索AI模型新动态，如有新模型或重大升级则生成报告并推送到GitHub" `
        -Force
    
    Write-Host "✅ 定时任务创建成功！" -ForegroundColor Green
    Write-Host "任务名称: $taskName" -ForegroundColor Cyan
    Write-Host "执行时间: 每天上午9:00" -ForegroundColor Cyan
    Write-Host "脚本路径: $scriptPath" -ForegroundColor Cyan
    Write-Host "日志路径: $logPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "管理命令:" -ForegroundColor Yellow
    Write-Host "  查看任务: Get-ScheduledTask -TaskName '$taskName'"
    Write-Host "  立即运行: Start-ScheduledTask -TaskName '$taskName'"
    Write-Host "  停止任务: Stop-ScheduledTask -TaskName '$taskName'"
    Write-Host "  删除任务: Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false"
} catch {
    Write-Error "创建定时任务失败: $_"
    Write-Host "请以管理员身份运行 PowerShell 后重试" -ForegroundColor Red
}
