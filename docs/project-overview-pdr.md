# Project Overview & Product Development Requirements

## Executive Summary

**fifc** (Fish FZF Completions) is a Fish shell plugin that integrates fzf (fuzzy finder) with Fish's native completion system. It provides intelligent, preview-enabled completions for files, directories, commands, options, and processes with a rule-based customization system.

## Project Vision

Enable Fish shell users to work more efficiently by providing:
1. Intelligent, searchable completions for common tasks (file navigation, command discovery)
2. Rich previews (text, images, binaries, archives, man pages, code)
3. Extensible rule-based system for custom completions
4. Seamless integration with modern Unix tools

## Target Users

- Fish shell users wanting enhanced completion experience
- Developers working frequently with CLI tools
- System administrators managing complex shell environments
- Power users seeking productivity optimizations

## Core Functional Requirements

### F1: Completion System
- Integrate with Fish's `complete` command to provide fzf-based completions
- Support completion groups: files, directories, options, processes
- Preserve original Fish completion descriptions in preview pane
- Escape paths with spaces correctly (Fish 3.4+ requirement)

### F2: Preview System
- File previews: text, code, JSON, images, PDFs, binaries, archives
- Command previews: man pages with syntax highlighting
- Function previews: Fish function definitions
- Process previews: process trees with parent relationships
- Directory previews: tree view with modern tools (exa) or fallback to ls

### F3: Rule-Based Configuration
- Users define rules with conditions (test commands or regex patterns)
- Rules bind preview, source, and open commands to completion contexts
- Ordered rule evaluation: first matching rule is used
- Built-in rules for files, directories, commands, functions, options, processes

### F4: Custom Keybindings
- Tab or custom keybinding triggers fzf completion interface
- Ctrl-O or custom keybinding opens detailed view of selected item
- User-configurable via environment variables

### F5: Tool Integration
Support optional integration with modern tools for enhanced functionality:
- **bat**: Syntax-highlighted file preview (fallback: cat)
- **chafa**: Image/PDF/GIF preview (fallback: file command)
- **hexyl**: Binary file preview (fallback: file command)
- **fd**: Fast recursive file search (fallback: find)
- **exa**: Modern directory listing (fallback: ls)
- **ripgrep**: Fast pattern matching in man pages
- **procs**: Process tree visualization (fallback: ps)
- **broot**: Interactive directory exploration

### F6: Fork-Specific Features
- **fifc_show_hidden**: Always display hidden files (dot-files)
- **fifc_case_insensitive**: Case-insensitive fzf matching for completions
- **Preserve fifc_fd_opts**: Allow custom fd options without override

## Non-Functional Requirements

### N1: Performance
- Completion response time < 100ms for typical use cases
- fzf integration should not introduce noticeable lag
- Lazy-load preview rules only when fzf is launched

### N2: Compatibility
- Minimum Fish version: 3.4.0 (for proper path escaping)
- Cross-platform support: macOS, Linux (BSD)
- No external dependencies for core functionality
- Graceful degradation when optional tools unavailable

### N3: Code Quality
- Modular Fish functions: one concern per function
- Clear function naming: `_fifc_<action>_<type>` pattern
- Comprehensive test coverage: Fishtape unit tests
- Syntax validation and format checks via CI

### N4: Reliability
- Proper error handling for missing files, commands
- Timeout handling for slow preview commands
- Signal handling for fzf interruptions
- State cleanup after each completion session

### N5: Extensibility
- Simple API for users to define custom rules
- Clear documentation of available variables in completion context
- Support for custom preview/source/open commands
- No need to modify core plugin files for customization

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Installation rate | 500+ users | GitHub stars, fisher installs |
| Test coverage | >80% | Fishtape test suite |
| Preview accuracy | 95% | Manual testing across file types |
| Performance | <100ms | fzf trigger to display response |
| Documentation quality | Complete | All functions documented, examples provided |
| User adoption | High | Issues, PRs, forks from community |

## Architecture Constraints

1. **Fish-only**: Written entirely in Fish shell, no external languages
2. **Minimal core**: fzf is the only hard dependency
3. **Stateless preview**: Preview rules should have no side effects
4. **Rule isolation**: Rules should not interfere with each other
5. **CLI utilities**: Leverage Unix philosophy of specialized tools

## Key Decisions

### Decision 1: Rule-Based System
**Why**: Allows users to customize without forking the plugin. Each rule evaluates independently with clear precedence.

### Decision 2: Lazy-Loading Preview Rules
**Why**: Reduces startup overhead. Preview rules only loaded inside fzf context to minimize Fish initialization time.

### Decision 3: Group-Based Completion Detection
**Why**: Automatically categorizes completion suggestions (files, directories, options, processes) enabling intelligent rule matching without user annotation.

### Decision 4: Optional Tool Integration
**Why**: Core functionality works without additional tools, but users can opt-in to enhanced experiences. Maintains accessibility while supporting power users.

## Known Limitations

1. Preview commands must complete in reasonable time (no timeout mechanism)
2. Archive preview limited to 7z format
3. Binary preview truncates long hexdumps
4. Process tree requires procs or ps (no pure Fish fallback)
5. Custom rules evaluated sequentially, no parallel execution

## Technical Debt & Future Improvements

1. **Timeout handling**: Add timeout wrapper for slow preview commands
2. **Plugin manager integration**: Better integration with fisher ecosystem
3. **Configuration UI**: Interactive rule configuration tool
4. **Caching**: Cache previews for frequently-accessed files
5. **Tree-based display**: Alternative completion layout options
6. **Theme support**: Customizable color schemes for previews
7. **Performance profiling**: Identify and optimize bottlenecks

## Dependencies & Ecosystem

### Hard Dependencies
- **Fish** >= 3.4.0: Shell runtime and completion system
- **fzf** >= 0.20.0: Fuzzy finder UI

### Optional Dependencies
| Tool | Purpose | Fallback |
|------|---------|----------|
| bat | Syntax highlighting | cat |
| chafa | Image preview | file command |
| hexyl | Binary preview | file command |
| fd | Fast recursive search | find |
| exa | Directory listing | ls |
| ripgrep | Pattern matching | pcregrep |
| procs | Process tree | ps |
| broot | Tree exploration | None |

## Maintenance & Support

- **License**: MIT (permissive open source)
- **Maintenance Level**: Active (bug fixes, feature development)
- **Update Frequency**: Regular updates aligned with Fish shell releases
- **CI/CD**: GitHub Actions for automated testing and validation
- **Code Review**: All changes reviewed before merge to main

## Version Strategy

- **Semantic Versioning**: MAJOR.MINOR.PATCH
- **Breaking Changes**: Clearly documented in CHANGELOG
- **Migration Guide**: Provided for version upgrades
- **Stable Releases**: Tagged in GitHub for direct installation

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
**Status**: Active Development
