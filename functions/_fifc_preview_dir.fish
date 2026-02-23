function _fifc_preview_dir -d "List content of the selected directory"
    if set --query fzf_preview_dir_cmd
        eval "$fzf_preview_dir_cmd '$fifc_candidate'"
    else if type -q eza
        eza -1a --color=always $fifc_exa_opts "$fifc_candidate"
    else if type -q exa
        exa -1a --color=always $fifc_exa_opts "$fifc_candidate"
    else
        command ls -A -F $fifc_ls_opts "$fifc_candidate"
    end
end
