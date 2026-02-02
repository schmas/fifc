# Codebase Summary

## Overview

fifc is a modular Fish shell plugin (~16,000 tokens) comprising 26 functions organized by concern. The architecture separates:
- **Completion orchestration** (_fifc.fish, fifc.fish)
- **Rule evaluation & matching** (_fifc_action.fish)
- **Preview handlers** (_fifc_preview_*.fish, 7 functions)
- **Open handlers** (_fifc_open_*.fish, 6 functions)
- **Source providers** (_fifc_source_*.fish, 2 functions)
- **Helper utilities** (_fifc_*.fish, 8 utilities)
- **Configuration** (conf.d/fifc.fish, completions/)
- **Tests** (10 Fishtape test files)

## Directory Structure

```
fifc/
├── functions/               # 26 Fish functions (core plugin logic)
│   ├── fifc.fish           # Rule definition interface & validation
│   ├── _fifc.fish          # Main completion orchestrator (100 LOC)
│   ├── _fifc_action.fish   # Rule evaluation engine (75 LOC)
│   ├── _fifc_*_preview.fish    # 7 preview handlers
│   ├── _fifc_*_open.fish       # 6 open action handlers
│   ├── _fifc_source_*.fish     # 2 source providers (files, dirs)
│   └── _fifc_*.fish            # 8 utility functions
├── completions/            # Tab completion for fifc command
│   └── fifc.fish           # Argument descriptions
├── conf.d/                 # Auto-loaded configuration
│   └── fifc.fish           # Keybindings + builtin rules
├── tests/                  # Fishtape test suite
│   ├── test_*.fish         # 10 test files
│   └── _resources/         # Test fixtures
├── .github/workflows/      # CI pipeline (syntax, tests, format)
├── README.md               # User documentation (265 lines)
├── CHANGELOG.md            # Version history
├── LICENSE                 # MIT
└── repomix-output.xml      # Codebase compaction
```

## Key Files & Purpose

### Core Functions

#### **fifc.fish** (58 LOC)
**Purpose**: User-facing rule definition command
**Key Responsibilities**:
- Parse CLI arguments (-n, -p, -o, -s, -e, -r, -O, -f, -h flags)
- Validate regex patterns and order numbers
- Store rule data in indexed arrays (_fifc_comp_N)
- Categorize rules as ordered or unordered

**Public Interface**:
```fish
fifc -n 'condition' -r 'regex' -p preview_cmd -o open_cmd -s source_cmd -e 'extract_regex' -f 'fzf_opts' -O 1
```

#### **_fifc.fish** (100 LOC)
**Purpose**: Main completion orchestrator and fzf integration
**Key Responsibilities**:
- Gather completions from Fish's native system
- Detect completion group (files, directories, options, processes)
- Resolve source command via rule evaluation
- Launch fzf with preview and open keybindings
- Post-process selected items (escape, extract, insert trailing space)
- Implement case-insensitive flag support

**Key Variables Exposed**:
- `fifc_commandline`: Command buffer before cursor
- `fifc_token`: Last token (completion context)
- `fifc_group`: Auto-detected group type
- `fifc_query`: Initial fzf search query
- `fifc_case_insensitive`: Enable case-insensitive matching

#### **_fifc_action.fish** (75 LOC)
**Purpose**: Rule matching engine for preview/source/open commands
**Key Responsibilities**:
- Evaluate all rules in precedence order (ordered first, then unordered)
- Match both condition commands and regex patterns
- Extract description from completion list
- Return first matching command for given action type
- Set extraction regex from matching rule

**Flow**:
1. Evaluate condition test command (if present)
2. Evaluate regex pattern against commandline (if present)
3. If both match (OR logic), find the action (preview/source/open)
4. Execute or return the action command

#### **_fifc_completion_group.fish** (utility)
**Purpose**: Detect completion type from Fish's completion list
**Detection Rules**:
- `directories`: All items are directories
- `files`: Mix of files and directories
- `options`: Items match regex `\h+\-+\h*$`
- `processes`: Items match regex `^[0-9]+$` (PIDs)

