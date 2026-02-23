# Private
set -gx _fifc_comp_count 0
set -gx _fifc_unordered_comp
set -gx _fifc_ordered_comp

if status is-interactive
    # Keybindings
    set -qU fifc_keybinding
    or set -U fifc_keybinding \t

    set -qU fifc_open_keybinding
    or set -U fifc_open_keybinding ctrl-o

    for mode in default insert
        bind --mode $mode \t _fifc
        bind --mode $mode $fifc_keybinding _fifc
    end

    # Build depth-control fzf options (default: depth 1)
    # Bindings: ctrl-j/k and alt-↓/↑ step depth, alt-1…9 jump directly
    set -l _base "--tiebreak=length,index --prompt='d:1> '"
    set -l _base "$_base --header='ctrl-j/k · alt-↓/↑ · alt-1…9 depth'"

    set -l _dir "$_base"
    set -l _dir "$_dir --bind='alt-down:transform(_fifc_depth_transform +1 d)'"
    set -l _dir "$_dir --bind='alt-up:transform(_fifc_depth_transform -1 d)'"
    set -l _dir "$_dir --bind='ctrl-j:transform(_fifc_depth_transform +1 d)'"
    set -l _dir "$_dir --bind='ctrl-k:transform(_fifc_depth_transform -1 d)'"
    for _n in 1 2 3 4 5 6 7 8 9
        set _dir "$_dir --bind='alt-$_n:transform(_fifc_depth_transform $_n d)'"
    end

    set -l _file "$_base"
    set -l _file "$_file --bind='alt-down:transform(_fifc_depth_transform +1)'"
    set -l _file "$_file --bind='alt-up:transform(_fifc_depth_transform -1)'"
    set -l _file "$_file --bind='ctrl-j:transform(_fifc_depth_transform +1)'"
    set -l _file "$_file --bind='ctrl-k:transform(_fifc_depth_transform -1)'"
    for _n in 1 2 3 4 5 6 7 8 9
        set _file "$_file --bind='alt-$_n:transform(_fifc_depth_transform $_n)'"
    end

    # Set source rules
    fifc \
        -n 'test "$fifc_group" = "directories"' \
        -s _fifc_source_directories \
        -f $_dir
    fifc \
        -n 'test "$fifc_group" = "files"' \
        -s _fifc_source_files \
        -f $_file
    fifc \
        -n 'test "$fifc_group" = processes' \
        -s 'ps -ax -o pid=,command='
end

# Load fifc preview rules only when fish is launched fzf
if set -q _fifc_launched_by_fzf
    # Builtin preview/open commands
    fifc \
        -n 'test "$fifc_group" = "options"' \
        -p _fifc_preview_opt \
        -o _fifc_open_opt
    fifc \
        -n 'test \( -n "$fifc_desc" -o -z "$fifc_commandline" \); and type -q -f -- "$fifc_candidate"' \
        -r '^(?!\\w+\\h+)' \
        -p _fifc_preview_cmd \
        -o _fifc_open_cmd
    fifc \
        -n 'test -n "$fifc_desc" -o -z "$fifc_commandline"' \
        -r '^(functions)?\\h+' \
        -p _fifc_preview_fn \
        -o _fifc_open_fn
    fifc \
        -n 'test -f "$fifc_candidate"' \
        -p _fifc_preview_file \
        -o _fifc_open_file
    fifc \
        -n 'test -d "$fifc_candidate"' \
        -p _fifc_preview_dir \
        -o _fifc_open_dir
    fifc \
        -n 'test "$fifc_group" = processes -a (ps -p (_fifc_parse_pid "$fifc_candidate") &>/dev/null)' \
        -p _fifc_preview_process \
        -o _fifc_open_process \
        -e '^\\h*([0-9]+)'
end

# Fisher
function _fifc_uninstall --on-event fifc_uninstall
end
