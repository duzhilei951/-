@echo off
chcp 65001 >nul
echo ==========================================
echo 小远智 - AI模型每日监测
echo 开始时间: %date% %time%
echo ==========================================

set WORKSPACE=C:\Users\远智教育\.openclaw\workspace\小远智
set LOGFILE=%WORKSPACE%\logs\daily_%date:~0,4%%date:~5,2%%date:~8,2%.log

echo [%date% %time%] 开始执行 >> "%LOGFILE%"

REM 使用PowerShell执行搜索和报告生成
PowerShell -ExecutionPolicy Bypass -Command "& {
    $ErrorActionPreference = 'Stop'
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $date = Get-Date -Format 'yyyy-MM-dd'
    
    Write-Host \"[$timestamp] 开始搜索AI模型新闻...\" -ForegroundColor Green
    
    try {
        # 搜索
        $headers = @{
            'Authorization' = 'Bearer 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'
            'Content-Type' = 'application/json'
        }
        $body = '{\"query\": \"AI model new release update Kimi Qwen DeepSeek latest\", \"max_results\": 10, \"time_range\": \"day\"}'
        $response = Invoke-RestMethod -Uri 'https://api.tavily.com/search' -Method POST -Headers $headers -Body $body -TimeoutSec 60
        
        Write-Host \"找到 $($response.results.Count) 条新闻\" -ForegroundColor Green
        Add-Content -Path '%LOGFILE%' -Value \"[$timestamp] 找到 $($response.results.Count) 条新闻\"
        
        # 检查是否有新模型或重大升级
        $hasNewModel = $false
        foreach ($result in $response.results) {
            $title = $result.title.ToLower()
            if ($title -match 'release|launch|new model|update|upgrade') {
                $hasNewModel = $true
                break
            }
        }
        
        if (!$hasNewModel) {
            Write-Host \"今日无新模型或重大升级，跳过报告生成\" -ForegroundColor Yellow
            Add-Content -Path '%LOGFILE%' -Value \"[$timestamp] 无重要动态，跳过\"
            exit 0
        }
        
        # 生成简单报告
        $reportFile = \"AI模型每日动态_$date.md\"
        $reportPath = Join-Path '%WORKSPACE%' $reportFile
        
        $content = \"# AI模型每日动态`n`n**日期：** $date`n**时间：** $timestamp`n**来源：** Tavily搜索`n`n---`n`n## 今日要闻`n`n\"
        
        $index = 1
        foreach ($result in $response.results) {
            $content += \"### $index. $($result.title)`n`n$($result.content.Substring(0, [Math]::Min(300, $result.content.Length)))...`n`n[链接]($($result.url))`n`n---`n`n\"
            $index++
        }
        
        $content += \"*自动生成*\"
        
        [System.IO.File]::WriteAllText($reportPath, $content, [System.Text.UTF8Encoding]::new($false))
        Write-Host \"报告已生成: $reportFile\" -ForegroundColor Green
        Add-Content -Path '%LOGFILE%' -Value \"[$timestamp] 报告已生成: $reportFile\"
        
        # GitHub同步
        Set-Location '%WORKSPACE%'
        git config user.email \"xiaoyuanzhi@auto.report\" 2>$null
        git config user.name \"小远智\" 2>$null
        git add . >$null 2>&1
        git commit -m \"每日监测 $date\" >$null 2>&1
        git push origin main >$null 2>&1
        Write-Host \"GitHub同步完成\" -ForegroundColor Green
        Add-Content -Path '%LOGFILE%' -Value \"[$timestamp] GitHub同步完成\"
        
        # Obsidian同步
        $obsidianPath = \"Y:\\000 笔记资料\\喜悦天地\\小远智\\01-AI模型与监测\"
        if (Test-Path $obsidianPath) {
            Copy-Item $reportPath $obsidianPath -Force
            Write-Host \"Obsidian同步完成\" -ForegroundColor Green
            Add-Content -Path '%LOGFILE%' -Value \"[$timestamp] Obsidian同步完成\"
        }
        
        Write-Host \"✅ 任务完成!\" -ForegroundColor Green
        Add-Content -Path '%LOGFILE%' -Value \"[$timestamp] 任务完成\"
        
    } catch {
        Write-Error \"错误: $_\"
        Add-Content -Path '%LOGFILE%' -Value \"[$timestamp] 错误: $_\"
    }
}"

echo [%date% %time%] 执行结束 >> "%LOGFILE%"
echo ==========================================
echo 执行完成，查看日志: %LOGFILE%
echo ==========================================
