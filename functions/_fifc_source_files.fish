function _fifc_source_files -d "Return a command to recursively find files"
    set -l path (_fifc_path_to_complete | string escape)
    set -l hidden (string match "*." "$path")

    if string match --quiet -- '~*' "$fifc_query"
        set -e fifc_query
    end

    # Sort function: by depth (first-level first), then hidden files last within each depth
    # Strip ANSI codes for analysis but preserve them in output
    # Format: depth (3 digits) + hidden flag (0/1) + path, then numeric sort and strip prefix
    set -l sort_cmd "awk '{line=\$0; gsub(/\\033\\[[0-9;]*m/,\"\",line); d=split(line,a,\"/\"); h=0; for(i=1;i<=d;i++) if(substr(a[i],1,1)==\".\") h=1; printf \"%03d%d%s\\n\", d, h, \$0}' | sort -n | cut -c5-"

    if type -q fd
        if _fifc_test_version (fd --version) -ge "8.3.0"
            set fd_custom_opts --strip-cwd-prefix
        end

        # Add --hidden flag if user configured fifc_show_hidden or path indicates hidden
        set -l hidden_flag
        if set -q fifc_show_hidden; and test "$fifc_show_hidden" = true
            set hidden_flag --hidden
        else if test -n "$hidden"; or test "$path" = "."
            set hidden_flag --hidden
        end

        if test "$path" = {$PWD}/
            echo "fd . $fifc_fd_opts --max-depth 1 --color=always $hidden_flag $fd_custom_opts | $sort_cmd"
        else if test "$path" = "."
            echo "fd . $fifc_fd_opts --max-depth 1 --color=always $hidden_flag $fd_custom_opts | $sort_cmd"
        else if test -n "$hidden"
            echo "fd . $fifc_fd_opts --max-depth 1 --color=always $hidden_flag -- $path | $sort_cmd"
        else
            echo "fd . $fifc_fd_opts --max-depth 1 --color=always $hidden_flag -- $path | $sort_cmd"
        end
    else if test -n "$hidden"
        # Use sed to strip cwd prefix
        echo "find . $path -maxdepth 1 $fifc_find_opts ! -path . -print 2>/dev/null | sed 's|^\./||' | $sort_cmd"
    else
        # Exclude hidden directories unless fifc_show_hidden is enabled
        if set -q fifc_show_hidden; and test "$fifc_show_hidden" = true
            echo "find . $path -maxdepth 1 $fifc_find_opts ! -path . -print 2>/dev/null | sed 's|^\./||' | $sort_cmd"
        else
            echo "find . $path -maxdepth 1 $fifc_find_opts ! -path . ! -path '*/.*' -print 2>/dev/null | sed 's|^\./||'"
        end
    end
end
