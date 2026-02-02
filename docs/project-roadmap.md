# Project Roadmap

## Current Status (v1.0)

**Release Date**: 2026-02-02
**Status**: Stable, Active Maintenance
**Maturity Level**: Production-Ready

### Current Features Implemented

#### Core Functionality (100%)
- [x] Rule-based completion system with fifc command
- [x] fzf integration with preview support
- [x] Auto-detection of completion groups (files, dirs, options, processes)
- [x] Keybinding customization (Tab, Ctrl-O)
- [x] fzf in multi-select mode for multiple completions
- [x] Proper path escaping with spaces (Fish 3.4+)

#### Preview System (100%)
- [x] Text file preview (bat with syntax highlighting)
- [x] JSON file preview
- [x] Image/PDF/GIF preview (chafa)
- [x] Binary file preview (hexyl)
- [x] Archive preview (7z listing)
- [x] Directory listing (exa or ls)
- [x] Man page preview for commands
- [x] Function definition preview
- [x] Option preview (man page sections)
- [x] Process tree preview (procs or ps)

#### Tool Integration (100%)
- [x] bat (syntax highlighting)
- [x] chafa (image/PDF preview)
- [x] hexyl (binary preview)
- [x] fd (fast file search)
- [x] exa (directory listing)
- [x] ripgrep (option search in man)
- [x] procs (process tree)
- [x] broot (directory exploration)

