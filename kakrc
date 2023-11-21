evaluate-commands %sh{
  # We're assuming the default bundle_path here...
  plugins="$kak_config/bundle"
  mkdir -p "$plugins"
  [ ! -e "$plugins/kak-bundle" ] && \
    git clone -q https://github.com/jdugan6240/kak-bundle "$plugins/kak-bundle"
  printf "%s\n" "source '$plugins/kak-bundle/rc/kak-bundle.kak'"
}

bundle-noload kak-bundle https://github.com/jdugan6240/kak-bundle

hook global User bundle-after-install %{
  # This is run after bundle-install completes.
  # This could be for automatically deleting the *bundle* buffer, or some other similar action.
  # In this case, we want to exit Kakoune, so we return to the command line.
  quit!
}

bundle-noload catppuccin 'git clone https://github.com/catppuccin/kakoune ./catppuccin.kak' %{
} %{
    mkdir -p ${kak_config}/colors
    ln -sf "${kak_opt_bundle_path}/catppuccin.kak" "${kak_config}/colors/" 
}

bundle-noload kakoune-themes https://codeberg.org/anhsirk0/kakoune-themes %{
} %{
    mkdir -p ${kak_config}/colors
    ln -sf "${kak_opt_bundle_path}/kakoune-themes" "${kak_config}/colors/"
}

bundle kakoune-discord https://github.com/ABuffSeagull/kakoune-discord %{
    discord-presence-enable
}

bundle-install-hook kakoune-discord %{
    cargo build -q --release
    cp target/release/kakoune-discord "$HOME/.local/bin" 
} 

bundle kak-lsp https://github.com/kak-lsp/kak-lsp  %{
    set global lsp_cmd "kak-lsp -c %val{config}/kak-lsp.toml -s %val{session} -vvv --log /tmp/kak-lsp.log"
        hook global WinSetOption filetype=(rust|python|haskell|julia|sh|latex) %{
            set global lsp_hover_anchor false
            lsp-enable-window
            map global user l %{: enter-user-mode lsp<ret>} -docstring "lsp mode commands"
            map global goto w '<esc>: lsp-hover-buffer lsp-info-window <ret>' -docstring 'lsp-info-window'
            define-command -docstring 'lsp-logs: shows lsp logs on tmux window' lsp-logs -params 0 %{
                terminal sh -c 'less +F /tmp/kak-lsp.log'
            }
            map global goto L '<esc>: lsp-logs <ret>' -docstring 'show lsp logs on another window'
        }
} %{}

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

bundle-customload smarttab https://github.com/andreyorst/smarttab.kak %{
    source "%opt{bundle_path}/smarttab.kak/rc/smarttab.kak"
    hook global BufCreate .*  %{
        editorconfig-load
        autoconfigtab
    }

    # you can configure text that is being used to represent curent active mode
    hook global WinSetOption filetype=.* %{
        expandtab # must be before softtabstop
        set-option buffer indentwidth 4
        set-option global softtabstop 4 # number of spaces to delete on backspace
    }
    set-option global smarttab_expandtab_mode_name 'exp'
    set-option global smarttab_noexpandtab_mode_name 'noexp'
    set-option global smarttab_smarttab_mode_name 'smart'
} %{}

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

map global insert <c-[> <esc>
define-command -docstring "save and quit" x "write-all; quit"

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