### Preview Handlers

| Function | Preview Type | Tool Used |
|----------|--------------|-----------|
| _fifc_preview_file | Files (text, JSON, images, archives, binary) | bat, chafa, hexyl, 7z |
| _fifc_preview_file_default | File metadata fallback | file command |
| _fifc_preview_dir | Directory listing | exa or ls |
| _fifc_preview_cmd | Command man pages | bat + man |
| _fifc_preview_fn | Function definitions | bat + type |
| _fifc_preview_opt | Man page section for option | bat + man + less |
| _fifc_preview_process | Process tree info | procs or ps |

### Open Handlers

| Function | Action | Tool Used |
|----------|--------|-----------|
| _fifc_open_file | Open with configured editor | `$fifc_editor` |
| _fifc_open_dir | Explore directory tree | broot |
| _fifc_open_cmd | Display full man page | _fifc_preview_cmd |
| _fifc_open_fn | Open function file | _fifc_open_file |
| _fifc_open_opt | Open man page at option | _fifc_preview_opt |
| _fifc_open_process | Interactive process tree | procs or ps |

### Source Providers

| Function | Source | Behavior |
|----------|--------|----------|
| _fifc_source_files | File search | Uses fd with hidden files support |
| _fifc_source_directories | Directory search | Uses fd --type d |

### Utility Functions

| Function | Purpose |
|----------|---------|
| _fifc_help | Display fifc command help text |
| _fifc_file_type | Detect file MIME type for preview routing |
| _fifc_parse_complist | Extract first column from completion list |
| _fifc_parse_pid | Extract PID from ps output |
| _fifc_expand_tilde | Expand ~ to home directory |
| _fifc_path_to_complete | Extract path from commandline token |
| _fifc_test_version | Compare version numbers (semver) |

### Configuration Files

#### **conf.d/fifc.fish** (62 LOC)
**Purpose**: Plugin initialization and built-in rule registration
**Responsibilities**:
- Initialize private variables (_fifc_comp_count, _fifc_ordered/unordered_comp)
- Set default keybindings (Tab for completion, Ctrl-O for open)
- Register 3 unconditional source rules (directories, files, processes)
- Register 6 conditional preview/open rules (options, commands, functions, files, directories, processes)
- Load rules only inside fzf context (when _fifc_launched_by_fzf is set)

**Keybindings**:
```fish
bind $fifc_keybinding _fifc              # Default: Tab
bind $fifc_open_keybinding ...           # Default: Ctrl-O (inside fzf)
```

#### **completions/fifc.fish** (8 LOC)
**Purpose**: Tab completion for the `fifc` command itself
**Completions**: Defines descriptions for all fifc flags

## Data Flow

### Completion Trigger
```
User presses Tab
    ↓
_fifc.fish executes
    ↓
Fish gathers native completions
    ↓
_fifc_completion_group detects group type
    ↓
_fifc_action source runs matching source rule
    ↓
fzf launches with preview callback
    ↓
User selects item, preview shown via _fifc_action preview
    ↓
User presses Ctrl-O or Tab, _fifc_action open executes
    ↓
Selected item post-processed and inserted into commandline
```

### Rule Evaluation
```
_fifc_action called with action (preview/source/open)
    ↓
For each rule in order (ordered rules first, then unordered):
    ├─ Evaluate condition command (test, type, etc.)
    ├─ Evaluate regex pattern against commandline
    ├─ If both match, extract and return action command
    └─ If action command missing, try next rule
    ↓
If no rule matched, use default:
    ├─ preview: show $fifc_desc (Fish completion description)
    ├─ source: call _fifc_parse_complist
    └─ open: do nothing
```

## Variable Scope & Lifecycle

