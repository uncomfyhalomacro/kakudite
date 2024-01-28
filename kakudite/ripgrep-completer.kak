declare-option -hidden completions ripgrep_completer
set-option global completers option=ripgrep_completer %opt{completers}

# Credits to https://zork.net/~st/jottings/Intro_to_Kakoune_completions.html
hook global InsertCompletionShow .* %{
    try %{
    execute-keys -draft h s \A[\w-_]\z<ret>
    evaluate-commands -draft %{
        execute-keys h <a-i>w <a-semicolon>
        set-option window ripgrep_completer \
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
            printf "set-option -add window ripgrep_completer \"%s||%s%*s{MenuInfo}RipGrep\"\n" "$word" "$word" $word_relative_length
        done
    }

    } catch %{
        set-option window ripgrep_completer
    }
}

