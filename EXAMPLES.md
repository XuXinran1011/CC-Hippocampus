# CC-Hippocampus - Usage Examples

This document shows practical examples of how CC-Hippocampus works in real Claude Code sessions.

---

## Example 1: Long Development Session

### Session Start (Automatic Load)

```text
User: Let's continue working on the memory manager.

Claude: python tools/hippocampus.py load

=== CC-HIPPOCAMPUS MEMORY ===
Last Updated: 2026-02-12T14:30:00

PROJECT CONTEXT: Building external memory manager for Claude Code

ACTIVE TASKS (2):
  [1] Implement atomic writes (Added: 2026-02-12T14:00:00)
  [2] Add Windows compatibility (Added: 2026-02-12T14:15:00)

TECHNICAL DEBT (1):
  [1] [LOW] Add more test cases

RECENTLY MODIFIED FILES:
  - tools/hippocampus.py
    Last: 2026-02-12T14:25:00 | Core implementation

=== END MEMORY ===

Welcome back! Continuing from previous session on Windows compatibility...
```

### During Work (Context Building)

```text
User: Can you implement atomic writes for Windows?

Claude: [Working on implementation... creates tools/hippocampus.py]

User: Great! Now add error handling.

Claude: [Adding error handling...]
```

### High Context Detection (~80%)

```text
Claude: [Internal check: Context usage at 83%]
💾 Memory usage high. Saving state before continuing...

python tools/hippocampus.py save '{
  "project_context": "Building external memory manager for Claude Code",
  "active_tasks": [
    {
      "description": "Test atomic writes on Windows",
      "added_at": "2026-02-12T14:45:00",
      "priority": "high"
    }
  ],
  "technical_debt": [
    {
      "description": "Add more test cases",
      "priority": "low",
      "added_at": "2026-02-12T14:30:00"
    }
  ],
  "file_map": {
    "tools/hippocampus.py": {
      "last_modified": "2026-02-12T14:50:00",
      "summary": "Implemented atomic writes with shutil.move"
    }
  }
}'

Memory saved successfully: .hippocampus.json
📊 Active tasks: 1 | Technical debt: 1 | Files tracked: 1

Please execute `/clear` to refresh the session. Your state will be automatically restored.
```

### User Clears Session

```text
User: /clear

[Claude Code clears context window]
```

### Next Session (Automatic Restore)

```text
User: Let's test the atomic writes.

Claude: python tools/hippocampus.py load

=== CC-HIPPOCAMPUS MEMORY ===
Last Updated: 2026-02-12T14:50:00

PROJECT CONTEXT: Building external memory manager for Claude Code

ACTIVE TASKS (1):
  [1] Test atomic writes on Windows (Added: 2026-02-12T14:45:00)

TECHNICAL DEBT (1):
  [1] [LOW] Add more test cases

RECENTLY MODIFIED FILES:
  - tools/hippocampus.py
    Last: 2026-02-12T14:50:00 | Implemented atomic writes

=== END MEMORY ===

Continuing work on testing atomic writes. The memory manager is ready for testing...
```

---

## Example 2: First Time Setup

### Initial Project

```text
User: I'm starting a new Python project. Help me set up the structure.

Claude: python tools/hippocampus.py load

No memory file found. Starting fresh.

I'll help you set up a new Python project. Let's create the structure...
```

### Project Progress

```text
User: Create main.py, utils.py, and tests/

Claude: [Creates project structure...]

User: Now implement the main feature.

Claude: [Implements feature...]

python tools/hippocampus.py save '{
  "project_context": "New Python project with CLI tool",
  "active_tasks": [
    {
      "description": "Add command-line argument parsing",
      "added_at": "2026-02-12T15:00:00",
      "priority": "high"
    }
  ],
  "technical_debt": [],
  "file_map": {
    "main.py": {"last_modified": "2026-02-12T15:05:00", "summary": "Main entry point"},
    "utils.py": {"last_modified": "2026-02-12T15:03:00", "summary": "Helper functions"},
    "tests/": {"last_modified": "2026-02-12T15:04:00", "summary": "Test directory created"}
  }
}'

Memory saved. Execute `/clear` when ready to continue.
```

