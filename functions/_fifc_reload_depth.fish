function _fifc_reload_depth -d "Reload file/directory listing at specific depth"
    set -l depth $argv[1]
    set -l type_flag $argv[2]

    set -l path (_fifc_path_to_complete | string escape)
    set -l hidden (string match "*." "$path")

    # Determine hidden flag
    set -l hidden_flag
    if set -q fifc_show_hidden; and test "$fifc_show_hidden" = true
        set hidden_flag --hidden
    else if test -n "$hidden"; or test "$path" = "."
        set hidden_flag --hidden
    end

    if type -q fd
        set -l fd_cmd (command -v fdfind || command -v fd)
        set -l fd_custom_opts
        if _fifc_test_version ($fd_cmd --version) -ge "8.3.0"
            set fd_custom_opts --strip-cwd-prefix
        end

        set -l type_opt
        if test -n "$type_flag"
            set type_opt -t $type_flag
        end

        if test "$path" = {$PWD}/; or test "$path" = "."
            $fd_cmd . $fifc_fd_opts $type_opt --max-depth $depth \
                --color=always $hidden_flag $fd_custom_opts
        else
            $fd_cmd . $fifc_fd_opts $type_opt --max-depth $depth \
                --color=always $hidden_flag -- $path
        end
    else
        set -l find_type_opt
        if test "$type_flag" = d
            set find_type_opt -type d
        end

        if set -q fifc_show_hidden; and test "$fifc_show_hidden" = true
            find . $path -maxdepth $depth $fifc_find_opts $find_type_opt \
                ! -path . -print 2>/dev/null | sed 's|^\./||'
        else if test -n "$hidden"
            find . $path -maxdepth $depth $fifc_find_opts $find_type_opt \
                ! -path . -print 2>/dev/null | sed 's|^\./||'
        else
            find . $path -maxdepth $depth $fifc_find_opts $find_type_opt \
                ! -path . ! -path '*/.*' -print 2>/dev/null | sed 's|^\./||'
        end
    end
end
