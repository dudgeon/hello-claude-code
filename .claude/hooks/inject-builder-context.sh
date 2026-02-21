#!/bin/bash
if [ -f "$CLAUDE_PROJECT_DIR/.builder-mode" ]; then
  cat "$CLAUDE_PROJECT_DIR/.claude/builder-context.md"
fi
exit 0
