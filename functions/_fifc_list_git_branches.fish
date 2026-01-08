function _fifc_list_git_branches -d "List git branches with optional filter"
    set -l filter $argv[1]
    
    switch $filter
        case local
            # Only local branches
            git branch --format='%(refname:short)' 2>/dev/null | sort -V
        case remote
            # Only remote branches (strip origin/ prefix)
            git branch -r --format='%(refname:short)' 2>/dev/null | \
                grep -v '^HEAD' | \
                grep -v '^origin/HEAD' | \
                sed 's/^origin\///' | \
                sort -V
        case '*'
            # All branches (default)
            git branch -a --format='%(refname:short)' 2>/dev/null | \
                grep -v '^HEAD' | \
                grep -v '^origin/HEAD' | \
                sed 's/^origin\///' | \
                sort -V -u
    end
end
