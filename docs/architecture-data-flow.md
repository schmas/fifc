# Architecture: Data Flow & Rule Engine

## Data Flow: Completion to Selection

### Phase 1: Initialization
```
User presses Tab
    │
    ├─→ _fifc.fish function called
    │
    ├─→ Get commandline context
    │   └─ fifc_commandline = "git add src/main."
    │   └─ fifc_token = "main."
    │
    ├─→ Get Fish completions
    │   └─ complete -C -- "$fifc_commandline"
    │   └─ Output saved to $_fifc_complist_path
    │   └─ Example:
    │       main.fish<TAB>Main fish file
    │       main.go<TAB>Go source
    │
    └─→ Detect group
        └─ _fifc_completion_group
        └─ All items are files → fifc_group = "files"
```

### Phase 2: Source Resolution
```
_fifc_action source is called
    │
    ├─→ Iterate rules in order
    │
    ├─→ Rule 1 (ordered, priority 1):
    │   ├─ Condition: user-defined custom rule
    │   ├─ Regex: user-defined pattern
    │   └─ NOT MATCHED → continue
    │
    ├─→ Rule 2 (unordered builtin):
    │   ├─ Condition: test "$fifc_group" = "files"
    │   ├─ MATCHED ✓
    │   ├─ Source: _fifc_source_files
    │   └─ STOP (first match wins)
    │
    ├─→ _fifc_source_files executes
    │   └─ fd --hidden --type f | ...
    │   └─ Output: list of files in expanded search
    │
    └─→ Return source command
```

### Phase 3: fzf Execution
```
eval "$source_cmd | fzf ..."
    │
    ├─→ Source provides completion items
    │
    ├─→ fzf renders interface with:
    │   ├─ Input: all files from source
    │   ├─ Previewer: --preview '_fifc_action preview {} {q}'
    │   ├─ Bindings:
    │   │   └─ Ctrl-O: --bind='ctrl-o:execute(...open...)'
    │   └─ Options: case-insensitive flag, multi-select, etc.
    │
    ├─→ User types in search (fuzzy filtered by fzf)
    │   └─ Query: "main" → shows files containing "main"
    │
    └─→ User navigates with arrow keys
```

### Phase 4: Preview Rendering
```
fzf calls preview callback: _fifc_action preview {selected} {query}
    │
    ├─→ _fifc_action evaluation:
    │   ├─ fifc_candidate = "src/main.fish"
    │   ├─ fifc_query = "main"
    │
    ├─→ Iterate rules for preview action:
    │   ├─ Rule X: -n 'test -f "$fifc_candidate"'
    │   ├─ Condition MATCHED ✓
    │   ├─ Preview: _fifc_preview_file
    │
    ├─→ _fifc_preview_file execution:
    │   ├─ Detect file type (txt, json, image, etc.)
    │   ├─ For text files:
    │   │   ├─ Check if bat available
    │   │   ├─ bat --color=always src/main.fish
    │   │   └─ Display syntax-highlighted preview
    │   └─ Output sent to fzf preview pane
    │
    └─→ User sees file contents in preview
```

### Phase 5: Selection & Insertion
```
User presses Tab (or custom fifc_keybinding)
    │
    ├─→ fzf captures selection
    │   └─ selected = "src/main.fish"
    │
    ├─→ fzf sends to _fifc.fish (replacement mode)
    │   └─ stdin: src/main.fish
    │
    ├─→ Post-processing:
    │   ├─ Escape special characters
    │   │   └─ Paths with spaces: "file name.txt" → "file\\ name.txt"
    │   ├─ Apply extraction regex (if any)
    │   ├─ Add trailing space (for non-directories)
    │
    ├─→ Replace current token
    │   └─ commandline --replace --current-token -- "src/main.fish "
    │
    └─→ Completion finished
        └─ User can press Enter to execute command
```

## Rule Evaluation Engine (_fifc_action)

