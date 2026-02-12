#!/usr/bin/env python3
"""
CC-Hippocampus - External Memory Manager for Claude Code
=========================================================

Atomic memory persistence to prevent data loss during context compression.
Handles memory save/load/clear operations with proper error handling.

Author: Principal Software Architect
License: MIT
"""

import json
import sys
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, List


class HippocampusMemory:
    """External memory manager with atomic writes and safe recovery."""

    def __init__(self, working_dir: Optional[str] = None):
        """
        Initialize memory manager.

        Args:
            working_dir: Project root directory. If None, uses Claude Code's $workingDirectory
        """
        # Use Claude Code's working directory environment variable
        if working_dir:
            self.base_dir = Path(working_dir)
        else:
            # Default to current directory (Claude Code sets this)
            self.base_dir = Path.cwd()

        self.memory_file = self.base_dir / ".hippocampus.json"
        self.history_dir = self.base_dir / ".hippocampus_history"
        # Create base directory and history dir if they don't exist
        self.base_dir.mkdir(parents=True, exist_ok=True)
        self.history_dir.mkdir(exist_ok=True)

    def _get_timestamp(self) -> str:
        """Get ISO-8601 formatted timestamp."""
        return datetime.now().isoformat()

    def _atomic_write(self, data: Dict[str, Any], target_path: Path) -> bool:
        """
        Atomically write JSON data to prevent corruption.

        Strategy: Write to temp file -> fsync -> replace (cross-platform)

        Args:
            data: JSON-serializable data
            target_path: Final destination path

        Returns:
            True if successful, False otherwise
        """
        import tempfile
        import shutil

        try:
            # Create temp file in same directory
            temp_dir = target_path.parent
            temp_path = temp_dir / f".{target_path.name}.tmp"

            # Write to temp file
            with open(temp_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                f.flush()
                os.fsync(f.fileno())

            # Cross-platform atomic replace using shutil.move
            # This handles Windows file locking correctly
            shutil.move(str(temp_path), str(target_path))

            return True

        except Exception as e:
            print(f"Error writing memory: {e}", file=sys.stderr)
            # Cleanup temp file if it exists
            temp_path.unlink(missing_ok=True)
            return False

    def load(self) -> str:
        """
        Load and format memory for LLM context injection.

        Returns:
            Formatted string for LLM prompt injection, or empty string if no memory
        """
        try:
            if not self.memory_file.exists():
                print("No memory file found. Starting fresh.", file=sys.stderr)
                return ""

            with open(self.memory_file, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Format for LLM consumption
            output = []
            output.append("=== CC-HIPPOCAMPUS MEMORY ===")
            output.append(f"Last Updated: {data.get('last_updated', 'Unknown')}")
            output.append("")

            # Project Context
            project_ctx = data.get('project_context', '').strip()
            if project_ctx:
                output.append("PROJECT CONTEXT:")
                output.append(f"  {project_ctx}")
                output.append("")

            # Active Tasks
            active_tasks = data.get('active_tasks', [])
            if active_tasks:
                output.append(f"ACTIVE TASKS ({len(active_tasks)}):")
                for i, task in enumerate(active_tasks, 1):
                    if isinstance(task, dict):
                        desc = task.get('description', 'Unknown task')
                        added = task.get('added_at', '')
                        output.append(f"  [{i}] {desc} (Added: {added})")
                    else:
                        output.append(f"  [{i}] {task}")
                output.append("")

            # Technical Debt
            tech_debt = data.get('technical_debt', [])
            if tech_debt:
                output.append(f"TECHNICAL DEBT ({len(tech_debt)} items):")
                for i, debt in enumerate(tech_debt, 1):
                    if isinstance(debt, dict):
                        desc = debt.get('description', 'Unknown issue')
                        priority = debt.get('priority', 'medium')
                        output.append(f"  [{i}] [{priority.upper()}] {desc}")
                    else:
                        output.append(f"  [{i}] {debt}")
                output.append("")

            # File Map
            file_map = data.get('file_map', {})
            if file_map:
                output.append("RECENTLY MODIFIED FILES:")
                for file_path, info in sorted(file_map.items()):
                    last_mod = info.get('last_modified', 'Unknown')
                    summary = info.get('summary', '')
                    output.append(f"  - {file_path}")
                    output.append(f"    Last: {last_mod} | {summary}")
                output.append("")

            output.append("=== END MEMORY ===")
            return "\n".join(output)

        except json.JSONDecodeError as e:
            print(f"Memory file corrupted: {e}", file=sys.stderr)
            return f"[WARNING: Memory file corrupted - {e}]"
        except Exception as e:
            print(f"Error loading memory: {e}", file=sys.stderr)
            return f"[ERROR: Failed to load memory - {e}]"

    def save(self, input_json: str) -> bool:
        """
        Save memory state from JSON input.

        Args:
            input_json: JSON string containing memory data, or file path prefixed with '@'

        Returns:
            True if saved successfully, False otherwise
        """
        try:
            # Check if input is a file reference (starts with @)
            if input_json.startswith('@'):
                file_path = input_json[1:]  # Remove @ prefix
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
            else:
                # Parse inline JSON
                data = json.loads(input_json)

            # Enforce schema
            current_data: Dict[str, Any] = {
                'last_updated': self._get_timestamp(),
                'project_context': data.get('project_context', ''),
                'active_tasks': data.get('active_tasks', []),
                'technical_debt': data.get('technical_debt', []),
                'file_map': data.get('file_map', {})
            }

            success = self._atomic_write(current_data, self.memory_file)
            if success:
                print(f"Memory saved successfully: {self.memory_file}", file=sys.stderr)
            return success

        except json.JSONDecodeError as e:
            print(f"Invalid JSON input: {e}", file=sys.stderr)
            return False
        except Exception as e:
            print(f"Error saving memory: {e}", file=sys.stderr)
            return False

    def clear(self) -> bool:
        """
        Archive current memory and reset to empty state.

        Returns:
            True if cleared successfully, False otherwise
        """
        try:
            # Archive existing memory
            if self.memory_file.exists():
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                archive_path = self.history_dir / f"memory_{timestamp}.json"

                with open(self.memory_file, 'r', encoding='utf-8') as f:
                    current_data = json.load(f)

                # Write archive
                self._atomic_write(current_data, archive_path)
                print(f"Memory archived: {archive_path}", file=sys.stderr)

            # Reset to empty state
            empty_state = {
                'last_updated': self._get_timestamp(),
                'project_context': '',
                'active_tasks': [],
                'technical_debt': [],
                'file_map': {}
            }

            success = self._atomic_write(empty_state, self.memory_file)
            if success:
                print("Memory cleared and reset", file=sys.stderr)
            return success

        except Exception as e:
            print(f"Error clearing memory: {e}", file=sys.stderr)
            return False

    def add_task(self, description: str, priority: str = "medium") -> bool:
        """Add a task to active tasks list."""
        try:
            current = {}
            if self.memory_file.exists():
                with open(self.memory_file, 'r', encoding='utf-8') as f:
                    current = json.load(f)

            tasks = current.get('active_tasks', [])
            tasks.append({
                'description': description,
                'added_at': self._get_timestamp(),
                'priority': priority
            })

            current['active_tasks'] = tasks
            current['last_updated'] = self._get_timestamp()

            return self._atomic_write(current, self.memory_file)

        except Exception as e:
            print(f"Error adding task: {e}", file=sys.stderr)
            return False

    def get_stats(self) -> Dict[str, Any]:
        """Get memory statistics."""
        try:
            if not self.memory_file.exists():
                return {
                    'exists': False,
                    'size_bytes': 0,
                    'active_tasks': 0,
                    'technical_debt': 0,
                    'files_tracked': 0
                }

            with open(self.memory_file, 'r', encoding='utf-8') as f:
                data = json.load(f)

            return {
                'exists': True,
                'size_bytes': self.memory_file.stat().st_size,
                'last_updated': data.get('last_updated', 'Unknown'),
                'active_tasks': len(data.get('active_tasks', [])),
                'technical_debt': len(data.get('technical_debt', [])),
                'files_tracked': len(data.get('file_map', {}))
            }

        except Exception as e:
            return {'error': str(e)}


def main():
    """CLI entry point."""
    if len(sys.argv) < 2:
        print("Usage: python hippocampus.py <command> [args]", file=sys.stderr)
        print("Commands: load, save, clear, stats, add-task", file=sys.stderr)
        sys.exit(1)

    command = sys.argv[1].lower()
    memory = HippocampusMemory()

    if command == "load":
        result = memory.load()
        if result:
            print(result)
        sys.exit(0)

    elif command == "save":
        if len(sys.argv) < 3:
            print("Usage: python hippocampus.py save '<json>'", file=sys.stderr)
            sys.exit(1)
        input_json = sys.argv[2]
        success = memory.save(input_json)
        sys.exit(0 if success else 1)

    elif command == "clear":
        success = memory.clear()
        sys.exit(0 if success else 1)

    elif command == "stats":
        stats = memory.get_stats()
        print(json.dumps(stats, indent=2))
        sys.exit(0)

    elif command == "add-task":
        if len(sys.argv) < 3:
            print("Usage: python hippocampus.py add-task '<description>' [priority]", file=sys.stderr)
            sys.exit(1)
        description = sys.argv[2]
        priority = sys.argv[3] if len(sys.argv) > 3 else "medium"
        success = memory.add_task(description, priority)
        sys.exit(0 if success else 1)

    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