### Public User-Configurable Variables
```fish
fifc_keybinding              # Keybinding trigger (default: \t)
fifc_open_keybinding         # Open action trigger (default: ctrl-o)
fifc_editor                  # Editor for opening files
fifc_show_hidden             # Show hidden files in completion
fifc_case_insensitive        # Enable case-insensitive matching
fifc_bat_opts                # Custom bat options
fifc_chafa_opts              # Custom chafa options
fifc_hexyl_opts              # Custom hexyl options
fifc_fd_opts                 # Custom fd options
fifc_exa_opts                # Custom exa options
fifc_procs_opts              # Custom procs options
fifc_broot_opts              # Custom broot options
fifc_ls_opts                 # Custom ls options
```

### Internal Private Variables
```fish
_fifc_comp_count             # Counter for rule numbering
_fifc_ordered_comp[]         # Indexed array of ordered rules
_fifc_unordered_comp         # Array of unordered rules
_fifc_complist_path          # Temp file with completions
_fifc_launched_by_fzf        # Set when running inside fzf
_fifc_extract_regex          # Extraction pattern for current rule
_fifc_custom_fzf_opts        # Custom fzf options from rule
```

### Context Variables (Exposed to Rules)
```fish
fifc_candidate               # Currently selected item
fifc_commandline             # Command buffer before cursor
fifc_token                   # Last token from commandline
fifc_group                   # Detected group: files, directories, options, processes
fifc_extracted               # Result of extraction regex (if applicable)
fifc_query                   # Initial fzf search query
fifc_desc                    # Fish completion description for candidate
```

## Testing

### Test Files (10 Fishtape tests)
- **test_fifc.fish**: Rule registration and argument parsing
- **test_source.fish**: Source command evaluation
- **test_preview_file.fish**: File preview command selection
- **test_open_cmd.fish**: Open command execution
- **test_open_file.fish**: File open handler
- **test_file_type.fish**: MIME type detection
- **test_group.fish**: Completion group detection
- **test_match_order.fish**: Rule precedence evaluation
- **test_exposed_vars.fish**: Context variable exposure
- **version_test.fish**: Version comparison utility

### Test Resources
```
tests/_resources/
├── dir with spaces/       # Test paths with spaces
│   ├── file 1.txt
│   ├── file 2.txt
│   ├── file.json
│   ├── file.7z
│   ├── file.bin
│   ├── file.pdf
│   └── fish.png
└── target.txt
```

## Code Organization Principles

### Naming Conventions
- `_fifc_<action>_<type>.fish`: Action handlers (e.g., _fifc_preview_file)
- `_fifc_<utility>.fish`: Helper functions (e.g., _fifc_parse_pid)
- Underscore prefix marks internal functions (Fish convention)

### Function Size
- Core orchestrators: 50-100 LOC (_fifc, _fifc_action)
- Handlers: 5-20 LOC each (simple and focused)
- Utilities: 5-10 LOC (single responsibility)

### Error Handling
- Graceful fallbacks: Use alternative tools if primary unavailable
- Type checking: `type -q` before executing external commands
- Null safety: Check variable existence with `test -n`

## Dependencies & Tool Integration

### Tool Detection Pattern
```fish
if type -q primary_tool
    # Use primary tool with options
else
    # Fallback to alternative
end
```

### Options Preservation
- Each tool supports custom options via `$fifc_*_opts` variable
- Options passed as lists (not quoted strings)
- Example: `set -U fifc_bat_opts --style=numbers`

## Performance Characteristics

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Rule evaluation | O(n) | Linear scan, stops at first match |
| Completion gathering | O(1) | Reuses Fish's built-in completion cache |
| Preview rendering | O(file_size) | Can be slow for large files |
| fzf startup | ~50-100ms | Depends on source command |

## Modularization Strategy

Each function has a single, clear responsibility:
1. **Orchestration** (_fifc): High-level flow control
2. **Evaluation** (_fifc_action): Rule matching engine
3. **Specialized Handlers** (_fifc_*_*): One handler per file type/action
4. **Utilities**: Reusable helpers with no side effects

This enables:
- Easy testing of individual functions
- Clear extension points for customization
- Low coupling between components
- High cohesion within components

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
**Total Lines of Code**: ~16,000 tokens (50 files)
**Test Coverage**: 10 Fishtape test suites
