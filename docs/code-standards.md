# Code Standards

> **Note**: This document provides an overview. For detailed information, see the linked standards documents.

## Overview

fifc follows Fish shell conventions with project-specific patterns for the rule-based completion system.

## Quick Reference

### Function Naming
- `fifc` - Public user-facing command
- `_fifc_*` - Internal/private functions
- `_fifc_preview_*` - Preview handlers
- `_fifc_open_*` - Open handlers
- `_fifc_source_*` - Source providers

### Variable Scope
```fish
set -l var      # Local (default)
set -g var      # Global
set -x var      # Exported
set -gx var     # Global + Exported
```

### Rule Definition
```fish
fifc -n 'condition' -r 'regex' -p 'preview_cmd' -o 'open_cmd' -s 'source_cmd'
```

## Detailed Documentation

| Document | Description |
|----------|-------------|
| [code-standards-fish-shell-conventions.md](./code-standards-fish-shell-conventions.md) | File organization, function declaration, variables, string handling, control flow, error handling |
| [code-standards-fifc-patterns.md](./code-standards-fifc-patterns.md) | Rule definition, context variables, handler patterns, testing standards |
| [code-standards-development-workflow.md](./code-standards-development-workflow.md) | Code quality, git workflow, code review checklist, common pitfalls |

## Key Principles

1. **One function per file** - Match filename to function name
2. **Local scope by default** - Use `-l` unless global access needed
3. **Tool fallback chains** - Always provide alternatives for optional tools
4. **Clean up state** - Erase temporary variables after use
5. **Document with `-d`** - Every function needs a description

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
**Fish Version**: 3.4.0+
