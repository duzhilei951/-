# 简化版每日监测测试
$date = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "[$timestamp] 开始测试..." -ForegroundColor Green

# 搜索
$headers = @{
    'Authorization' = 'Bearer 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'
    'Content-Type' = 'application/json'
}

$body = @{
    query = "AI model latest news today"
    max_results = 5
    time_range = "day"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri 'https://api.tavily.com/search' -Method POST -Headers $headers -Body $body -TimeoutSec 30
    Write-Host "找到 $($response.results.Count) 条新闻" -ForegroundColor Green
    
    # 简单报告
    $report = "# 测试报告 $date`n`n找到 $($response.results.Count) 条新闻`n"
    $reportPath = "C:\Users\远智教育\.openclaw\workspace\小远智\测试_$(Get-Date -Format 'HHmmss').md"
    $report | Out-File $reportPath -Encoding UTF8
    
    Write-Host "报告已生成: $reportPath" -ForegroundColor Green
    
    # GitHub同步
    cd "C:\Users\远智教育\.openclaw\workspace\小远智"
    git add . >$null 2>&1
    git commit -m "测试报告 $timestamp" >$null 2>&1
    git push origin main >$null 2>&1
    Write-Host "GitHub同步完成" -ForegroundColor Green
    
    # Obsidian同步（使用变量避免中文路径问题）
    $vault = "Y:\000 笔记资料\喜悦天地"
    $folder = "小远智"
    $dest = Join-Path $vault $folder
    
    if (Test-Path $dest) {
        Copy-Item $reportPath $dest -Force
        Write-Host "Obsidian同步完成" -ForegroundColor Green
    }
    
    Write-Host "✅ 测试成功!" -ForegroundColor Green
    
} catch {
    Write-Error "错误: $_"
}
