hook global BufWritePre .* %{
    evaluate-commands set-option window static_words %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(/usr/bin/ls "${cwd}" | tr '[:space:]' ' ' 2>/dev/null)
        echo "${words}"
    }
}

hook global BufWritePost .* %{
    evaluate-commands set-option window static_words %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(/usr/bin/ls "${cwd}" | tr '[:space:]' ' ' 2>/dev/null)
        echo "${words}"
    }
}

hook global InsertCompletionShow .* %{
    evaluate-commands set-option window static_words %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(/usr/bin/ls "$cwd" | tr '[:space:]' ' ' 2>/dev/null)
        echo "${words}"
    }
}
