# CC-Hippocampus: Behavioral Protocol

## Purpose

CC-Hippocampus prevents context loss by persisting Claude's working memory to disk before context compression. This ensures that project understanding, active tasks, and technical debt are never forgotten during long development sessions.

## Core Principles

1. **Memory is External**: Your cognitive state exists in `.hippocampus.json`, not just in the current context window.
2. **Proactive Preservation**: Save memory BEFORE it's needed, not after it's lost.
3. **Explicit Handoff**: Always inform the user when transferring state between session and disk.

---

## Trigger Conditions

Execute memory operations when ANY of the following occur:

### 1. High Context Usage (>80%)
When you detect the conversation approaching context limits, initiate memory preservation **immediately**.

**Detection Signal**:
```
<context_usage>
  - token_count: 160000+
  - percentage: 80%+
</context_usage>
```

**Action**: Save memory and prepare for `/clear`.

### 2. Intention to Run `/compact`
The native `/compact` command is **FORBIDDEN** - it destroys memory irreversibly.

**WRONG**:
```
User: Can you help me with this?
Claude: Let me use /compact to free up space...
```

**CORRECT**:
```
User: Can you help me with this?
Claude: Memory usage is high. Saving state before refresh...
[Execute hippocampus.py save]
```

### 3. Session Start (Boot)
At the **very beginning** of every conversation, load external memory.

**Mandatory First Action**:
```bash
python tools/hippocampus.py load
```

**Response Template**:
```
[Memory loaded: {stats}]
- Active tasks: {N}
- Technical debt: {M}
- Last updated: {timestamp}

Continuing from previous session...
```

### 4. User Requests `/clear` or `/compact`
Intercept and redirect to safe workflow.

**Intervention**:
```
User: /clear
Claude: [STOP] First, persisting memory to prevent data loss...
[Save memory]
User: Memory saved. Execute /clear now to refresh session.
```

---

## Execution Workflow

### Workflow A: Safe Context Compression

**Step 1: Detect** (Trigger condition met)
```
[Internal] Context at 85%. Need to preserve state.
```

**Step 2: Summarize** (Prepare JSON)
```json
{
  "project_context": "Building CC-Hippocampus plugin for Claude Code",
  "active_tasks": [
    {
      "description": "Implement memory persistence",
      "added_at": "2026-02-12T10:30:00",
      "priority": "high"
    }
  ],
  "technical_debt": [
    {
      "description": "Add error recovery for corrupted JSON",
      "priority": "medium"
    }
  ],
  "file_map": {
    "tools/hippocampus.py": {
      "last_modified": "2026-02-12T10:45:00",
      "summary": "Core memory manager with atomic writes"
    }
  }
}
```

**Step 3: Save** (Execute)
```bash
python tools/hippocampus.py save '{json}'
```

**Step 4: Inform** (User notification)
```
💾 Memory saved successfully
📊 Active tasks: 1 | Technical debt: 1 | Files tracked: 1

Please execute `/clear` to refresh the session. Your state will be automatically restored on next load.
```

**Step 5: Wait** (User action required)
```
[AWAITING: User executes /clear]
```

**Step 6: Restore** (On next session)
```
python tools/hippocampus.py load
[Memory loaded]
Continuing work on: memory persistence...
```

### Workflow B: Forced Clear Recovery

If user executes `/clear` without prior save:

**Immediate Action**:
```
[WARNING: Context compression detected without prior save]
Attempting recovery...
python tools/hippocampus.py load
```

**Fallback**: If no memory exists, bootstrap from codebase:
```
Rebuilding context from codebase...
- Scanning recent commits
- Analyzing modified files
- Reconstructing active tasks
```

---

## Memory Schema

### Required Fields

Every save operation **MUST** include:

```json
{
  "project_context": "string (required)",
  "active_tasks": "array of {description, added_at, priority}",
  "technical_debt": "array of {description, priority, added_at}",
  "file_map": "object mapping paths to {last_modified, summary}"
}
```

### Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| `project_context` | string | High-level summary of project goals and current focus |
| `active_tasks` | array | List of in-progress work items |
| `technical_debt` | array | Pending refactors, bugs, improvements |
| `file_map` | object | Recently modified files with summaries |

---

## Error Handling Protocol

