# Hippocampus Skills

Skills for CC-Hippocampus memory management.

## 🚀 Quick Start

After installation, these skills are automatically available in Claude Code.

## 📚 Available Skills

### `/hippocampus-load`

Load external memory at session start.

**Usage**: Automatically triggered or run manually

```bash
/hippocampus-load
```

**What it does**:
- Reads `.hippocampus.json` from project root
- Formats memory for LLM context injection
- Displays active tasks, technical debt, and recently modified files

---

### `/hippocampus-save`

Save current memory state.

**Usage**: Automatically triggered or run manually

```bash
/hippocampus-save
```

**What it does**:
- Persists current project context to disk
- Updates timestamps and file maps
- Prepares for safe context compression

---

### `/hippocampus-clear`

Clear and archive current memory.

**Usage**: Run manually when needed

```bash
/hippocampus-clear
```

**What it does**:
- Archives current memory to `.hippocampus_history/`
- Resets to empty state
- Useful for starting fresh or creating recovery points

---

### `/hippocampus-stats`

View memory statistics.

**Usage**: Run manually to check memory status

```bash
/hippocampus-stats
```

**Output**:
```json
{
  "exists": true,
  "size_bytes": 887,
  "last_updated": "2026-02-12T16:26:04",
  "active_tasks": 2,
  "technical_debt": 1,
  "files_tracked": 2
}
```

---

## ⚙️ Automatic Behavior

### Session Start

The `post-session-start` hook automatically runs `/hippocampus-load` when you start a new session.

### Context Compression

When context usage exceeds 80%, the system will:
1. Automatically save memory using `/hippocampus-save`
2. Prompt you to run `/clear` to refresh the session

---

## 🎯 Use Cases

### Long Development Sessions

```text
Session 1: Work on feature A → Memory auto-saved
/clear
Session 2: Memory auto-loaded → Continue from feature A
```

### Multi-Day Projects

```text
Day 1: Build scraper → Save memory
Day 2: /hippocampus-load → Continue where you left off
```

### Error Recovery

```text
Memory corrupted? → /hippocampus-load (loads from archive)
Need fresh start? → /hippocampus-clear
```

---

## 🔧 Advanced Usage

### Manual Save with Custom Context

You can manually specify what to save:

```javascript
// In Claude Code console
await skills.hippocampus.save(JSON.stringify({
  project_context: "Building memory manager",
  active_tasks: [{description: "Test atomic writes"}],
  technical_debt: [],
  file_map: {}
}));
```

### Check Memory Health

```bash
/hippocampus-stats
```

Use this to verify:
- Memory file exists
- File size is reasonable
- Last update timestamp is recent

---

## 📖 Related Documentation

- [Main README](../README.md) - Full plugin documentation
- [Installation Guide](../README.md#-installation) - How to install
- [Examples](../EXAMPLES.md) - Real-world usage scenarios

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Skill not found | Restart Claude Code after installation |
| Memory not loading | Run `/hippocampus-load` manually |
| Save fails | Check file permissions in project directory |
| Hook not triggering | Verify `~/.claude/hooks/post-session-start.js` exists |

---

## 📝 Notes

- Skills are installed to `~/.claude/skills/hippocampus/`
- Hooks are installed to `~/.claude/hooks/`
- Memory is stored in your project root (`.hippocampus.json`)
- Archives are kept in `.hippocampus_history/`

---

**Built with ❤️ for developers who think in context.**
