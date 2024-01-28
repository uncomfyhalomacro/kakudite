declare-option -hidden completions latex_symbol_completer
set-option global completers option=latex_symbol_completer %opt{completers}
\-phi
# Credits to https://zork.net/~st/jottings/Intro_to_Kakoune_completions.html
hook global InsertCompletionShow .* %{
    try %{
    # Rationale
    # We try to first get the word backward once with `b`
    # then we try to use `H` to check if there is a `\`
    # otherwise, go to the catch block
    execute-keys -draft b H s \A^\\[\w-_\^]+\z<ret> 
    evaluate-commands -draft %{
        execute-keys h <a-i>w <a-semicolon>
        set-option window latex_symbol_completer \
            "%val{cursor_line}.%val{cursor_column}+%val{selection_length}@%val{timestamp}"
    }
    evaluate-commands %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words=$(rg "[\\w_-]+" "$cwd" -d 1 --block-buffered --no-line-number --only-matching --no-filename | sort | uniq | tr '\n' ' ')
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
            printf "set-option -add window latex_symbol_completer \"%s||%s%*s{MenuInfo}RipGrep\"\n" "$word" "$word" $word_relative_length
        done
    }

    } catch %{
        set-option window latex_symbol_completer
    }
}

