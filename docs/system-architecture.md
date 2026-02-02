# System Architecture

> **Note**: This document provides an overview. For detailed information, see the linked architecture documents.

## Overview

fifc is a thin integration layer between Fish shell's native completion system and fzf (fuzzy finder).

**Core Capabilities**:
1. Completion Orchestration - Gather Fish completions and launch fzf
2. Rule-Based Customization - Match user-defined rules to completion contexts
3. Preview System - Display intelligent previews based on item type
4. Tool Integration - Leverage modern Unix tools for enhanced previews

## Quick Architecture Diagram

```
User Input (Tab)
    ↓
Fish Completion Engine → Completion List
    ↓
_fifc.fish (Orchestrator)
    ├─ Detect Group (files, dirs, options, processes)
    ├─ Evaluate Rules → Source Command
    ├─ Launch fzf
    │   ├─ Preview Callback
    │   ├─ Open Callback
    │   └─ User Selection
    └─ Post-Process & Insert Result
```

## Detailed Documentation

| Document | Description |
|----------|-------------|
| [architecture-components.md](./architecture-components.md) | Component diagram, handler architecture, tool integration |
| [architecture-data-flow.md](./architecture-data-flow.md) | 5-phase completion flow, rule evaluation engine, context variables |
| [architecture-performance.md](./architecture-performance.md) | Optimization strategies, error handling, extension points |

## Key Components

- **`_fifc.fish`**: Main orchestrator (100 LOC)
- **`_fifc_action.fish`**: Rule evaluation engine (75 LOC)
- **`fifc.fish`**: User-facing rule definition command
- **Preview/Open/Source handlers**: Modular action handlers

## Completion Groups

| Group | Detection |
|-------|-----------|
| files | Mix of files and directories |
| directories | Only directories |
| options | Items match `\h+\-+\h*$` |
| processes | All items are PIDs |

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
