# 小远智 - 每日AI模型动态监测脚本
# 功能：搜索最新AI模型新闻，如有新模型或重大升级则生成报告并推送到GitHub

param(
    [string]$TavilyApiKey = "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",
    [string]$RepoPath = "C:\Users\远智教育\.openclaw\workspace\小远智",
    [string]$GithubRepo = "duzhilei951/-"
)

$ErrorActionPreference = "Stop"
$date = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "[$timestamp] 开始执行每日AI模型监测..." -ForegroundColor Green

# 1. 搜索最新AI模型新闻
try {
    Write-Host "正在搜索今日AI模型动态..." -ForegroundColor Cyan
    
    $headers = @{
        'Authorization' = "Bearer $TavilyApiKey"
        'Content-Type' = 'application/json'
    }
    
    $body = @{
        query = "AI model new release update Kimi Qwen DeepSeek GLM MiniMax Doubao GPT Claude Gemini latest news"
        max_results = 15
        time_range = "day"
        search_depth = "advanced"
        include_raw_content = $true
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri 'https://api.tavily.com/search' -Method POST -Headers $headers -Body $body -TimeoutSec 60
    
    Write-Host "找到 $($response.results.Count) 条相关新闻" -ForegroundColor Green
} catch {
    Write-Error "搜索失败: $_"
    exit 1
}

# 2. 分析是否有新模型或重大升级
$newModels = @()
$majorUpdates = @()

$keywordsNewModel = @("release", "launch", "new model", "announced", "introducing", " unveiled")
$keywordsUpdate = @("update", "upgrade", "version", "V2", "V3", "V4", "V5", "2.0", "3.0", "4.0", "5.0")

foreach ($result in $response.results) {
    $titleLower = $result.title.ToLower()
    $contentLower = $result.content.ToLower()
    
    # 检查新模型发布
    foreach ($keyword in $keywordsNewModel) {
        if ($titleLower.Contains($keyword) -or $contentLower.Contains($keyword)) {
            if ($titleLower -match "(kimi|qwen|deepseek|glm|minimax|doubao|gpt|claude|gemini|llama|mistral)" -or 
                $contentLower -match "(kimi|qwen|deepseek|glm|minimax|doubao|gpt|claude|gemini|llama|mistral)") {
                $newModels += $result
                break
            }
        }
    }
    
    # 检查重大升级
    foreach ($keyword in $keywordsUpdate) {
        if ($titleLower.Contains($keyword) -or $contentLower.Contains($keyword)) {
            if ($titleLower -match "(kimi|qwen|deepseek|glm|minimax|doubao|gpt|claude|gemini)" -or 
                $contentLower -match "(kimi|qwen|deepseek|glm|minimax|doubao|gpt|claude|gemini)") {
                $majorUpdates += $result
                break
            }
        }
    }
}

Write-Host "发现 $($newModels.Count) 条新模型相关新闻" -ForegroundColor Yellow
Write-Host "发现 $($majorUpdates.Count) 条升级相关新闻" -ForegroundColor Yellow

# 3. 判断是否需要生成报告
if ($newModels.Count -eq 0 -and $majorUpdates.Count -eq 0) {
    Write-Host "[$timestamp] 今日无新模型或重大升级，跳过报告生成" -ForegroundColor Gray
    exit 0
}

Write-Host "检测到重要动态，开始生成报告..." -ForegroundColor Green

# 4. 生成报告内容
$reportContent = @"
# AI模型每日动态监测报告

**日期：** $date  
**监测时间：** $timestamp  
**整理：** 小远智（自动）

---

## 📊 今日概览

| 类型 | 数量 |
|------|------|
| 🆕 新模型发布 | $($newModels.Count) 条 |
| ⬆️ 重大升级 | $($majorUpdates.Count) 条 |

---

"@

# 添加新模型部分
if ($newModels.Count -gt 0) {
    $reportContent += @"
## 🆕 新模型发布

"@
    $index = 1
    foreach ($model in $newModels | Select-Object -First 5) {
        $reportContent += @"
### $index. $($model.title)

**来源：** [$($model.url)]($($model.url))  
**摘要：** $($model.content.Substring(0, [Math]::Min(300, $model.content.Length)))...

---

"@
        $index++
    }
}

# 添加升级部分
if ($majorUpdates.Count -gt 0) {
    $reportContent += @"
## ⬆️ 重大升级动态

"@
    $index = 1
    foreach ($update in $majorUpdates | Select-Object -First 5) {
        $reportContent += @"
### $index. $($update.title)

**来源：** [$($update.url)]($($update.url))  
**摘要：** $($update.content.Substring(0, [Math]::Min(300, $update.content.Length)))...

---

"@
        $index++
    }
}

# 添加原始数据附录
$reportContent += @"
## 📎 原始搜索结果

共检索到 $($response.results.Count) 条相关新闻：

| 序号 | 标题 | 来源 |
|------|------|------|
"@

$index = 1
foreach ($result in $response.results) {
    $domain = ([System.Uri]$result.url).Host
    $reportContent += "| $index | $($result.title) | $domain |`n"
    $index++
}

$reportContent += @"

---

*本报告由「小远智的报告」技能自动生成，使用 Tavily API 进行多源新闻聚合。*
*仅在有新模型发布或重大升级时生成。*
"@

# 5. 保存报告
$reportFileName = "AI模型每日动态_$date.md"
$reportPath = Join-Path $RepoPath $reportFileName

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "报告已保存: $reportPath" -ForegroundColor Green

# 6. 推送到GitHub
try {
    Set-Location $RepoPath
    
    # 配置git用户信息（如果未配置）
    git config user.email "xiaoyuanzhi@auto.report" 2>$null
    git config user.name "小远智" 2>$null
    
    # 添加、提交、推送
    git add .
    $commitMsg = "每日AI模型动态监测 - $date（发现 $($newModels.Count) 新模型, $($majorUpdates.Count) 升级）"
    git commit -m $commitMsg
    git push origin main
    
    Write-Host "[$timestamp] ✅ 成功推送到 GitHub: $GithubRepo" -ForegroundColor Green
} catch {
    Write-Error "GitHub推送失败: $_"
    exit 1
}

Write-Host "[$timestamp] 任务完成！" -ForegroundColor Green
