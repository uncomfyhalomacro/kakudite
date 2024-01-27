define-command -docstring "update-to-recentf" update-to-recentf %{ 
    nop %sh{
        if [ -f "$kak_buffile" ] && [ "$kak_buffile" != "$kak_config/recentf" ];
        then
            output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-recentf.XXXXXXXXXXX)
            mktemp "${output}"/tmp 2>/dev/null
            cat "${kak_config}"/recentf | sort | uniq | tee "${output}"/tmp
            echo "$kak_buffile" | tee -a "${output}"/tmp
            cat "${output}"/tmp | parallel -j$(nproc) 'if [ -f "{}" ]; then echo "{}"; fi' | sort | uniq | tee "${kak_config}"/recentf
            rm -rfv "${output}"
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

define-command -docstring "clear-recentf" clear-recentf %{
    nop %sh{
        cat /dev/null | tee "${kak_config}"/recentf
    }
}
