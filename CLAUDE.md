# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

**fifc** (fish fzf completions) is a Fish shell plugin that adds fzf powers on top of Fish's native completion engine. Fork of [gazorby/fifc](https://github.com/gazorby/fifc).

## Quick Commands

```bash
# Run tests
fish tests/test_*.fish

# Check syntax
fish -n functions/*.fish

# Install locally
fisher install .
```

## Project Structure

```
fifc/
├── functions/           # 26 Fish functions (core logic)
│   ├── fifc.fish        # Public rule definition command
│   ├── _fifc.fish       # Core fzf orchestrator
│   ├── _fifc_action.fish # Rule evaluation engine
│   ├── _fifc_preview_*.fish  # Preview handlers
│   ├── _fifc_open_*.fish     # Open handlers
│   └── _fifc_source_*.fish   # Source providers
├── completions/         # Tab completion for fifc command
├── conf.d/              # Auto-loaded config & builtin rules
├── tests/               # Fishtape test files
└── docs/                # Technical documentation
```

## Code Conventions

### Function Naming
- `fifc` - Public user command
- `_fifc_*` - Internal functions (underscore = private)
- `_fifc_preview_*` / `_fifc_open_*` / `_fifc_source_*` - Handlers

### Variable Scope
```fish
set -l var      # Local (preferred)
set -g var      # Global
set -gx var     # Global + Exported
```

### Variables (Public)
- `fifc_*` - User-configurable (e.g., `fifc_keybinding`, `fifc_show_hidden`)
- `_fifc_*` - Private internal state

## Context Variables (Available in Rules)

```fish
$fifc_candidate    # Selected item from fzf
$fifc_commandline  # Command buffer before cursor
$fifc_token        # Last token
$fifc_group        # files, directories, options, or processes
$fifc_extracted    # Extraction result if regex applied
$fifc_query        # fzf query string
```

## Adding a Preview Handler

1. Create `functions/_fifc_preview_<type>.fish`
2. Implement with tool fallback:
   ```fish
   function _fifc_preview_<type> -d "Description"
       if type -q preferred_tool
           preferred_tool "$fifc_candidate"
       else
           fallback_tool "$fifc_candidate"
       end
   end
   ```
3. Register rule in `conf.d/fifc.fish`
4. Add tests

## Rule Definition

```fish
fifc -n 'condition' -r 'regex' -p 'preview_cmd' -o 'open_cmd' -s 'source_cmd' -O 1
```

## External Tools

| Tool | Purpose | Fallback |
|------|---------|----------|
| fzf | Fuzzy finder (required) | - |
| bat | File preview | cat |
| fd | File search | find |
| chafa | Image preview | file |
| exa | Directory listing | ls |
| procs | Process tree | ps |

## Documentation

See `docs/` for detailed documentation on architecture, code standards, and roadmap.
