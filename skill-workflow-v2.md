---
name: xiaoyuanzhi-reporter
description: 小远智的报告标准化工作流。提供信息收集→报告生成→双同步（GitHub+Obsidian）的完整流程框架。支持通过Tavily API搜索信息、自动生成Markdown报告、并同步到云端仓库和本地Obsidian知识库，自动维护索引文件。适用于各类研究报告、新闻汇总、资料整理的自动化产出。
---

# 小远智的报告 - 标准化工作流

**核心定位**：提供标准化的报告生产流程框架

```
信息收集 → 报告生成 → 双同步（GitHub + Obsidian）→ 索引更新
```

## 标准工作流程

### Phase 1: 信息收集
- **工具**: Tavily API
- **输入**: 搜索关键词
- **输出**: 结构化搜索结果

### Phase 2: 报告生成
- **格式**: Markdown
- **模板**: 标准化报告结构
- **输出**: `[任务名]_YYYY-MM-DD.md`

### Phase 3: 双同步
| 目标 | 路径 | 操作 |
|------|------|------|
| **GitHub** | `github.com/duzhilei951/-` | git add → commit → push |
| **Obsidian** | `Y:\000 笔记资料\喜悦天地\小远智\` | 文件复制 + 索引更新 |

### Phase 4: 索引维护
- **文件**: `README.md`
- **功能**: 自动列出所有报告，支持 `[[双向链接]]`
- **更新**: 每次同步自动刷新

---

## 使用方式

### 方式一：完整工作流（推荐）

一键完成：搜索 → 生成 → 同步

```powershell
.\workflow-standard.ps1 `
    -TaskName "AI模型监测" `
    -Query "AI model latest news" `
    -ReportTitle "AI模型每日动态"
```

### 方式二：仅同步

已有报告，只需同步到两个目标：

```powershell
.\sync-only.ps1 `
    -ReportFile "C:\path\to\report.md" `
    -ReportTitle "报告标题"
```

### 方式三：自定义脚本调用

在其他脚本中引用标准流程：

```powershell
# 1. 信息收集
$results = Search-Tavily -Query "关键词"

# 2. 生成报告
$reportPath = Generate-Report -Data $results -Title "标题"

# 3. 双同步
Sync-To-GitHub -File $reportPath
Sync-To-Obsidian -File $reportPath -UpdateIndex $true
```

---

## 脚本工具集

| 脚本 | 用途 | 场景 |
|------|------|------|
| `workflow-standard.ps1` | 完整工作流 | 从搜索到同步一站式完成 |
| `sync-only.ps1` | 纯同步 | 已有报告，只需同步 |
| `daily_ai_report.ps1` | AI模型定时监测 | 特定领域的自动化监测 |

---

## 配置参数

### 默认配置

```powershell
$WorkspacePath = "C:\Users\远智教育\.openclaw\workspace\小远智"
$ObsidianVaultPath = "Y:\000 笔记资料\喜悦天地"
$ObsidianFolder = "小远智"
$TavilyApiKey = "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"
```

### 自定义配置

所有脚本都支持通过参数覆盖默认配置：

```powershell
.\workflow-standard.ps1 `
    -TaskName "自定义任务" `
    -Query "搜索词" `
    -WorkspacePath "D:\MyReports" `
    -ObsidianVaultPath "D:\ObsidianVault" `
    -ObsidianFolder "我的报告"
```

---

## 报告模板结构

生成的报告包含以下标准章节：

```markdown
# 报告标题

**日期：** YYYY-MM-DD  
**任务：** 任务名称  
**来源：** Tavily 多源聚合  
**整理：** 小远智

---

## 📊 检索概览

## 📋 详细内容

### 1. [标题]
[摘要]

### 2. [标题]
[摘要]

## 📎 原始数据

| 序号 | 来源 | 标题 |
|------|------|------|
...

---

*本报告由「小远智的报告」技能自动生成*
```

---

## Obsidian 索引格式

自动维护的 `README.md`：

```markdown
# 小远智 - 报告索引

> 自动生成的报告集合  
> 最后更新：2026-03-01 12:00:00

---

## 报告列表

- [[报告文件名|报告标题]] - 2026-03-01
- [[报告文件名|报告标题]] - 2026-03-01
...

---

*本索引由「小远智的报告」技能自动维护*
```

---

## 扩展使用

### 集成到其他脚本

```powershell
# 导入工作流函数
. "C:\Users\远智教育\.openclaw\skills\xiaoyuanzhi-reporter\scripts\workflow-standard.ps1"

# 在自定义逻辑中调用
function My-CustomTask {
    # 自定义信息收集
    $data = Custom-DataCollection
    
    # 使用标准报告生成
    $report = Generate-StandardReport -Data $data
    
    # 使用标准双同步
    Invoke-DualSync -Report $report
}
```

### 批量处理

```powershell
$tasks = @(
    @{ Name = "任务1"; Query = "关键词1" },
    @{ Name = "任务2"; Query = "关键词2" },
    @{ Name = "任务3"; Query = "关键词3" }
)

foreach ($task in $tasks) {
    .\workflow-standard.ps1 `
        -TaskName $task.Name `
        -Query $task.Query
}
```

---

## 注意事项

1. **编码**: 所有文件使用 UTF-8 编码，确保中文正常显示
2. **网络**: GitHub推送和Tavily搜索需要网络连接
3. **权限**: 确保对Obsidian Vault目录有写入权限
4. **索引**: 索引文件会自动创建和维护，无需手动干预

---

*标准化工作流框架，让报告生产一致、高效、可追溯。*
