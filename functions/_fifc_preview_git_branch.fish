function _fifc_preview_git_branch -d "Preview git branch information"
    set -l branch $argv[1]
    
    if test -z "$branch"
        echo "No branch specified"
        return 1
    end

    # Get current branch for comparison
    set -l current_branch (git branch --show-current 2>/dev/null)
    
    # Check if branch exists locally or remotely
    set -l is_local (git show-ref --verify --quiet refs/heads/$branch; echo $status)
    set -l is_remote (git show-ref --verify --quiet refs/remotes/origin/$branch; echo $status)
    
    # Determine the ref to use
    set -l ref $branch
    if test $is_local -ne 0
        set ref "origin/$branch"
    end

    # Print branch header
    set_color --bold cyan
    echo "Branch: $branch"
    set_color normal
    echo ""

    # Check if local or remote
    if test $is_local -eq 0
        set_color green
        echo "● Local branch"
        set_color normal
    else if test $is_remote -eq 0
        set_color yellow
        echo "○ Remote branch only"
        set_color normal
    else
        set_color red
        echo "✗ Branch not found"
        set_color normal
        return 1
    end
    echo ""

    # Show last commit information
    set_color --bold
    echo "Last Commit:"
    set_color normal
    git log -1 --format="%C(yellow)%h%Creset %C(blue)%an%Creset %C(green)%ar%Creset%n%s%n" $ref 2>/dev/null
    echo ""

    # Show commit count comparison with current branch if different
    if test -n "$current_branch" -a "$branch" != "$current_branch"
        set -l counts (git rev-list --left-right --count $current_branch...$ref 2>/dev/null | string split \t)
        if test (count $counts) -eq 2
            set -l behind $counts[1]
            set -l ahead $counts[2]
            
            set_color --bold
            echo "Comparison with $current_branch:"
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

    # Show recent commits (last 5)
    set_color --bold
    echo "Recent Commits:"
    set_color normal
    git log -5 --format="%C(yellow)%h%Creset %C(green)%ar%Creset %s" $ref 2>/dev/null
end
