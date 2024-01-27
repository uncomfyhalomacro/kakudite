declare-option -hidden completions fd_completer
set-option global completers option=fd_completer %opt{completers}

# Credits to https://zork.net/~st/jottings/Intro_to_Kakoune_completions.html
hook global InsertCompletionShow .* %{
    try %{
    evaluate-commands -draft %{
        execute-keys h <a-i>w <a-semicolon>
        set-option window fd_completer \
            "%val{cursor_line}.%val{cursor_column}+%val{selection_length}@%val{timestamp}"
    }
    evaluate-commands %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(fd | tr '[:space:]' ' ' 2>/dev/null)
        longest_length=-1
        for word in $words
        do
            if [ ${#word} -gt $longest_length ]
            then
              longest_length=${#word}
            fi
        done
        for word in $words
        do
            word_relative_length=$(($longest_length - ${#word}))
            word_relative_length=${word_relative_length/#-}
            printf "set-option -add window fd_completer \"%s||%s%*s{MenuInfo}Fd\"\n" "$word" "$word" $word_relative_length
        done
    }

    } catch %{
        set-option window fd_completer
    }
}

