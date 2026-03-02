# 每日AI模型监测 - 简化版
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$date = Get-Date -Format 'yyyy-MM-dd'
$workspace = 'C:\Users\远智教育\.openclaw\workspace\小远智'
$logFile = "$workspace\logs\daily_$date.log"

# 确保日志目录存在
if (!(Test-Path "$workspace\logs")) {
    New-Item -ItemType Directory -Path "$workspace\logs" -Force | Out-Null
}

Add-Content -Path $logFile -Value "[$timestamp] 开始执行"

try {
    # 搜索
    $headers = @{
        'Authorization' = 'Bearer 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'
        'Content-Type' = 'application/json'
    }
    $body = '{"query": "AI model latest news", "max_results": 5, "time_range": "day"}'
    
    Add-Content -Path $logFile -Value "[$timestamp] 正在搜索..."
    $response = Invoke-RestMethod -Uri 'https://api.tavily.com/search' -Method POST -Headers $headers -Body $body -TimeoutSec 60
    Add-Content -Path $logFile -Value "[$timestamp] 找到 $($response.results.Count) 条结果"
    
    # 生成报告
    $reportFile = "AI动态_$date.md"
    $reportPath = Join-Path $workspace $reportFile
    
    $content = @"
# AI动态 $date

**时间:** $timestamp

## 新闻

"@
    
    $index = 1
    foreach ($result in $response.results) {
        $content += "$index. $($result.title)`n"
        $index++
    }
    
    [System.IO.File]::WriteAllText($reportPath, $content, [System.Text.UTF8Encoding]::new($false))
    Add-Content -Path $logFile -Value "[$timestamp] 报告已生成: $reportFile"
    
    # GitHub同步
    Set-Location $workspace
    git add . 2>$null
    git commit -m "Daily update $date" 2>$null
    git push origin main 2>$null
    Add-Content -Path $logFile -Value "[$timestamp] GitHub同步完成"
    
    # Obsidian同步
    $obsidianPath = 'Y:\000 笔记资料\喜悦天地\小远智\01-AI模型与监测'
    if (Test-Path $obsidianPath) {
        Copy-Item $reportPath $obsidianPath -Force
        Add-Content -Path $logFile -Value "[$timestamp] Obsidian同步完成"
    }
    
    Add-Content -Path $logFile -Value "[$timestamp] 任务完成"
    
} catch {
    Add-Content -Path $logFile -Value "[$timestamp] 错误: $_"
}
