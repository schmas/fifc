function _fifc_git_branch_selector -d "Select a git branch using fzf and insert it at cursor"
    # Check if we're in a git repository
    if not git rev-parse --git-dir &>/dev/null
        echo "Not in a git repository"
        return 1
    end

    # Get all branches initially
    set -l branches (_fifc_list_git_branches all)

    if test -z "$branches"
        echo "No branches found"
        return 1
    end

    # Set up fzf options with reload bindings for filtering
    set -l fzf_opts \
        --ansi \
        --height=80% \
        --reverse \
        --no-hscroll \
        --border=rounded \
        --border-label=" Git Branches " \
        --preview="_fifc_preview_git_branch {}" \
        --preview-window=right:60%:wrap \
        --prompt="All> " \
        --header="Filter: ctrl-l (local) | ctrl-r (remote)
        ctrl-a (all)
More info: ctrl-o" \
        --bind="ctrl-l:reload(_fifc_list_git_branches local)+change-prompt(Local> )" \
        --bind="ctrl-r:reload(_fifc_list_git_branches remote)+change-prompt(Remote> )" \
        --bind="ctrl-a:reload(_fifc_list_git_branches all)+change-prompt(All> )"

    # Add keybinding for open action if configured
    if set -q fifc_open_keybinding
        set -a fzf_opts --bind="$fifc_open_keybinding:execute(_fifc_open_git_branch {} | less -R)"
    end

    # Launch fzf and get selection
    set -l selected (printf "%s\n" $branches | fzf $fzf_opts)

    # Always repaint to restore the command line
    commandline --function repaint

    # If a branch was selected, insert it at cursor position
    if test -n "$selected"
        commandline --insert -- $selected
    end
end
