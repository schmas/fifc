# Code Standards: Fish Shell Conventions

## File Organization

### Function Files
- **One function per file** (fifc convention)
- **File naming**: `_fifc_<action>_<type>.fish` for handlers
  - Examples: `_fifc_preview_file.fish`, `_fifc_open_dir.fish`
- **Function naming**: Match filename (without .fish extension)
- **Max file size**: Keep under 100 LOC for readability

### Helper Functions
- **File naming**: `_fifc_<utility>.fish`
  - Examples: `_fifc_parse_pid.fish`, `_fifc_file_type.fish`
- **Convention**: Underscore prefix indicates internal/private function
- **Scope**: Use local scope (`-l`) for temporary variables

### Configuration Files
- **conf.d/fifc.fish**: Plugin initialization and rule registration
- **completions/fifc.fish**: Tab completion for fifc command
- **functions/fifc.fish**: Public user-facing rule definition command

## Function Declaration

```fish
function function_name -d "Description for help text"
    # Implementation
end
```

**Standards**:
- Always include `-d` documentation string
- Use clear, imperative descriptions
- Include parameters and return value info in comments if complex

## Variable Naming

### Public Configuration Variables
```fish
fifc_<feature>          # User-configurable options
# Examples: fifc_keybinding, fifc_show_hidden, fifc_case_insensitive
```

### Private/Internal Variables
```fish
_fifc_<feature>         # Internal plugin state
# Examples: _fifc_comp_count, _fifc_complist_path
```

### Local/Temporary Variables
```fish
set -l variable_name    # Function-local scope
set -lx export_var      # Local but exported to subshells
```

### Global Accessible Variables
```fish
set -gx variable_name   # Global and exported
```

## Scope Management

```fish
function my_function
    # Local variable - cleaned up when function exits
    set -l temp_file (mktemp)

    # Don't use global scope unless necessary
    set -g cached_value

    # Export only when calling external commands
    set -lx SOME_ENV_VAR "value"

    # Cleanup before return
    rm $temp_file
    set -e cached_value
end
```

**Best Practices**:
1. Default to `-l` (local) scope
2. Export (`-x`) only for subshell/external command access
3. Minimize global state to reduce side effects
4. Always clean up temporary files and variables
5. Use `-e` to erase variables in cleanup sections

## String Handling

### Quoting Rules
```fish
# Double quotes - allow variable expansion
set cmd "echo $variable"

# Single quotes - literal string (no expansion)
set pattern '^some_regex'

# No quotes - word splitting occurs (use carefully)
set -l parts $string_with_spaces  # Splits into array
```

### Variable Expansion
```fish
# Safe expansion in command position
if test -n "$variable"
    echo $variable
end

# Use quotes when passing to commands
echo "prefix $variable suffix"

# For paths with spaces - always quote
bat "$fifc_candidate"
```

### String Operations
```fish
# Trimming
string trim --chars '\n ' -- "$text"

# Matching and extraction
string match --regex --groups-only -- 'pattern' "$text"

# Replacement
string replace --all 'old' 'new' "$text"

# Splitting
string split '\t' "$line"
```

## Control Flow

### Conditionals
```fish
# Test command status
if test -f "$file_path"
    echo "File exists"
else if test -d "$file_path"
    echo "Directory exists"
else
    echo "Path does not exist"
end

# Logical operators
if test -n "$var1"; and test -z "$var2"
    echo "var1 set and var2 empty"
end

# Regex matching
if string match --quiet --regex '^pattern' "$text"
    echo "Matched"
end
```

### Loops
```fish
# Iterate over array
for item in $array
    echo $item
end

# Iterate with index
for i in (seq (count $array))
    echo "$i: $array[$i]"
end

# Iterate over command output
for line in (command)
    # Process line
end
```

### Switch Statements
```fish
switch $variable
    case value1
        echo "First case"
    case value2 value3
        echo "Second or third"
    case '*'
        echo "Default case"
end
```

## Error Handling

### Exit Status Checking
```fish
function critical_operation
    if not important_command
        echo "error: operation failed" >&2
        return 1
    end
    echo "success"
end

# Check status after calling
if critical_operation
    echo "All good"
else
    echo "Failed"
end
```

### Redirecting Output
```fish
# Discard stdout
command > /dev/null

# Discard stderr
command 2>/dev/null

# Discard both
command &> /dev/null

# Capture output
set result (command 2>&1)

# Conditional execution
command && echo "success" || echo "failure"
```

### Type Checking
```fish
# Check if command/function exists
if type -q command_name
    command_name
else
    fallback_command
end

# Check function type
if type -q -f -- function_name
    function_name
end
```

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
**Fish Version**: 3.4.0+