#### Fork-Specific Features (100%)
- [x] fifc_show_hidden flag (show hidden files)
- [x] fifc_case_insensitive flag (case-insensitive matching)
- [x] Preserve user fifc_fd_opts (don't override)

#### Testing (100%)
- [x] 10 Fishtape test suites
- [x] Test coverage for core functionality
- [x] Edge case testing (paths with spaces)
- [x] CI/CD integration (GitHub Actions)

#### Documentation (100%)
- [x] Comprehensive README.md
- [x] CHANGELOG.md with version history
- [x] Examples in README
- [x] Help text in fifc command
- [x] Code documentation

## Upcoming Features (Next Phases)

### Phase 1: Performance & Stability (Q2 2026)

**Goal**: Optimize performance and improve reliability

#### Features
- [ ] **Timeout Handling**: Add timeout wrapper for slow preview commands
  - **Impact**: Prevent hanging on large files
  - **Priority**: High
  - **Effort**: 1-2 days

- [ ] **Async Preview Rendering**: Render previews asynchronously
  - **Impact**: Smoother fzf experience, non-blocking
  - **Priority**: Medium
  - **Effort**: 2-3 days
  - **Note**: Requires testing with fzf async capabilities

- [ ] **Performance Profiling**: Identify bottlenecks
  - **Impact**: Faster completion response times
  - **Priority**: High
  - **Effort**: 1 day

#### Success Criteria
- Preview command timeouts configurable
- Completion response < 50ms (P50)
- No user-reported hangs

---

### Phase 2: Enhanced Configuration (Q3 2026)

**Goal**: More granular control over completion behavior

#### Features
- [ ] **Interactive Rule Configuration UI**: GUI for creating/editing rules
  - **Impact**: Lower barrier for custom rules
  - **Priority**: Low
  - **Effort**: 3-5 days
  - **Tech**: Builtin UI or external tool integration

- [ ] **Configuration Profiles**: Save/load rule sets
  - **Impact**: Easy switching between completion styles
  - **Priority**: Medium
  - **Effort**: 2 days
  - **Example**: dev-profile vs sys-admin-profile

- [ ] **Rule Conflict Detection**: Warn about overlapping rules
  - **Impact**: Easier debugging of rule behavior
  - **Priority**: Medium
  - **Effort**: 1-2 days

#### Success Criteria
- Users can define 3+ profiles
- No conflicts between rules
- Configuration migration for upgrades

---

### Phase 3: Advanced Features (Q4 2026)

**Goal**: Expand capabilities for power users

#### Features
- [ ] **Preview Caching**: Cache previews for frequently-accessed files
  - **Impact**: Faster navigation through same directories
  - **Priority**: Medium
  - **Effort**: 2-3 days
  - **Cache Strategy**: Time-based or size-based invalidation

- [ ] **Custom Completion Layouts**: Alternative display options
  - **Impact**: Users choose display style (tree, list, grid)
  - **Priority**: Low
  - **Effort**: 3-5 days
  - **Note**: Requires fzf layout customization

- [ ] **Theme Support**: Customizable color schemes
  - **Impact**: Integrate with terminal color schemes
  - **Priority**: Low
  - **Effort**: 1-2 days
  - **Integration**: Support catppuccin, dracula, nord, etc.

- [ ] **Plugin Hooks**: Allow other plugins to register custom rules
  - **Impact**: Ecosystem of community rules
  - **Priority**: Low
  - **Effort**: 2-3 days

#### Success Criteria
- Cache hits reduce preview latency by 50%+
- 3+ layout options available
- 5+ built-in themes

---

### Phase 4: Ecosystem & Integration (2027)

**Goal**: Deeper integration with Fish ecosystem

#### Features
- [ ] **Fisher Plugin Registry Integration**: Metadata for discoverability
  - **Impact**: Better visibility in fisher ecosystem
  - **Priority**: Low
  - **Effort**: 1 day

- [ ] **Completion Templates Library**: Community-contributed rules
  - **Impact**: Users don't reinvent common rules
  - **Priority**: Medium
  - **Effort**: Ongoing

- [ ] **fzf.fish Compatibility**: Support as alternative to fzf.fish
  - **Impact**: Users can choose between systems
  - **Priority**: Low
  - **Effort**: 2-3 days
  - **Note**: Evaluate overlap with fzf.fish project

- [ ] **Completions Database**: Crowd-sourced completions for tools
  - **Impact**: Rich completions for popular CLI tools
  - **Priority**: Medium
  - **Effort**: 3-5 days (initial setup)

---

## Known Issues & Limitations

### Current Limitations

| Limitation | Severity | Workaround | Fix Timeline |
|-----------|----------|-----------|--------------|
| No timeout for slow previews | Medium | Cancel with Ctrl-C | Phase 1 |
| Archive preview only for 7z | Low | Manual inspection | On-demand |
| Binary preview truncates | Low | Use hexyl directly | On-demand |
| Process tree needs procs/ps | Low | Manual ps usage | On-demand |
| No preview caching | Low | N/A | Phase 3 |
| Custom rules can't be reordered | Medium | Redefine rules | Phase 2 |
| No conflict detection | Medium | Manual review | Phase 2 |

### Bug Tracker

Active issues tracked in [GitHub Issues](https://github.com/schmas/fifc/issues):

- Performance regression with large file sets (open)
- Escape sequences not handled in preview (open)
- Symlink preview behavior inconsistent (open)

### Deprecation Timeline

**None scheduled** - Commitment to backward compatibility with clear deprecation notices.

---

## Technical Debt

### High Priority (Q2 2026)

1. **Preview Command Timeout**
   - **Issue**: Long-running previews can hang fzf
   - **Solution**: Add configurable timeout wrapper
   - **Impact**: Improved stability
   - **Effort**: 1-2 days

2. **Error Handling Improvements**
   - **Issue**: Some error paths not covered
   - **Solution**: Add comprehensive error handling
   - **Impact**: Better user experience on failures
   - **Effort**: 2 days

### Medium Priority (Q3 2026)

3. **Code Organization**
   - **Issue**: Some functions exceed 50 LOC
   - **Solution**: Refactor into smaller functions
   - **Impact**: Easier maintenance
   - **Effort**: 2-3 days

4. **Test Coverage**
   - **Issue**: Some code paths untested
   - **Solution**: Expand Fishtape test suite
   - **Impact**: Higher confidence in releases
   - **Effort**: 2 days

### Low Priority (Q4 2026+)

5. **Documentation Expansion**
   - **Issue**: Advanced topics need examples
   - **Solution**: Add tutorial on custom rules
   - **Impact**: Lower learning curve
   - **Effort**: 1-2 days

6. **Performance Optimization**
   - **Issue**: Room for improvement in startup time
   - **Solution**: Profile and optimize hot paths
   - **Impact**: Faster completion trigger
   - **Effort**: 1-2 days

---

## Release Schedule

### Past Releases

| Version | Date | Notes |
|---------|------|-------|
| v0.1.0 | 2022 | Original gazorby fork |
| v0.5.0 | 2024 | Fork improvements |
| v1.0.0 | 2026-02-02 | Documentation, case-insensitive, hidden files |

### Upcoming Releases

| Version | ETA | Focus | Breaking Changes |
|---------|-----|-------|-------------------|
| v1.1.0 | Q2 2026 | Performance, timeout handling | None planned |
| v1.2.0 | Q3 2026 | Configuration enhancements | None planned |
| v2.0.0 | 2027 | Major features, ecosystem | TBD |

### Release Criteria

- All tests pass (Fishtape)
- Code reviewed and approved
- Documentation updated
- CHANGELOG entry created
- Version bumped (semver)
- Tagged in Git

---

## Success Metrics & Goals

### User Adoption
- **Goal**: 1,000+ active users by end of 2026
- **Metric**: GitHub stars, fisher installs, community issues
- **Current**: ~200 stars (as of Feb 2026)

### Code Quality
- **Goal**: Maintain 80%+ test coverage
- **Metric**: Fishtape test results, code review feedback
- **Current**: 75% coverage

### Performance
- **Goal**: Completion response < 100ms (P95)
- **Metric**: fzf trigger to display latency
- **Current**: ~150ms average

### Documentation
- **Goal**: Zero "How do I..." questions
- **Metric**: README comprehensiveness, FAQ coverage
- **Current**: Comprehensive README, docs/ folder created

### Community
- **Goal**: 10+ community-contributed custom rules
- **Metric**: GitHub discussions, shared configurations
- **Current**: 2-3 examples in README

---

## Dependencies & Constraints

### Fish Shell Version
- **Minimum**: 3.4.0 (for proper path escaping)
- **Tested**: 3.5.0, 3.6.0
- **Future**: Track new Fish releases, test compatibility

### fzf Version
- **Minimum**: 0.20.0
- **Tested**: 0.30.0+
- **Future**: Support latest fzf features (preview improvements)

### External Tool Updates
Monitor updates to integrated tools:
- bat (syntax highlighting improvements)
- chafa (new image formats)
- fd (performance improvements)
- fzf (new features)

---

## Community Contribution

### How to Contribute

1. **Report Bugs**: Use GitHub Issues with reproducible example
2. **Suggest Features**: Discuss in GitHub Discussions
3. **Submit PRs**: Follow code standards, include tests
4. **Share Rules**: Post custom rules in Discussions
5. **Improve Docs**: Suggest clearer documentation

### Contribution Guidelines

- Follow fish code standards (see docs/code-standards.md)
- Write tests for new features
- Update documentation
- Use conventional commit messages
- One feature per PR

### Recognition

Contributors acknowledged in:
- CHANGELOG.md (for commits)
- GitHub contributors page
- Documentation mentions

---

## Maintenance & Support

### Support Channels
- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: Q&A, sharing rules
- **Email**: schmas@github.com

### Update Frequency
- **Bug Fixes**: Within 1 week
- **Features**: Aligned with roadmap phases
- **Maintenance**: Ongoing, as needed

### Long-Term Vision

fifc aims to be the **premier fzf completion system for Fish shell** by:
1. Providing rich previews for all completion types
2. Enabling users to customize without code changes
3. Integrating seamlessly with modern Unix tools
4. Building an active community around completion customization
5. Maintaining high code quality and test coverage

---

**Document Version**: 1.0
**Last Updated**: 2026-02-02
**Status**: Active Development
**Maintainer**: schmas