### Input Parameters
```fish
_fifc_action <action> <candidate> [query]

# Example calls:
_fifc_action source                           # No args, use current context
_fifc_action preview "src/main.fish" "main"  # With candidate and query
_fifc_action open "src/main.fish" "main"     # For open action
```

### Execution Algorithm

```
Input: action, candidate
Output: command or output

1. Initialize context variables:
   ├─ fifc_candidate = argv[2]
   ├─ fifc_desc = extract description from completion list
   ├─ fifc_extracted = apply extraction regex to candidate

2. For each rule in _fifc_ordered_comp + _fifc_unordered_comp:
   │
   ├─ Evaluate condition:
   │  ├─ If condition specified: eval condition command
   │  └─ If no condition: condition = true
   │
   ├─ Evaluate regex:
   │  ├─ If regex specified: string match --regex -- regex "$fifc_commandline"
   │  └─ If no regex: regex = true
   │
   ├─ If condition AND regex match:
   │  │
   │  ├─ If action = "source":
   │  │  ├─ Set _fifc_custom_fzf_opts from rule
   │  │  ├─ Execute or echo source command
   │  │  └─ RETURN (source found, stop)
   │  │
   │  ├─ If action = "preview":
   │  │  ├─ Set default_preview = 0 (override default)
   │  │  ├─ Execute preview command
   │  │  └─ RETURN (preview found, stop)
   │  │
   │  └─ If action = "open":
   │     ├─ Execute open command
   │     └─ RETURN (open found, stop)
   │
   └─ If no match, continue to next rule

3. Fallback (if no rule matched):
   ├─ If action = "source": echo _fifc_parse_complist
   ├─ If action = "preview": echo "$fifc_desc"
   └─ If action = "open": do nothing
```

### Rule Precedence

Rules are evaluated in this order:

1. **Ordered Rules** (with `-O` flag): Ordered by priority number (lowest first)
   ```fish
   fifc -O 1 ...   # Evaluated first
   fifc -O 2 ...   # Evaluated second
   ```

2. **Unordered Rules** (no `-O` flag): In definition order
   ```fish
   fifc ... # User rule 1 (evaluated before builtin)
   fifc ... # User rule 2
   ```

3. **Default Fallback**: If no rule matches
   - Source: return parsed completion list
   - Preview: return Fish description
   - Open: do nothing

**Important**: First matching rule wins, remaining rules are not evaluated.

## Context Variables & Scope

### Variable Lifecycle

```
Tab pressed
    ↓
_fifc starts
    ├─ Export: fifc_commandline, fifc_token, fifc_group
    │   (available to all called functions)
    │
    ├─ Call _fifc_action source
    │   └─ Export: _fifc_custom_fzf_opts (for fzf)
    │
    ├─ fzf preview callback triggered
    │   └─ Call _fifc_action preview
    │       └─ Export: fifc_candidate, fifc_extracted, fifc_query
    │
    └─ Completion ends
        └─ Cleanup: -e all exported variables
```

### Variable Scope Rules

```fish
# Private - internal use only
_fifc_comp_count              # (global)
_fifc_complist_path           # (global, temp file)
_fifc_launched_by_fzf         # (global, signals fzf context)

# Public - user-configurable
fifc_keybinding               # (user variable)
fifc_case_insensitive         # (user variable)
fifc_editor                   # (user variable)

# Context - exposed to rules
fifc_candidate                # (exported during preview/open)
fifc_commandline              # (exported during completion)
fifc_token                    # (exported during completion)
fifc_group                    # (exported during completion)
fifc_extracted                # (exported if extraction rule used)
fifc_query                    # (exported during preview)
```

### Variable Cleanup

```fish
function _fifc
    # ... execution ...

    # Cleanup section
    set -e _fifc_extract_regex
    set -e _fifc_custom_fzf_opts
    set -e _fifc_complist_path
    set -e fifc_token
    set -e fifc_group
    set -e fifc_extracted
    set -e fifc_candidate
    set -e fifc_commandline
    set -e fifc_query
end
```

**Purpose**: Prevent pollution of global namespace, ensure clean state for next completion.

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
