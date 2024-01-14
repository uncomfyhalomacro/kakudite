hook global BufWritePre .* %{
    evaluate-commands set-option window static_words %sh{
        fd | tr '[:space:]' ' ' 2>/dev/null
    }
}

hook global BufWritePost .* %{
    evaluate-commands set-option window static_words %sh{
        fd | tr '[:space:]' ' ' 2>/dev/null
    }
}

hook global InsertCompletionShow .* %{
    evaluate-commands set-option window static_words %sh{
        fd | tr '[:space:]' ' ' 2>/dev/null
    }
}
