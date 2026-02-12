# CC-Hippocampus 🧠

**External Memory Manager for Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.7+](https://img.shields.io/badge/Python-3.7+-green.svg)](https://www.python.org/downloads/)

---

<div align="center">

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

</div>

---

## 🎯 Target Users

This plugin is designed for **users who connect Claude Code to third-party LLMs**, solving context storage and compression issues.

---

## 🚀 Installation (30 seconds)

### Method 1: One-Line Installation (Recommended)

Copy and run the command below:

**Windows (PowerShell)**:
```powershell
irm https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.ps1 | iex
```

**macOS/Linux (Terminal)**:
```bash
curl -fsSL https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.sh | bash
```

**⚠️ Important Notes**:
- ✅ This installation **does NOT modify** your existing Claude Code settings
- ✅ Only adds CC-Hippocampus plugin, skills, and one hook file
- ✅ Your existing plugins and settings remain unchanged

### Method 2: Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/XuXinran1011/CC-Hippocampus.git
```

2. In Claude Code, run:
```bash
/plugin add .
```

---

## 📖 Usage

### Automatic Workflow (Recommended)

After installation, CC-Hippocampus works automatically:

1. **Session Start**: Memory is loaded automatically
2. **High Context**: At ~80% usage, memory is saved
3. **User Clears**: You're prompted to run `/clear`
4. **Session Resume**: Memory is restored automatically

### Manual Skills

After installation, you can use these skills:

```bash
/hippocampus-load    # Load memory manually
/hippocampus-save    # Save memory manually
/hippocampus-clear   # Clear and archive memory
/hippocampus-stats   # View memory statistics
```

---

## 🧠 Memory Schema

```json
{
  "last_updated": "2026-02-12T14:30:00",
  "project_context": "High-level summary of project goals",
  "active_tasks": [
    {
      "description": "Current task description",
      "added_at": "2026-02-12T14:00:00",
      "priority": "high"
    }
  ],
  "technical_debt": [
    {
      "description": "Pending refactor or bug",
      "priority": "medium",
      "added_at": "2026-02-12T13:00:00"
    }
  ],
  "file_map": {
    "src/file.py": {
      "last_modified": "2026-02-12T14:15:00",
      "summary": "What was changed"
    }
  }
}
```

---

## ⚠️ Important Notes

1. **NEVER use `/compact`**
   - This command irreversibly destroys memory
   - Always use the save-and-clear workflow

2. **Memory File Location**
   - `.hippocampus.json` is stored in your project root
   - Archives are kept in `.hippocampus_history/`

3. **Archive Cleanup**
   - Old states are kept indefinitely (manual cleanup recommended)

4. **Reset Memory**
   ```bash
   /hippocampus-clear  # Clear and archive
   ```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Memory not loading | Run `/hippocampus-load` manually |
| Save fails | Check file permissions in project directory |
| Corrupted JSON | Delete `.hippocampus.json` and start fresh |
| Archive folder too large | Delete old archives in `.hippocampus_history/` |

---

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

**Built with ❤️ for developers who think in context.** 💡
