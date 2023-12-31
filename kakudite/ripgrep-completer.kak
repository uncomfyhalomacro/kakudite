declare-option -hidden completions rg_completions

set-option global completers option=rg_completions %opt{completers}

hook global BufNewFile .* %{
    set-option window rg_completions \
        "%val{cursor_line}.%val{cursor_column}+%val{selection_length}@%val{timestamp}"
    evaluate-commands %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words="$(rg --max-depth 2 -No --no-heading --no-filename -e '\w+' $cwd | cut -d':' -f2 | uniq | tr '\n' ' ' 2>/dev/null)"
        for word in $words
        do
            echo "set-option -add window rg_completions '$word||$word {MenuInfo}RipGrep'"
        done
    }
}

hook global BufCreate .* %{
    set-option window rg_completions \
        "%val{cursor_line}.%val{cursor_column}+%val{selection_length}@%val{timestamp}"
    evaluate-commands %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words="$(rg --max-depth 2 -No --no-heading --no-filename -e '\w+' $cwd | cut -d':' -f2 | uniq | tr '\n' ' ' 2>/dev/null)"
        for word in $words
        do
            echo "set-option -add window rg_completions '$word||$word {MenuInfo}RipGrep'"
        done
    }
}

hook global BufWritePost .* %{
    set-option window rg_completions \
        "%val{cursor_line}.%val{cursor_column}+%val{selection_length}@%val{timestamp}"
    evaluate-commands %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words="$(rg --max-depth 2 -No --no-heading --no-filename -e '\w+' $cwd | cut -d':' -f2 | uniq | tr '\n' ' ' 2>/dev/null)"
        for word in $words
        do
            echo "set-option -add window rg_completions '$word||$word {MenuInfo}RipGrep'"
        done
    }
}

hook global BufWritePre .* %{
    set-option window rg_completions \
        "%val{cursor_line}.%val{cursor_column}+%val{selection_length}@%val{timestamp}"
    evaluate-commands %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        words="$(rg --max-depth 2 -No --no-heading --no-filename -e '\w+' $cwd | cut -d':' -f2 | uniq | tr '\n' ' ' 2>/dev/null)"
        for word in $words
        do
            echo "set-option -add window rg_completions '$word||$word {MenuInfo}RipGrep'"
        done
    }
}
