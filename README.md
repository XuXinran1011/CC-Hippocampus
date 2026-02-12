# CC-Hippocampus 🧠

**External Memory Manager for Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.7+](https://img.shields.io/badge/Python-3.7+-green.svg)](https://www.python.org/downloads/)
[![Cross-Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](#features)

---

## 🎯 Overview

**Target Users**: This plugin is designed for users who connect Claude Code to third-party LLMs.

**CC-Hippocampus** is an external memory persistence plugin for Claude Code that prevents context loss during long development sessions. By saving your project context, active tasks, and technical debt to disk before context compression, you never lose your train of thought.

### Key Features

- ✅ **Atomic Persistence**: Memory writes are atomic (write → temp → rename) to prevent corruption
- ✅ **Zero-Config**: Works immediately after `/plugin add .`
- ✅ **Cross-Platform**: Runs on macOS, Linux, and Windows without modification
- ✅ **Auto-Load**: Automatically loads memory at session start
- ✅ **Safe Compression**: Replaces dangerous `/compact` with safe save-and-clear workflow
- ✅ **Archive History**: Previous states are archived for recovery

## 🚀 Installation

1. Clone or download this repository
2. In Claude Code, run:
   ```bash
   /plugin add .
   ```
3. Done! Memory management is now automatic.

## 📖 Usage

### Automatic Workflow (Recommended)

CC-Hippocampus works **automatically**:

1. **Session Start**: Memory is loaded automatically
2. **High Context**: At ~80% usage, memory is saved
3. **User Clears**: You're prompted to run `/clear`
4. **Session Resume**: Memory is restored automatically

### Manual Commands

```bash
# Load memory (usually automatic)
python tools/hippocampus.py load

# Save memory with custom JSON
python tools/hippocampus.py save '{
  "project_context": "Building memory manager",
  "active_tasks": [{"description": "Test atomic writes"}],
  "technical_debt": [],
  "file_map": {}
}'

# Clear and archive current memory
python tools/hippocampus.py clear

# View memory statistics
python tools/hippocampus.py stats

# Add a task quickly
python tools/hippocampus.py add-task "Fix bug in save function" high
```

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

## 🔧 Architecture

```
CC-Hippocampus/
├── tools/
│   └── hippocampus.py       # Core memory manager
├── rules/
│   └── hippocampus_policy.md # Behavioral protocol
├── .hippocampus.json         # Current memory (auto-generated)
└── .hippocampus_history/     # Archived states
```

## ⚠️ Important Notes

- **NEVER use `/compact`**: It destroys memory irreversibly. Always use the save-and-clear workflow.
- **Memory location**: `.hippocampus.json` is stored in your project root
- **Archive retention**: Old states are kept in `.hippocampus_history/` indefinitely (manual cleanup recommended)

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Memory not loading | Run `python tools/hippocampus.py load` manually |
| Save fails | Check file permissions in project directory |
| Corrupted JSON | Delete `.hippocampus.json` and start fresh |
| Archive folder too large | Delete old archives in `.hippocampus_history/` |

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For issues or questions, please open an issue on GitHub.

---

**Built with ❤️ for developers who think in context.**
