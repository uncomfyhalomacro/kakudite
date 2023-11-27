evaluate-commands %sh{
    theme_mode="$(gsettings get org.gnome.desktop.interface color-scheme)"
    if [ "$theme_mode" = "'prefer-light'" ]
    then
        printf "%s\n" "colorscheme catppuccin_latte"
    else
        printf "%s\n" "colorscheme catppuccin_macchiato"
    fi
}

set-option global ui_options terminal_assistant=cat terminal_status_on_top=false

hook global WinSetOption filetype=.* %{
    add-highlighter buffer/ show-whitespaces
    add-highlighter buffer/ show-matching
    add-highlighter buffer/ wrap -indent -word -width 120 -marker '↝'
    add-highlighter -override buffer/ number-lines -relative -min-digits 6
    hook global ModeChange (push|pop):.*:insert %{
        set-face buffer   PrimarySelection white,green+F
        set-face buffer SecondarySelection black,green+F
        set-face buffer      PrimaryCursor black,bright-yellow+F
        set-face buffer    SecondaryCursor black,bright-green+F
        set-face buffer   PrimaryCursorEol black,bright-yellow
        set-face buffer SecondaryCursorEol black,bright-green
        add-highlighter -override buffer/ number-lines -min-digits 6
        remove-highlighter buffer/number-lines_-relative_-min-digits_6
    }


    # Undo colour changes when we leave insert mode.
    hook global ModeChange (push|pop):insert:.* %{
        unset-face buffer PrimarySelection
        unset-face buffer SecondarySelection
        unset-face buffer PrimaryCursor
        unset-face buffer SecondaryCursor
        unset-face buffer PrimaryCursorEol
        unset-face buffer SecondaryCursorEol
        add-highlighter -override buffer/ number-lines -relative -min-digits 6
        remove-highlighter buffer/number-lines_-min-digits_6
    }
}

declare-option -docstring "name of the git branch holding the current buffer" \
    str modeline_git_branch

declare-option -docstring "if the tracked file is modified or not" \
    str modeline_git_modified

hook global WinCreate .* %{
    hook window NormalIdle .* %{
        evaluate-commands %sh{
            branch=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
            if [ -n "${branch}" ]; then
                printf 'set-option window modeline_git_branch %%{%s}\n' "${branch}"
                ismodified=$(cd "$(dirname "${kak_buffile}")" && git status "$kak_buffile" --porcelain 2>/dev/null)
                if [ -n "${ismodified}" ]; then
                    printf 'set-option window modeline_git_modified %%{%s}\n' "[M]"
                    printf 'git show-diff'
                else
                    printf 'unset-option window modeline_git_modified\n'
                    printf 'git hide-diff'
                fi
            else
                printf 'unset-option window modeline_git_modified\n'
            fi
        }
    }
    evaluate-commands %sh{
        is_work_tree=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --is-inside-work-tree 2>/dev/null)
        if [ "${is_work_tree}" = 'true' ]; then
            printf 'set-option window modelinefmt %%{%s}' "{GitBranch} %opt{modeline_git_branch}{StatusLine} {GitModified}%opt{modeline_git_modified}{StatusLine} ${kak_opt_modelinefmt}"
        fi
    }
}

# Status line
set-face global    BufferList  "%opt{background},%opt{rosewater}"
set-face global    DateTime    "%opt{background},%opt{cyan}"
set-face global    StatusLine  "%opt{foreground},%opt{background}"
set-face global    GitBranch   "%opt{background},%opt{mauve}"
set-face global    GitModified "%opt{background},%opt{teal}"
set-face global BlackOnWhiteBg "%opt{background},%opt{foreground}"

set-option global modelinefmt '%val{bufname} %val{cursor_line}:%val{cursor_char_column} {BlackOnWhiteBg}[%opt{filetype}]{StatusLine} {{context_info}} {{mode_info}} - %val{client}@[%val{session}]%opt{lsp_modeline_message_requests} %opt{lsp_modeline_progress} {BufferList}U+%sh{printf "%04x" "$kak_cursor_char_value"}{StatusLine} {BlackOnWhiteBg}%sh{printf "﬘->%s"  $(printf %s\\n $kak_buflist |wc -w) }{StatusLine} {DateTime}%sh{ date "+%Y-%m-%d %T"}'

