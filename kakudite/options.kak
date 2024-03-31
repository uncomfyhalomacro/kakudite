evaluate-commands %sh{
    theme_mode="$(gsettings get org.gnome.desktop.interface color-scheme)"
    if [ "$theme_mode" = "'prefer-light'" ]
    then
        printf "%s\n" "colorscheme gruvbox-light"
    else
        printf "%s\n" "colorscheme gruvbox-dark"
    fi
}

set-option global ui_options terminal_assistant=cat \
    terminal_status_on_top=false terminal_set_title=false \
    terminal_padding_fill=true terminal_info_max_width=0 \
    terminal_enable_mouse=false terminal_synchronized=false

hook global WinSetOption filetype=rust %{
        add-highlighter window/ regex '//\h*(TODO:?|FIXME:?)[^\n]*'                0:yellow       1:rgb:000000,yellow
        add-highlighter window/ regex '//\h*(BUG:?|DEBUG:?)[^\n]*'                 0:red          1:rgb:000000,red
        add-highlighter window/ regex '//\h*(NOTE:?|EXPLAINER:?)[^\n]*'            0:green        1:rgb:000000,green
        add-highlighter window/ regex '/\*\s*(TODO:?|FIXME:?)([^\n]*|\s+)*\*/'     0:yellow       1:rgb:000000,yellow
        add-highlighter window/ regex '/\*\s*(BUG:?|DEBUG:?)([^\n]*|\s+)*\*/'      0:red          1:rgb:000000,red
        add-highlighter window/ regex '/\*\s*(NOTE:?|EXPLAINER:?)([^\n]*|\s+)*\*/' 0:green        1:rgb:000000,green
}

hook global WinSetOption filetype=(crystal|julia|python|sh|bash) %{
        add-highlighter window/ regex '#\h*(TODO:?|FIXME:?)[^\n]*'                 0:yellow       1:rgb:000000,yellow
        add-highlighter window/ regex '#\h*(BUG:?|DEBUG:?)[^\n]*'                  0:red          1:rgb:000000,red
        add-highlighter window/ regex '#\h*(NOTE:?|EXPLAINER:?)[^\n]*'             0:green        1:rgb:000000,green
}

hook global WinSetOption filetype=(c|cpp) %{
        add-highlighter window/ regex '//\h*(TODO:?|FIXME:?)[^\n]*'                0:yellow       1:rgb:000000,yellow
        add-highlighter window/ regex '//\h*(BUG:?|DEBUG:?)[^\n]*'                 0:red          1:rgb:000000,red
        add-highlighter window/ regex '//\h*(NOTE:?|EXPLAINER:?)[^\n]*'            0:green        1:rgb:000000,green
}

hook global WinSetOption filetype=(markdown|html) %{
        add-highlighter window/ regex '<!--\h*(TODO:?|FIXME:?)[^\n]*'              0:yellow       1:rgb:000000,yellow
        add-highlighter window/ regex '<!--\h*(BUG:?|DEBUG:?)[^\n]*'               0:red          1:rgb:000000,red
        add-highlighter window/ regex '<!--\h*(NOTE:?|EXPLAINER:?)[^\n]*'          0:green        1:rgb:000000,green
}

hook global WinSetOption filetype=.* %{
    add-highlighter buffer/ show-whitespaces -tab "⋅" -lf " "
    add-highlighter buffer/ show-matching
    add-highlighter buffer/ wrap -indent -word -width 120 -marker '↝'
    add-highlighter -override buffer/ number-lines -relative -min-digits 6
    hook global ModeChange (push|pop):.*:insert %{
        set-face buffer   PrimarySelection rgb:ebdbb2,rgb:d65d0e+biF
        set-face buffer SecondarySelection black,bright-yellow,green+biF
        set-face buffer      PrimaryCursor rgb:ebdbb2,rgb:d65d0e,yellow+iuF
        set-face buffer    SecondaryCursor black,bright-yellow,green+F
        set-face buffer   PrimaryCursorEol rgb:ebdbb2,default,bright-yellow+uF
        set-face buffer SecondaryCursorEol black,bright-yellow,bright-green+F
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
            printf 'set-option window modelinefmt %%{%s}' "{GitBranch}%opt{modeline_git_branch}{StatusLine} {GitModified}%opt{modeline_git_modified}{StatusLine} ${kak_opt_modelinefmt}"
        fi
    }
}
declare-option str gray     "rgb:928374"
declare-option str red      "rgb:fb4934"
declare-option str green    "rgb:b8bb26"
declare-option str yellow   "rgb:fabd2f"
declare-option str blue     "rgb:83a598"
declare-option str purple   "rgb:d3869b"
declare-option str aqua     "rgb:8ec07c"
declare-option str orange   "rgb:fe8019"
declare-option str bg       "rgb:282828"
declare-option str bg_alpha "rgba:282828a0"
declare-option str bg1      "rgb:3c3836"
declare-option str bg2      "rgb:504945"
declare-option str bg3      "rgb:665c54"
declare-option str bg4      "rgb:7c6f64"
declare-option str fg       "rgb:fbf1c7"
declare-option str fg_alpha "rgba:fbf1c7a0"
declare-option str fg0      "rgb:fbf1c7"
declare-option str fg2      "rgb:d5c4a1"
declare-option str fg3      "rgb:bdae93"
declare-option str fg4      "rgb:a89984"

# Status line
set-face global BufferList     "%opt{bg},%opt{green}"
set-face global DateTime       "%opt{bg},%opt{blue}"
set-face global StatusLine     "%opt{fg},%opt{bg}"
set-face global GitBranch      "%opt{bg},%opt{yellow}"
set-face global GitModified    "%opt{bg},%opt{green}"
set-face global BlackOnWhiteBg "%opt{bg},%opt{fg}"

set-option global modelinefmt \
'%val{client}@[%val{session}]%opt{lsp_modeline_message_requests} LSP: %opt{lsp_modeline_progress} E: %opt{lsp_diagnostic_error_count} W: %opt{lsp_diagnostic_warning_count} {BufferList}U+%sh{printf "%04x" "$kak_cursor_char_value"}{StatusLine} {BlackOnWhiteBg}%sh{printf "󱫉->%s" $(printf %s\\n $kak_buflist |wc -w) }{StatusLine} {{context_info}} {{mode_info}} %val{bufname} %val{cursor_line}:%val{cursor_char_column} {BlackOnWhiteBg}[%opt{filetype}]'

