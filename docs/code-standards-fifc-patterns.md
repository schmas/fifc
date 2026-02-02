# Code Standards: fifc-Specific Patterns

## Rule Definition Pattern

```fish
fifc \
    -n 'test_command' \           # Condition (optional)
    -r 'regex_pattern' \          # Regex (optional)
    -s 'source_function' \        # Source provider
    -p 'preview_function' \       # Preview command
    -o 'open_function' \          # Open command
    -e 'extraction_regex' \       # Extract pattern (optional)
    -f '--fzf-custom-options' \   # fzf options (optional)
    -O 1                          # Order: 1 = highest priority
```

**Rules**:
- At least one of `-n` or `-r` condition
- At least one of `-s`, `-p`, `-o`, `-e`, `-f` action
- Multiple rules evaluated in order (first match wins)
- Ordered rules (with `-O`) evaluated before unordered

## Context Variables in Rules

Always available inside preview/source/open commands:

```fish
$fifc_candidate    # Selected item from completion list
$fifc_commandline  # Command buffer before cursor
$fifc_token        # Last token (completion context)
$fifc_group        # Detected group: files, directories, options, processes
$fifc_extracted    # Extraction result (if regex applied)
$fifc_query        # Initial fzf query (for custom filtering)
```

## Preview Handler Pattern

```fish
function _fifc_preview_<type>
    # Accept fifc_candidate as implicit context variable
    # (no need to explicitly receive as argument)

    if type -q preferred_tool
        preferred_tool $fifc_candidate
    else
        fallback_tool $fifc_candidate
    end
end
```

## Source Handler Pattern

```fish
function _fifc_source_<type> -d "Generate completion items"
    # Output one item per line to stdout
    # Each line format: "item<TAB>description"

    # Example: file search with fd
    fd --hidden --type f | while read -l item
        echo "$item"
    end
end
```

## Tool Integration Pattern

```fish
function _fifc_preview_something
    # Step 1: Check primary tool availability
    if type -q primary_tool
        # Step 2: Use primary tool with custom options
        primary_tool $fifc_*_opts "$fifc_candidate"
        return
    end

    # Step 3: Fallback to alternative
    if type -q fallback_tool
        fallback_tool "$fifc_candidate"
        return
    end

    # Step 4: Final fallback or error
    echo "No suitable tool available"
end
```

## Testing Standards

### Test File Structure

```fish
# Setup
set test_variable "value"
set test_dir "tests/_resources"

# Define test helper functions
function test_helper
    # Helper implementation
end

# Run tests
@test "test_name" actual_value = expected_value
@test "another test" (test_helper) = expected
```

### Test Naming Convention

```fish
@test "component: feature_being_tested" actual = expected
# Examples:
@test "file_type: detects text files" (detect_type "file.txt") = txt
@test "rule_eval: prioritizes ordered rules" (get_first_match) = expected_rule
```

### Test Coverage Areas

1. **Unit Tests**: Individual function behavior
2. **Integration Tests**: Rule evaluation + execution
3. **Edge Cases**: Paths with spaces, special chars, missing tools
4. **Performance**: Completion response time
5. **Tool Fallbacks**: Behavior when optional tools unavailable

### Running Tests

```bash
# Run all tests with Fishtape
fish tests/test_*.fish

# Run specific test file
fish tests/test_preview_file.fish

# With verbose output
fish -c "source tests/test_file_type.fish"
```

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
