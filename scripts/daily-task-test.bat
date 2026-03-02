@echo off
chcp 65001 >nul
echo [%date% %time%] 开始执行定时任务测试 >> C:\Users\远智教育\.openclaw\workspace\小远智\logs\task-test.log

PowerShell -ExecutionPolicy Bypass -Command "& { 
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path 'C:\Users\远智教育\.openclaw\workspace\小远智\logs\task-test.log' -Value "[$timestamp] PowerShell脚本启动"
    
    # 简单测试
    try {
        # 搜索测试
        $headers = @{
            'Authorization' = 'Bearer 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'
            'Content-Type' = 'application/json'
        }
        $body = '{"query": "test", "max_results": 1}'
        $response = Invoke-RestMethod -Uri 'https://api.tavily.com/search' -Method POST -Headers $headers -Body $body -TimeoutSec 30
        Add-Content -Path 'C:\Users\远智教育\.openclaw\workspace\小远智\logs\task-test.log' -Value "[$timestamp] 搜索成功，找到 $($response.results.Count) 条结果"
    } catch {
        Add-Content -Path 'C:\Users\远智教育\.openclaw\workspace\小远智\logs\task-test.log' -Value "[$timestamp] 错误: $_"
    }
}"

echo [%date% %time%] 执行完成 >> C:\Users\远智教育\.openclaw\workspace\小远智\logs\task-test.log
echo. >> C:\Users\远智教育\.openclaw\workspace\小远智\logs\task-test.log
