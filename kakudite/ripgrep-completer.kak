hook global BufWritePre .* %{
    evaluate-commands set-option window static_words %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(rg --max-depth 1 -No --no-heading --no-filename -e '\w+' "${cwd}" | cut -d':' -f2 | uniq | tr '\n' ' ' 2>/dev/null)
        echo "${words}"
    }
}

hook global BufWritePost .* %{
    evaluate-commands set-option window static_words %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(rg --max-depth 1 -No --no-heading --no-filename -e '\w+' "${cwd}" | cut -d':' -f2 | uniq | tr '\n' ' ' 2>/dev/null)
        echo "${words}"
    }
}

hook global InsertCompletionShow .* %{
    evaluate-commands set-option window static_words %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(rg --max-depth 1 -No --no-heading --no-filename -e '\w+' "${cwd}" | cut -d':' -f2 | uniq | tr '\n' ' ' 2>/dev/null)
        echo "${words}"
    }
}
