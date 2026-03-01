# 小远智 - 每日AI模型动态监测脚本（双同步版）
# 功能：搜索最新AI模型新闻，如有新模型或重大升级则生成报告并同步到GitHub和Obsidian

$ErrorActionPreference = "Stop"
$date = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$TavilyApiKey = "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"
$WorkspacePath = "C:\Users\远智教育\.openclaw\workspace\小远智"
$ObsidianVaultPath = "Y:\000 笔记资料\喜悦天地"
$ObsidianTargetFolder = "小远智"

Write-Host "[$timestamp] 开始执行每日AI模型监测..." -ForegroundColor Green

# ============================================
# 第一步：搜索最新AI模型新闻
# ============================================
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
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri 'https://api.tavily.com/search' -Method POST -Headers $headers -Body $body -TimeoutSec 60
    
    Write-Host "找到 $($response.results.Count) 条相关新闻" -ForegroundColor Green
} catch {
    Write-Error "搜索失败: $_"
    exit 1
}

# ============================================
# 第二步：分析是否有新模型或重大升级
# ============================================
$newModels = @()
$majorUpdates = @()

$keywordsNewModel = @("release", "launch", "new model", "announced", "introducing", "unveiled")
$keywordsUpdate = @("update", "upgrade", "version", "V2", "V3", "V4", "V5", "2.0", "3.0", "4.0", "5.0")
$modelNames = @("kimi", "qwen", "deepseek", "glm", "minimax", "doubao", "gpt", "claude", "gemini", "llama", "mistral")

foreach ($result in $response.results) {
    $titleLower = $result.title.ToLower()
    $contentLower = $result.content.ToLower()
    
    # 检查是否包含模型名称
    $hasModelName = $false
    foreach ($model in $modelNames) {
        if ($titleLower.Contains($model) -or $contentLower.Contains($model)) {
            $hasModelName = $true
            break
        }
    }
    
    if (!$hasModelName) { continue }
    
    # 检查新模型发布
    foreach ($keyword in $keywordsNewModel) {
        if ($titleLower.Contains($keyword) -or $contentLower.Contains($keyword)) {
            $newModels += $result
            break
        }
    }
    
    # 检查重大升级
    foreach ($keyword in $keywordsUpdate) {
        if ($titleLower.Contains($keyword) -or $contentLower.Contains($keyword)) {
            $majorUpdates += $result
            break
        }
    }
}

Write-Host "发现 $($newModels.Count) 条新模型相关新闻" -ForegroundColor Yellow
Write-Host "发现 $($majorUpdates.Count) 条升级相关新闻" -ForegroundColor Yellow

# ============================================
# 第三步：判断是否需要生成报告
# ============================================
if ($newModels.Count -eq 0 -and $majorUpdates.Count -eq 0) {
    Write-Host "[$timestamp] 今日无新模型或重大升级，跳过报告生成" -ForegroundColor Gray
    exit 0
}

Write-Host "检测到重要动态，开始生成报告..." -ForegroundColor Green

# ============================================
# 第四步：生成报告内容
# ============================================
$reportTitle = "AI模型每日动态_$date"
$reportFileName = "$reportTitle.md"
$reportPath = Join-Path $WorkspacePath $reportFileName

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
        $summary = $model.content
        if ($summary.Length -gt 300) {
            $summary = $summary.Substring(0, 300) + "..."
        }
        $reportContent += @"
### $index. $($model.title)

**来源：** [$($model.url)]($($model.url))  
**摘要：** $summary

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
        $summary = $update.content
        if ($summary.Length -gt 300) {
            $summary = $summary.Substring(0, 300) + "..."
        }
        $reportContent += @"
### $index. $($update.title)

**来源：** [$($update.url)]($($update.url))  
**摘要：** $summary

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
    try {
        $domain = ([System.Uri]$result.url).Host
        $reportContent += "| $index | $($result.title) | $domain |`n"
    } catch {
        $reportContent += "| $index | $($result.title) | - |`n"
    }
    $index++
}

$reportContent += @"

---

*本报告由「小远智的报告」技能自动生成，使用 Tavily API 进行多源新闻聚合。*
*仅在有新模型发布或重大升级时生成。*
"@

# 保存报告
$reportContent | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "✅ 报告已生成: $reportPath" -ForegroundColor Green

# ============================================
# 第五步：双同步（GitHub + Obsidian）
# ============================================
Write-Host "开始双同步..." -ForegroundColor Cyan

# 5.1 同步到 GitHub
try {
    Set-Location $WorkspacePath
    
    git config user.email "xiaoyuanzhi@auto.report" 2>$null
    git config user.name "小远智" 2>$null
    
    git add .
    $commitMsg = "每日AI模型动态监测 - $date（发现 $($newModels.Count) 新模型, $($majorUpdates.Count) 升级）"
    git commit -m $commitMsg 2>$null
    git push origin main
    
    Write-Host "✅ GitHub 同步成功" -ForegroundColor Green
} catch {
    Write-Warning "GitHub 同步警告: $_"
}

# 5.2 同步到 Obsidian
try {
    # 创建目标目录
    $obsidianFolder = Join-Path $ObsidianVaultPath $ObsidianTargetFolder
    if (!(Test-Path $obsidianFolder)) {
        New-Item -ItemType Directory -Path $obsidianFolder -Force | Out-Null
        Write-Host "创建Obsidian目录: $obsidianFolder" -ForegroundColor Yellow
    }
    
    # 复制报告文件
    $obsidianReportPath = Join-Path $obsidianFolder $reportFileName
    Copy-Item -Path $reportPath -Destination $obsidianReportPath -Force
    Write-Host "✅ 报告已复制到Obsidian" -ForegroundColor Green
    
    # 5.3 更新Obsidian索引
    $indexFilePath = Join-Path $obsidianFolder "README.md"
    $indexContent = ""
    
    if (Test-Path $indexFilePath) {
        $indexContent = Get-Content $indexFilePath -Raw -Encoding UTF8
    }
    
    # 创建基础结构
    if ([string]::IsNullOrWhiteSpace($indexContent)) {
        $indexContent = @"
# 小远智 - 报告索引

> 自动生成的报告集合，同步自GitHub仓库
> 最后更新：$timestamp

---

## 📊 每日监测

"@
    } else {
        $indexContent = $indexContent -replace "> 最后更新：.*", "> 最后更新：$timestamp"
    }
    
    # 创建新的索引条目
    $newEntry = "- [[$reportTitle|AI模型每日动态]] - $date`n"
    
    # 检查是否已存在
    if (!$indexContent.Contains("[[$reportTitle|")) {
        # 在每日监测类别下添加
        if ($indexContent -match "## 📊 每日监测") {
            $indexContent = $indexContent -replace "(## 📊 每日监测.*?)(\n## |$)", "`$1$newEntry`$2"
        } else {
            $indexContent += @"

## 📊 每日监测

$newEntry
"@
        }
        
        $indexContent | Out-File -FilePath $indexFilePath -Encoding UTF8
        Write-Host "✅ Obsidian索引已更新" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ 索引中已存在该报告" -ForegroundColor Gray
    }
    
} catch {
    Write-Error "Obsidian同步失败: $_"
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✅ 任务完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "📍 GitHub: https://github.com/duzhilei951/-" -ForegroundColor Cyan
Write-Host "📍 Obsidian: $ObsidianVaultPath\$ObsidianTargetFolder\" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Green
