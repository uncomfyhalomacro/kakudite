define-command -docstring "update-to-recentf" update-to-recentf %{ 
    nop %sh{
        if [ -f "$kak_buffile" ] && [ "$kak_buffile" != "$kak_config/recentf" ];
        then
            output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-recentf.XXXXXXXX)/tmp
            mktemp "${output}"
            cat "${kak_config}"/recentf | sort | uniq | tee "${output}"
            echo "$kak_buffile" | tee -a "${output}"
            cat "${output}" | parallel -j$(nproc) 'if [ -f "{}" ]; then echo "{}"; fi' | sort | uniq | tee "${kak_config}"/recentf
        fi 
    }
}
hook global BufOpenFile .* %{
    evaluate-commands update-to-recentf
}

hook global BufNewFile .* %{
    evaluate-commands update-to-recentf
}

hook global BufWritePost .* %{
    evaluate-commands update-to-recentf
}
