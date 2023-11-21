hook global InsertCompletionShow .* %{
    try %{
        # this command temporarily removes cursors preceded by whitespace;
        # if there are no cursors left, it raises an error, does not
        # continue to execute the mapping commands, and the error is eaten
        # by the `try` command so no warning appears.
        execute-keys -draft 'h<a-K>\h<ret>'
        map window insert <tab> <c-n>
        map window insert <s-tab> <c-p>
        hook -once -always window InsertCompletionHide .* %{
            unmap window insert <tab> <c-n>
            unmap window insert <s-tab> <c-p>
        }
    }
}

hook global WinSetOption filetype=.* %{
    add-highlighter buffer/ show-whitespaces
    add-highlighter buffer/ show-matching
    add-highlighter buffer/ wrap -indent -word -width 90 -marker '↝'
    add-highlighter -override buffer/ number-lines -relative
    hook global ModeChange (push|pop):.*:insert %{
        set-face buffer PrimarySelection white,green+F
        set-face buffer SecondarySelection black,green+F
        set-face buffer PrimaryCursor black,bright-yellow+F
        set-face buffer SecondaryCursor black,bright-green+F
        set-face buffer PrimaryCursorEol black,bright-yellow
        set-face buffer SecondaryCursorEol black,bright-green
        add-highlighter -override buffer/ number-lines
        remove-highlighter buffer/number-lines_-relative
    }


    # Undo colour changes when we leave insert mode.
    hook global ModeChange (push|pop):insert:.* %{
        unset-face buffer PrimarySelection
        unset-face buffer SecondarySelection
        unset-face buffer PrimaryCursor
        unset-face buffer SecondaryCursor
        unset-face buffer PrimaryCursorEol
        unset-face buffer SecondaryCursorEol
        add-highlighter -override buffer/ number-lines -relative
        remove-highlighter buffer/number-lines
    }
}

hook global ModuleLoaded zellij %{
    define-command -docstring 'vsplit-right (zellij): Open a new vertical split on the right relative to the active pane' vsplit-right -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "%s\n" "zellij-action new-pane -d right -- $1"
                else
                    printf "%s\n" "zellij-action new-pane -d right"
                fi
            }
    }

    define-command -docstring 'vsplit-left (zellij): Open a new vertical split on the left relative to the active pane' vsplit-left -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "%s\n" "zellij-action new-pane -d left -- $1"
                else
                    printf "%s\n" "zellij-action new-pane -d left"
                fi
            }
    }

    define-command -docstring 'split-down (zellij): Open a new vertical split on the down relative to the active pane' split-down -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "%s\n" "zellij-action new-pane -d down -- $1"
                else
                    printf "%s\n" "zellij-action new-pane -d down"
                fi
            }
    }

    define-command -docstring 'split-up (zellij): Open a new vertical split on the up relative to the active pane' split-up -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "%s\n" "zellij-action new-pane -d up -- $1"
                else
                    printf "%s\n" "zellij-action new-pane -d up"
                fi
            }
    }
}

evaluate-commands %sh{
  kak_tree_sitter="$kak_config/kak-tree-sitter"
  [ ! -e "$kak_tree_sitter" ] && \
    git clone -q https://github.com/phaazon/kak-tree-sitter "$kak_tree_sitter" && \
    pushd "$kak_tree_sitter" && cargo build -q --release && popd && \
    cp "$kak_tree_sitter/target/release/ktsctl" "$HOME/.local/bin" && \
    cp "$kak_tree_sitter/target/release/kak-tree-sitter" "$HOME/.local/bin"

    kak-tree-sitter -dks --session $kak_session
}
evaluate-commands %sh{
    theme_mode="$(gsettings get org.gnome.desktop.interface color-scheme)"
    if [ "$theme_mode" = "'prefer-light'" ]
    then
        printf "%s\n" "colorscheme catppuccin_latte"
    else
        printf "%s\n" "colorscheme catppuccin_mocha"
    fi
}
set-option global ui_options terminal_assistant=cat terminal_status_on_top=false
map global insert <c-[> <esc>
define-command -docstring "save and quit" x "write-all; quit"

