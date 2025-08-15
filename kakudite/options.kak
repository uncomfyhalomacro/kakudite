evaluate-commands %sh{
    theme_mode="$(gsettings get org.gnome.desktop.interface color-scheme)"
    if [ "$theme_mode" = "'prefer-light'" ]
    then
        printf "%s\n" "colorscheme gruvbox-light"
    else
        printf "%s\n" "colorscheme gruvbox-light"
    fi
}

set-option global ui_options terminal_assistant=cat \
    terminal_status_on_top=false terminal_set_title=false \
    terminal_padding_fill=false terminal_info_max_width=0 \
    terminal_enable_mouse=true terminal_synchronized=no

set-option global startup_info_version 20250603
set-option global indentwidth 0


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

hook global WinSetOption filetype=(c|cpp|hare|go) %{
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
    add-highlighter -override buffer/ number-lines -relative -min-digits 6
    hook buffer ModeChange (push|pop):.*:insert %{
        set-face buffer   PrimarySelection default,rgb:ebdbb2,rgb:fbf1c7+Bu
        set-face buffer SecondarySelection black,bright-yellow,green+biF
        set-face buffer      PrimaryCursor default,rgb:bdae93,rgb:b57614+Bu
        set-face buffer    SecondaryCursor black,bright-yellow,green+F
        set-face buffer    PrimaryCursorEol default,rgb:bdae93,rgb:b57614+Bu
        set-face buffer SecondaryCursorEol black,bright-yellow,bright-green+F
        remove-highlighter buffer/number-lines_-relative_-min-digits_6
        add-highlighter -override buffer/ number-lines -min-digits 6
    }

    # Undo colour changes when we leave insert mode.
    hook buffer ModeChange (push|pop):insert:.* %{
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

# Gruvbox light
# TODO: make this programmable with three themes
declare-option str gray         "rgb:928374"
declare-option str red          "rgb:9d0006"
declare-option str green        "rgb:79740e"
declare-option str yellow       "rgb:b57614"
declare-option str blue         "rgb:876678"
declare-option str purple       "rgb:8f3f71"
declare-option str aqua         "rgb:427b58"
declare-option str orange       "rgb:af3a03"
declare-option str bg           "rgb:fbf1c7"
declare-option str bg_alpha     "rgba:fbf1c7a0"
declare-option str bg1          "rgb:ebdbb2"
declare-option str bg2          "rgb:d5c4a1"
declare-option str bg3          "rgb:bdae93"
declare-option str bg4          "rgb:a89984"
declare-option str fg           "rgb:3c3836"
declare-option str fg_alpha     "rgba:3c3836a0"
declare-option str fg0          "rgb:282828"
declare-option str fg2          "rgb:504945"
declare-option str fg3          "rgb:665c54"
declare-option str fg4          "rgb:7c6f64"

# Status line
set-face global BufferList     "%opt{bg},%opt{green}"
set-face global DateTime       "%opt{bg},%opt{blue}"
set-face global StatusLine     "%opt{fg},%opt{bg}"
set-face global GitBranch      "%opt{bg},%opt{yellow}"
set-face global GitModified    "%opt{bg},%opt{green}"
set-face global BlackOnWhiteBg "%opt{bg},%opt{fg}"

set-option global modelinefmt \
'%val{client}@[%val{session}]%opt{lsp_modeline_message_requests} LSP: %opt{lsp_modeline_progress} E: %opt{lsp_diagnostic_error_count} W: %opt{lsp_diagnostic_warning_count} {BufferList}U+%sh{printf "%04x" "$kak_cursor_char_value"}{StatusLine} %sh{printf "󱫉->%s" $(printf %s\\n $kak_buflist |wc -w) }{StatusLine} {{context_info}} {{mode_info}} %val{bufname} %val{cursor_line}:%val{cursor_char_column} {BlackOnWhiteBg}[%opt{filetype}]'

