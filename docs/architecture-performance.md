# Architecture: Performance & Error Handling

## Performance Optimization

### Optimization Strategies

1. **Lazy Loading**: Preview rules only loaded when fzf launched
   ```fish
   if set -q _fifc_launched_by_fzf
       # Register preview rules only inside fzf
   end
   ```

2. **Completion Caching**: Fish completions stored in temp file
   ```fish
   complete -C -- "$fifc_commandline" > $_fifc_complist_path
   # Reused by _fifc_action for descriptions
   ```

3. **Rule Evaluation Short-Circuit**: Stop after first match
   ```fish
   if rule_matches
       execute_action
       break  # Don't evaluate remaining rules
   end
   ```

4. **Tool Availability Caching**: Check tool existence once
   ```fish
   if type -q tool
       # Cache in builtin completion, not per-invocation
   end
   ```

### Performance Bottlenecks

| Bottleneck | Cause | Mitigation |
|------------|-------|-----------|
| fzf launch | Source generation | Use fast tools (fd, ripgrep) |
| Preview rendering | Slow tool execution | Timeout handling, async preview |
| Large completions | Many items to display | Use fzf multi/filter performance |
| Temp file I/O | Completion list persistence | Keep temp file small, clean up |

## Error Handling Strategy

### Error Categories

1. **Missing Tools**: Graceful fallback to alternatives
2. **Invalid Paths**: Check existence before operations
3. **Timeout**: Long-running preview should complete or timeout
4. **Permission Denied**: Check readability before preview
5. **Signal Interruption**: fzf Ctrl-C should clean up state

### Error Handling Patterns

```fish
# Tool availability
if type -q tool
    tool $args
else
    fallback_tool $args
end

# Path validation
if test -f "$path"
    process_file "$path"
else if test -d "$path"
    process_dir "$path"
else
    echo "Path does not exist: $path" >&2
    return 1
end

# Command status
if command_name
    # success
else
    echo "error: command failed" >&2
    return 1
end
```

## State Management

### Session State

During a single completion session:

```
1. _fifc starts → Initialize context variables
2. User interacts with fzf → Variables persist
3. User selects item → Variables available to open handler
4. Completion ends → Clean up all variables
```

## Extension Points

Users can extend fifc via:

1. **Custom Rules**: Define new completion behaviors
   ```fish
   fifc -n 'my_condition' -s 'my_source' -p 'my_preview'
   ```

2. **Custom Handlers**: Create preview/open/source functions
   ```fish
   function _fifc_preview_custom
       # Custom preview logic
   end
   ```

3. **Configuration Variables**: Control behavior
   ```fish
   set -U fifc_show_hidden true
   set -U fifc_bat_opts --style=numbers
   ```

4. **Tool Configuration**: Pass options to external tools
   ```fish
   set -U fifc_fd_opts --max-depth 3 --exclude .git
   ```

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
**Architecture Pattern**: Pipeline + Rule Engine
**Complexity**: Moderate (clear separation of concerns)
