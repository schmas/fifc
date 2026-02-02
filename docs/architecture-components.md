# Architecture: Component Diagram & Overview

## High-Level Overview

fifc is a thin integration layer between Fish shell's native completion system and fzf (fuzzy finder). It provides:

1. **Completion Orchestration**: Gather Fish completions and launch fzf
2. **Rule-Based Customization**: Match user-defined rules to completion contexts
3. **Preview System**: Display intelligent previews based on item type
4. **Tool Integration**: Leverage modern Unix tools for enhanced previews

```
User Input (Tab)
    ↓
Fish Completion Engine → Completion List
    ↓
_fifc.fish (Orchestrator)
    ├─ Detect Group (files, dirs, options, processes)
    ├─ Evaluate Rules (source) → Source Command
    ├─ Launch fzf
    │   ├─ Preview Callback → _fifc_action (preview)
    │   ├─ Open Callback → _fifc_action (open)
    │   └─ User Selection
    └─ Post-Process & Insert Result
```

## Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Fish Shell                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Completion System (builtin complete command)       │   │
│  │  • Gather completions                               │   │
│  │  • Manage descriptions                              │   │
│  │  • Generate completion list                         │   │
│  └────────────┬────────────────────────────────────────┘   │
└───────────────┼──────────────────────────────────────────────┘
                │
                ↓
        ┌──────────────────┐
        │  _fifc.fish      │  (Main Orchestrator)
        │                  │
        │  1. Gather       │
        │  2. Group        │
        │  3. Get Source   │
        │  4. Launch fzf   │
        │  5. Post-process │
        └────┬─────┬───────┘
             │     │
        ┌────▼─┐  ┌▼──────────────────┐
        │fzf   │  │ _fifc_action      │  (Rule Engine)
        │      │  │                   │
        │Multi │  │ 1. Evaluate rules │
        │-line │  │ 2. Match          │
        │Fuzzy │  │ 3. Execute cmd    │
        │Find  │  │                   │
        └──────┘  └────┬───────────────┘
                        │
        ┌───────────────┼────────────────────────┐
        │               │                        │
        ▼               ▼                        ▼
  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐
  │ Preview      │  │ Source       │  │ Open             │
  │ Handlers     │  │ Providers    │  │ Handlers         │
  │              │  │              │  │                  │
  │ • file       │  │ • files      │  │ • file           │
  │ • dir        │  │ • directories│  │ • dir (broot)    │
  │ • cmd        │  │ • process    │  │ • cmd (man)      │
  │ • fn         │  │              │  │ • fn (editor)    │
  │ • opt        │  │              │  │ • process (tree) │
  │ • process    │  │              │  │ • opt (man)      │
  └──────────────┘  └──────────────┘  └──────────────────┘
        │                                      │
        └──────────────┬───────────────────────┘
                       │
        ┌──────────────▼────────────────────┐
        │   External Tools (Optional)       │
        │                                   │
        │ • bat (syntax highlighting)      │
        │ • chafa (image preview)           │
        │ • hexyl (binary preview)          │
        │ • fd (fast file search)           │
        │ • exa (directory listing)         │
        │ • ripgrep (pattern matching)      │
        │ • procs (process tree)            │
        │ • broot (tree exploration)        │
        └───────────────────────────────────┘
```

## Completion Groups

The system automatically detects and categorizes completion items:

| Group | Detection | Purpose |
|-------|-----------|---------|
| **files** | Mix of files and directories | Show all path completions |
| **directories** | Only directories | Optimized for directory navigation |
| **options** | Items match `\h+\-+\h*$` | Command-line options/flags |
| **processes** | All items are PIDs | Process selection (ps output) |

Detection logic in `_fifc_completion_group.fish`:

```fish
# Check if all items are directories
if all directories → group = "directories"

# Check if all items are options (whitespace + dash)
else if all match "^[[:space:]]*-" → group = "options"

# Check if all items are processes (numbers only)
else if all match "^[0-9]+$" → group = "processes"

# Otherwise, mixed files/directories
else → group = "files"
```

## Handler Architecture

### Preview Handlers

Each preview handler follows the same pattern:

```fish
function _fifc_preview_<type> -d "Description"
    # 1. Check primary tool availability
    if type -q preferred_tool
        # 2. Use preferred tool with options
        preferred_tool $fifc_*_opts "$fifc_candidate"
        return
    end

    # 3. Fallback chain
    if type -q fallback_tool
        fallback_tool "$fifc_candidate"
        return
    end

    # 4. Final fallback - show metadata
    _fifc_preview_file_default "$fifc_candidate"
end
```

### Source Providers

Source providers generate completion items:

```fish
function _fifc_source_<type> -d "Generate items for completion"
    # Output completion items
    # Format: item<TAB>optional_description
    fd --hidden --type f | while read -l item
        echo "$item"
    end
end
```

### Open Handlers

Open handlers perform actions on selected items:

```fish
function _fifc_open_<type> -d "Open/execute action on item"
    # Examples:
    # - Open file: $fifc_editor "$fifc_candidate"
    # - Open directory: broot "$fifc_candidate"
    # - Show man page: man "$fifc_candidate"
end
```

## Tool Integration Pattern

```
Tool Priority Chain
│
├─→ Primary Tool (modern, feature-rich)
│   └─ Check with: type -q primary
│   └─ Example: bat (syntax highlighting)
│
├─→ Secondary Tool (wider availability)
│   └─ Fallback if primary unavailable
│   └─ Example: cat (universal)
│
└─→ Final Fallback (universal or metadata)
    └─ File info, error message, or disabled
    └─ Example: file command
```

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
