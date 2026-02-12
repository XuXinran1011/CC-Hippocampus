# CC-Hippocampus 🧠

**Claude Code 的外部记忆管理器**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.7+](https://img.shields.io/badge/Python-3.7+-green.svg)](https://www.python.org/downloads/)
[![Cross-Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](#features)

---

## 🎯 概述

**适用范围**：本插件专为将 Claude Code 接入第三方大模型的用户设计。

**CC-Hippocampus** 是 Claude Code 的外部记忆持久化插件，可在长时间开发会话期间防止上下文丢失。通过在上下文压缩之前将项目上下文、活跃任务和技术债务保存到磁盘，你永远不会丢失思路。

### 主要特性

- ✅ **原子持久化**：记忆写入是原子操作（写入→临时文件→重命名），防止损坏
- ✅ **零配置**：运行 `/plugin add .` 后立即可用
- ✅ **跨平台**：无需修改即可在 macOS、Linux 和 Windows 上运行
- ✅ **自动加载**：会话开始时自动加载记忆
- ✅ **安全压缩**：用安全的保存-清除工作流替换危险的 `/compact` 命令
- ✅ **归档历史**：保留之前的状态以便恢复

## 🚀 安装

1. 克隆或下载此仓库
2. 在 Claude Code 中运行：
   ```bash
   /plugin add .
   ```
3. 完成！记忆管理现在是自动的。

## 📖 使用方法

### 自动工作流（推荐）

CC-Hippocampus **自动工作**：

1. **会话开始**：自动加载记忆
2. **上下文过高**：使用率达到 ~80% 时，保存记忆
3. **用户清除**：提示运行 `/clear`
4. **会话恢复**：自动恢复记忆

### 手动命令

```bash
# 加载记忆（通常自动）
python tools/hippocampus.py load

# 使用自定义 JSON 保存记忆
python tools/hippocampus.py save '{
  "project_context": "构建记忆管理器",
  "active_tasks": [{"description": "测试原子写入"}],
  "technical_debt": [],
  "file_map": {}
}'

# 清除并归档当前记忆
python tools/hippocampus.py clear

# 查看记忆统计
python tools/hippocampus.py stats

# 快速添加任务
python tools/hippocampus.py add-task "修复保存函数中的 bug" high
```

## 🧠 记忆结构

```json
{
  "last_updated": "2026-02-12T14:30:00",
  "project_context": "项目目标的高级摘要",
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

## 🔧 架构

```
CC-Hippocampus/
├── tools/
│   └── hippocampus.py       # 核心记忆管理器
├── rules/
│   └── hippocampus_policy.md # 行为协议
├── .hippocampus.json         # 当前记忆（自动生成）
└── .hippocampus_history/     # 归档状态
```

## ⚠️ 重要说明

- **切勿使用 `/compact`**：它会不可逆地销毁记忆。始终使用保存-清除工作流。
- **记忆位置**：`.hippocampus.json` 存储在项目根目录
- **归档保留**：旧状态保存在 `.hippocampus_history/`（建议手动清理）

## 🐛 故障排除

| 问题 | 解决方案 |
|------|----------|
| 记忆未加载 | 手动运行 `python tools/hippocampus.py load` |
| 保存失败 | 检查项目目录中的文件权限 |
| JSON 损坏 | 删除 `.hippocampus.json` 并重新开始 |
| 归档文件夹太大 | 删除 `.hippocampus_history/` 中的旧归档 |

## 📜 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)。

---

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

## 📧 联系方式

如有问题或疑问，请在 GitHub 上提交 issue。

---

**为在上下文中思考的开发者打造。**
