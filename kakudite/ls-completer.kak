hook global BufWritePre .* %{
    evaluate-commands set-option window static_words %sh{
        words=$(fd | tr '[:space:]' ' ' 2>/dev/null)
        echo "${words}"
    }
}

hook global BufWritePost .* %{
    evaluate-commands set-option window static_words %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(fd | tr '[:space:]' ' ' 2>/dev/null)
        echo "${words}"
    }
}

hook global InsertCompletionShow .* %{
    evaluate-commands set-option window static_words %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(fd | tr '[:space:]' ' ' 2>/dev/null)
        echo "${words}"
    }
}
