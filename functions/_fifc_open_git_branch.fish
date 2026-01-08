function _fifc_open_git_branch -d "Show detailed git branch information"
    set -l branch $argv[1]
    
    if test -z "$branch"
        echo "No branch specified"
        return 1
    end

    # Check if branch exists locally or remotely
    set -l is_local (git show-ref --verify --quiet refs/heads/$branch; echo $status)
    set -l is_remote (git show-ref --verify --quiet refs/remotes/origin/$branch; echo $status)
    
    # Determine the ref to use
    set -l ref $branch
    if test $is_local -ne 0
        set ref "origin/$branch"
    end

    # Get current branch for comparison
    set -l current_branch (git branch --show-current 2>/dev/null)

    # Print detailed branch information
    set_color --bold cyan
    echo "═══════════════════════════════════════════════════════"
    echo "  Branch Details: $branch"
    echo "═══════════════════════════════════════════════════════"
    set_color normal
    echo ""

    # Branch type
    if test $is_local -eq 0
        set_color green
        echo "Type: Local branch"
        set_color normal
    else if test $is_remote -eq 0
        set_color yellow
        echo "Type: Remote branch only (origin/$branch)"
        set_color normal
    else
        set_color red
        echo "Type: Branch not found"
        set_color normal
        return 1
    end
    echo ""

    # Last commit
    set_color --bold
    echo "Last Commit:"
    set_color normal
    git log -1 --format="%C(yellow)commit %H%Creset%nAuthor: %C(blue)%an <%ae>%Creset%nDate:   %C(green)%ar (%ad)%Creset%n%n    %s%n" --date=format:"%Y-%m-%d %H:%M:%S" $ref 2>/dev/null
    echo ""

    # Comparison with current branch
    if test -n "$current_branch" -a "$branch" != "$current_branch"
        set -l counts (git rev-list --left-right --count $current_branch...$ref 2>/dev/null | string split \t)
        if test (count $counts) -eq 2
            set -l behind $counts[1]
            set -l ahead $counts[2]
            
            set_color --bold
            echo "Comparison with current branch ($current_branch):"
            set_color normal
            
            if test $ahead -gt 0
                set_color green
                echo "  ↑ $ahead commit(s) ahead"
                set_color normal
            end
            
            if test $behind -gt 0
                set_color red
                echo "  ↓ $behind commit(s) behind"
                set_color normal
            end
            
            if test $ahead -eq 0 -a $behind -eq 0
                set_color cyan
                echo "  ≈ Up to date"
                set_color normal
            end
            echo ""
        end
    end

    # Recent commits
    set_color --bold
    echo "Recent Commits (last 10):"
    set_color normal
    git log -10 --format="%C(yellow)%h%Creset %C(blue)%an%Creset %C(green)%ar%Creset%n    %s%n" $ref 2>/dev/null
end
