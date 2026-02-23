function _fifc_depth_transform -d "Emit fzf actions to change depth level"
    set -l delta $argv[1]
    set -l type $argv[2]

    # Parse current depth from FZF_PROMPT (format: "d:N> ")
    set -l current_depth 1
    if set -q FZF_PROMPT
        set -l parsed (string match --regex --groups-only '(\d+)' -- "$FZF_PROMPT")
        if test -n "$parsed"
            set current_depth $parsed
        end
    end

    # Compute new depth (minimum 1)
    set -l new_depth (math "max(1, $current_depth + $delta)")

    # Emit fzf actions: update prompt + reload with new depth
    if test -n "$type"
        echo "change-prompt(d:$new_depth> )+reload(_fifc_reload_depth $new_depth $type)"
    else
        echo "change-prompt(d:$new_depth> )+reload(_fifc_reload_depth $new_depth)"
    end
end
