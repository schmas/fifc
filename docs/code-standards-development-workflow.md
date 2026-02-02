# Code Standards: Development Workflow

## Code Quality Standards

### Documentation Requirements

Every function must have:

```fish
function name -d "Brief description of what this does"
    # Longer comment explaining complex behavior if needed

    # Variable documentation for non-obvious logic
    set -l config_var "value"  # Used for X, see fifc.fish line N

    # Implementation
end
```

### Comments

**Good comments explain WHY, not WHAT**:

```fish
# GOOD - explains reasoning
if test "$action" = preview; and test -n "$$comp[$i][3]"
    # Stop after first matching preview rule to avoid duplicate previews
    eval $$comp[$i][3]
    set default_preview 0
    break
end

# BAD - restates code
# If action equals preview and comp has preview command
if test "$action" = preview; and test -n "$$comp[$i][3]"
```

### Code Readability

1. **Line length**: Keep under 100 characters when practical
2. **Indentation**: Use 4 spaces (not tabs)
3. **Variable naming**: Be explicit, not cryptic
4. **Function length**: Keep individual functions under 100 LOC
5. **Complexity**: Use helper functions to break down complex logic

### Performance Considerations

1. **Avoid subshells**: Use command substitution sparingly
2. **Minimize temp files**: Clean up immediately after use
3. **Lazy loading**: Load rules only when needed
4. **Caching**: Store completion list in temp file to avoid re-running `complete`
5. **Tool detection**: Cache `type -q` results instead of checking repeatedly

## Git Workflow Standards

### Commit Messages

Use conventional commit format:

```
<type>: <subject line (50 chars max)>

<body: explain what and why, not how (72 char wrap)>

<footer: reference issues, breaking changes>
```

**Types**: feat, fix, refactor, docs, test, chore, perf

**Examples**:
```
feat: add case-insensitive completion matching option

Add fifc_case_insensitive flag to enable case-insensitive fzf matching.
This is useful for cd and file completions where case sensitivity is not desired.

Fixes #123
```

### Branch Naming

```
<type>/<short-description>
# Examples:
feature/case-insensitive-matching
fix/path-with-spaces-escaping
docs/architecture-overview
```

### Code Review Checklist

Before merging, verify:

- [ ] All tests pass (Fishtape)
- [ ] Fish syntax valid (fisher lint or `fish -n`)
- [ ] Code formatted correctly (fish_indent)
- [ ] No hardcoded paths or env assumptions
- [ ] Error handling implemented
- [ ] Tool fallbacks in place for optional dependencies
- [ ] Documentation updated
- [ ] Commit messages clear and conventional
- [ ] No confidential information in code

## Development Workflow

### Setting Up Environment

```bash
# Install dependencies
brew install fish fzf bat fd exa ripgrep procs

# Clone repository
git clone https://github.com/schmas/fifc.git
cd fifc

# Run tests
fish tests/test_*.fish

# Check syntax
fish -n functions/*.fish
```

### Adding a New Feature

1. Create feature branch: `git checkout -b feature/my-feature`
2. Update `conf.d/fifc.fish` or functions as needed
3. Add unit tests in `tests/test_*.fish`
4. Update `README.md` if user-facing
5. Update `CHANGELOG.md` with breaking changes
6. Create commit with conventional message
7. Create PR with test results

### Adding a New Preview Handler

1. Create `functions/_fifc_preview_<type>.fish`
2. Implement function with tool fallback chain
3. Register in `conf.d/fifc.fish` rule
4. Add test case in `tests/test_preview_file.fish`
5. Document in README preview support table

## Common Pitfalls & Solutions

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Unquoted variables | Word splitting with spaces | Always quote: `"$var"` |
| Missing type checks | Crashes when tool unavailable | Use `type -q` before executing |
| Global state pollution | Side effects, hard to debug | Use `-l` scope by default |
| Ignoring stderr | Missing error messages | Redirect to `/dev/null` explicitly |
| Unbounded recursion | Stack overflow | Use loops instead of recursion |
| Temp file leaks | Disk space issues | Always `rm` temp files in cleanup |
| Regex without escaping | Pattern interpretation errors | Use `string escape --style=regex` |

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
**Fish Version**: 3.4.0+
