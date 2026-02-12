# CC-Hippocampus 🧠

**Claude Code 的外部記憶管理器**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.7+](https://img.shields.io/badge/Python-3.7+-green.svg)](https://www.python.org/downloads/)

---

<div align="center">

[English](README.md) | [繁體中文](README.zh-TW.md) | [繁體中文](README.zh-TW.md)

</div>

---

## 🎯 适用范围

本插件专为**将 Claude Code 接入第三方大模型**的用户设计，用于解决上下文存储与压缩异常问题。

---

## 🚀 安装（30 秒完成）

### 方法 1：一键安装（推荐）

复制下方命令直接运行：

**Windows (PowerShell)**:
```powershell
irm https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.ps1 | iex
```

**macOS/Linux (Terminal)**:
```bash
curl -fsSL https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.sh | bash
```

**⚠️ 重要说明**:
- ✅ 本安装**不会修改**您现有的 Claude Code 设置
- ✅ 仅添加 CC-Hippocampus 插件、技能和一个钩子文件
- ✅ 您现有的插件和设置保持不变

### 方法 2：手动安装

1. 克隆仓库：
```bash
git clone https://github.com/XuXinran1011/CC-Hippocampus.git
```

2. 在 Claude Code 中运行：
```bash
/plugin add .
```

---

## 📖 使用方法

### 自动工作流（推荐）

安装后，CC-Hippocampus 会自动工作：

1. **会话开始**：自动加载記憶
2. **上下文过高**：在 ~80% 时自动保存
3. **用户清除**：提示运行 `/clear`
4. **会话恢复**：自动恢复記憶

### 手动技能

安装后可以使用以下技能：

```bash
/hippocampus-load    # 手动加载記憶
/hippocampus-save    # 手动保存記憶
/hippocampus-clear   # 清除并歸檔記憶
/hippocampus-stats   # 查看記憶统计
```

---

## 🧠 記憶结构

```json
{
  "last_updated": "2026-02-12T14:30:00",
  "project_context": "項目目标的高级摘要",
  "active_tasks": [
    {
      "description": "当前任务描述",
      "added_at": "2026-02-12T14:00:00",
      "priority": "high"
    }
  ],
  "technical_debt": [
    {
      "description": "待处理的重构或 bug",
      "priority": "medium",
      "added_at": "2026-02-12T13:00:00"
    }
  ],
  "file_map": {
    "src/file.py": {
      "last_modified": "2026-02-12T14:15:00",
      "summary": "修改内容"
    }
  }
}
```

---

## ⚠️ 注意事项

1. **切勿使用 `/compact`**
   - 该命令会不可逆地销毁記憶
   - 始终使用保存-清除工作流

2. **記憶文件位置**
   - `.hippocampus.json` 存储在項目根目录
   - 歸檔历史保存在 `.hippocampus_history/`

3. **歸檔清理**
   - 旧状态会一直保留（建议手动清理）

4. **重置記憶**
   ```bash
   /hippocampus-clear  # 清除并歸檔
   ```

---

## 🐛 故障排除

| 问题 | 解决方案 |
|------|----------|
| 記憶未加载 | 手动运行 `/hippocampus-load` |
| 保存失败 | 检查項目目录中的文件权限 |
| JSON 损坏 | 删除 `.hippocampus.json` 并重新开始 |
| 歸檔文件夹太大 | 删除 `.hippocampus_history/` 中的旧歸檔 |

---

## 📜 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)。

---

**为在上下文中思考的开发者打造。** 💡
