# CC-Hippocampus 🧠

**Claude Code 的外部記憶管理器**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.7+](https://img.shields.io/badge/Python-3.7+-green.svg)](https://www.python.org/downloads/)
[![Cross-Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](#features)

---

## 🎯 概述

**適用範圍**：本插件專為將 Claude Code 接入第三方大模型的用戶設計。

**CC-Hippocampus** 是 Claude Code 的外部記憶持久化插件，可在長時間開發會話期間防止上下文丟失。通過在上下文壓縮之前將項目上下文、活躍任務和技術債務保存到磁盤，你永遠不會丟失思路。

### 主要特性

- ✅ **原子持久化**：記憶寫入是原子操作（寫入→臨時文件→重命名），防止損壞
- ✅ **零配置**：運行 `/plugin add .` 後立即可用
- ✅ **跨平台**：無需修改即可在 macOS、Linux 和 Windows 上運行
- ✅ **自動加載**：會話開始時自動加載記憶
- ✅ **安全壓縮**：用安全的保存-清除工作流替換危險的 `/compact` 命令
- ✅ **歸檔歷史**：保留之前的狀態以便恢復

## 🚀 安裝

1. 克隆或下載此倉庫
2. 在 Claude Code 中運行：
   ```bash
   /plugin add .
   ```
3. 完成！記憶管理現在是自動的。

## 📖 使用方法

### 自動工作流（推薦）

CC-Hippocampus **自動工作**：

1. **會話開始**：自動加載記憶
2. **上下文過高**：使用率達到 ~80% 時，保存記憶
3. **用戶清除**：提示運行 `/clear`
4. **會話恢復**：自動恢復記憶

### 手動命令

```bash
# 載入記憶（通常自動）
python tools/hippocampus.py load

# 使用自定義 JSON 保存記憶
python tools/hippocampus.py save '{
  "project_context": "構建記憶管理器",
  "active_tasks": [{"description": "測試原子寫入"}],
  "technical_debt": [],
  "file_map": {}
}'

# 清除並歸檔當前記憶
python tools/hippocampus.py clear

# 查看記憶統計
python tools/hippocampus.py stats

# 快速添加任務
python tools/hippocampus.py add-task "修復保存函數中的 bug" high
```

## 🧠 記憶結構

```json
{
  "last_updated": "2026-02-12T14:30:00",
  "project_context": "項目目標的高級摘要",
  "active_tasks": [
    {
      "description": "當前任務描述",
      "added_at": "2026-02-12T14:00:00",
      "priority": "high"
    }
  ],
  "technical_debt": [
    {
      "description": "待處理的重構或 bug",
      "priority": "medium",
      "added_at": "2026-02-12T13:00:00"
    }
  ],
  "file_map": {
    "src/file.py": {
      "last_modified": "2026-02-12T14:15:00",
      "summary": "修改內容"
    }
  }
}
```

## 🔧 架構

```
CC-Hippocampus/
├── tools/
│   └── hippocampus.py       # 核心記憶管理器
├── rules/
│   └── hippocampus_policy.md # 行為協議
├── .hippocampus.json         # 當前記憶（自動生成）
└── .hippocampus_history/     # 歸檔狀態
```

## ⚠️ 重要說明

- **切勿使用 `/compact`**：它會不可逆地銷毀記憶。始終使用保存-清除工作流。
- **記憶位置**：`.hippocampus.json` 存儲在項目根目錄
- **歸檔保留**：舊狀態保存在 `.hippocampus_history/`（建議手動清理）

## 🐛 故障排除

| 問題 | 解決方案 |
|------|----------|
| 記憶未加載 | 手動運行 `python tools/hippocampus.py load` |
| 保存失敗 | 檢查項目目錄中的文件權限 |
| JSON 損壞 | 刪除 `.hippocampus.json` 並重新開始 |
| 歸檔文件夾太大 | 刪除 `.hippocampus_history/` 中的舊歸檔 |

## 📜 許可證

MIT 許可證 - 詳見 [LICENSE](LICENSE)。

---

## 🤝 貢獻

歡迎貢獻！請隨時提交 Pull Request。

## 📧 聯繫方式

如有問題或疑問，請在 GitHub 上提交 issue。

---

**為在上下文中思考的開發者打造。**