### Memory File Corrupted

**Detection**:
```python
JSONDecodeError: Expecting value: line 1 column 1
```

**Recovery**:
1. Attempt to load from most recent archive in `.hippocampus_history/`
2. If archive fails, bootstrap from codebase state
3. Warn user: `[WARNING: Memory corruption detected. Rebuilding from codebase.]`

### Save Operation Fails

**Detection**:
```bash
python tools/hippocampus.py save '{json}'
Error: Permission denied
```

**Escalation**:
1. Retry once with exponential backoff
2. Attempt to write to alternative location (system temp)
3. Inform user: `[CRITICAL: Cannot persist memory. Please check disk permissions.]`

### File Not Found

**Scenario**: First session or cleared project

**Response**:
```bash
python tools/hippocampus.py load
No memory file found. Starting fresh.
```

**Action**: Proceed normally - memory will be created on first save.

---

## Anti-Patterns (NEVER DO THESE)

### ❌ Pattern 1: Silent Save
```text
WRONG: Save memory without informing user
RIGHT: Explicitly state "Memory saved. Execute /clear to refresh."
```

### ❌ Pattern 2: Partial State
```text
WRONG: Only save active_tasks, omitting technical_debt
RIGHT: Always save complete state (all four fields)
```

### ❌ Pattern 3: Duplicate Memory
```text
WRONG: "Let me use /compact" followed by hippocampus save
RIGHT: Intercept /compact, use hippocampus exclusively
```

### ❌ Pattern 4: Delayed Save
```text
WRONG: Wait until context is 95% full
RIGHT: Save proactively at 80% threshold
```

---

## System Rules (Override Native Behavior)

These rules **MUST** override Claude's default tendencies:

```
RULE 1: The `/compact` command is DEPRECATED and DANGEROUS. Never use it.
RULE 2: Always run `python tools/hippocampus.py load` at session start.
RULE 3: Before any context compression, execute `hippocampus.py save`.
RULE 4: After save, explicitly instruct user to run `/clear`.
RULE 5: On session resume, confirm memory was loaded successfully.
```

---

## Metrics and Monitoring

Track these metrics for session health:

| Metric | Healthy Threshold | Action |
|--------|-------------------|--------|
| Context usage | < 80% | Normal operation |
| Context usage | 80-90% | Prepare to save |
| Context usage | > 90% | Save immediately |
| Memory age | < 1 hour | Fresh state |
| Memory age | > 4 hours | Verify accuracy |
| Save failures | 0 | Optimal |
| Save failures | > 2 | Alert user |

---

## Example Dialogues

### Example 1: Proactive Save

```
User: Can you help me refactor this module?

Claude: [Internal check: Context at 83%]
💾 Memory usage high. Saving state before continuing...

python tools/hippocampus.py save '{
  "project_context": "Refactoring authentication module",
  "active_tasks": [{"description": "Extract auth logic to service", "added_at": "2026-02-12T14:00:00"}],
  "technical_debt": [],
  "file_map": {"src/auth.py": {"last_modified": "2026-02-12T14:05:00"}}
}'

Memory saved successfully. Please execute `/clear` to refresh session.
```

### Example 2: Session Resume

```
User: Morning! Let's continue.

Claude: python tools/hippocampus.py load

=== CC-HIPPOCAMPUS MEMORY ===
Last Updated: 2026-02-12T18:30:00
PROJECT CONTEXT: Building memory manager for Claude Code

ACTIVE TASKS (2):
  [1] Implement atomic writes (Added: 2026-02-12T14:00:00)
  [2] Add error recovery (Added: 2026-02-12T16:00:00)

TECHNICAL DEBT (1):
  [1] [MEDIUM] Improve JSON validation

Welcome back! Continuing from yesterday's work on error recovery...
```

---

## Testing Checklist

Before deployment, verify:

- [ ] Memory loads correctly on session start
- [ ] Save operation is atomic (no corruption on crash)
- [ ] Clear archives previous state properly
- [ ] Works on macOS, Linux, and Windows
- [ ] Handles corrupted JSON gracefully
- [ ] Proper UTF-8 encoding for all languages
- [ ] File permissions don't cause failures
- [ ] Archive history doesn't grow indefinitely

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-12 | Initial implementation |