---

## Example 3: Manual Commands

### Quick Task Addition

```bash
# Add a task without full JSON
python tools/hippocampus.py add-task "Fix bug in error handling" high
```

### View Memory Statistics

```bash
python tools/hippocampus.py stats
```

Output:
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

### Clear and Archive

```bash
python tools/hippocampus.py clear
```

This:
1. Archives current memory to `.hippocampus_history/memory_YYYYMMDD_HHMMSS.json`
2. Creates empty memory state
3. Prints confirmation

---

## Example 4: Error Recovery

### Corrupted Memory File

```text
User: Something went wrong, the memory seems broken.

Claude: python tools/hippocampus.py load

[WARNING: Memory file corrupted - Expecting value: line 1 column 1 (char 0)]

Attempting recovery from archive...

[Loads most recent archive from .hippocampus_history/]

Memory recovered from archive: .hippocampus_history/memory_20260212_143000.json
```

### Missing Permissions

```text
Claude: python tools/hippocampus.py save '{...}'

Error writing memory: [Errno 13] Permission denied: '.hippocampus.json'

[CRITICAL: Cannot persist memory. Please check disk permissions.]
```

---

## Example 5: Multi-Day Development

### Day 1

```text
User: Start building a web scraper.

Claude: python tools/hippocampus.py load
No memory file found. Starting fresh.

[Builds scraper...]

python tools/hippocampus.py save '{
  "project_context": "Web scraper for product data",
  "active_tasks": [
    {"description": "Add rate limiting", "added_at": "...", "priority": "high"}
  ],
  "technical_debt": [
    {"description": "Handle 429 responses", "priority": "medium"}
  ],
  "file_map": {
    "scraper.py": {"last_modified": "...", "summary": "Core scraper"}
  }
}'
```

### Day 2

```text
User: Continue with the scraper.

Claude: python tools/hippocampus.py load

=== CC-HIPPOCAMPUS MEMORY ===
Last Updated: 2026-02-11T18:00:00
...

Right! We need to add rate limiting and handle 429 responses...
```

---

## Anti-Patterns to Avoid

### ❌ Never Use `/compact`

```text
WRONG:
User: Context is getting full
Claude: Let me use /compact to free up space...

RIGHT:
User: Context is getting full
Claude: Memory usage high. Saving state first...
python tools/hippocampus.py save '{...}'
Memory saved. Execute `/clear` to refresh.
```

### ❌ Don't Wait Until 95%

```text
WRONG:
Claude: [Context at 95%] Let me save now...

RIGHT:
Claude: [Context at 80%] Memory usage high. Saving state...
```

### ❌ Don't Save Partial State

```text
WRONG:
python tools/hippocampus.py save '{"active_tasks": [...]}'

RIGHT:
python tools/hippocampus.py save '{
  "project_context": "...",
  "active_tasks": [...],
  "technical_debt": [...],
  "file_map": {...}
}'
```

---

## Integration with Claude Code Hooks

To make this fully automatic, you can configure Claude Code to:

1. **On Session Start**: Auto-run `python tools/hippocampus.py load`
2. **On High Context**: Auto-trigger save workflow
3. **On Clear**: Auto-archive before clearing

Example hook configuration (in `~/.claude/settings.json`):

```json
{
  "hooks": {
    "preSessionStart": "python tools/hippocampus.py load",
    "preClear": "python tools/hippocampus.py save '{...}'"
  }
}
```

---

## Best Practices

1. **Save Early, Save Often**: Don't wait for context warnings
2. **Include Context**: Always populate `project_context` field
3. **Track Files**: Update `file_map` when modifying important files
4. **Archive Regularly**: Use `clear` to create recovery points
5. **Verify Load**: Always check that memory loaded correctly

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Memory not loading | Run `python tools/hippocampus.py load` manually |
| Save fails | Check file permissions, disk space |
| JSON corrupted | Delete `.hippocampus.json`, load from history |
| Archive too large | Clean old files in `.hippocampus_history/` |

---

**CC-Hippocampus ensures your development context never gets lost!** 🧠💾
