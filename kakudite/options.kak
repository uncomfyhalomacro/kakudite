hook global InsertCompletionShow .* %{
	map buffer insert <tab> <c-n>
	map buffer insert <s-tab> <c-p>
}

hook global InsertCompletionHide .* %{
	unmap buffer insert <tab>
	unmap buffer insert <s-tab>
}

hook global WinSetOption filetype=.* %{
    add-highlighter buffer/ show-whitespaces
    add-highlighter buffer/ show-matching
    add-highlighter buffer/ wrap -indent -word -width 120 -marker '↝'
    add-highlighter -override buffer/ number-lines -relative -min-digits 6
    hook global ModeChange (push|pop):.*:insert %{
        set-face buffer PrimarySelection white,green+F
        set-face buffer SecondarySelection black,green+F
        set-face buffer PrimaryCursor black,bright-yellow+F
        set-face buffer SecondaryCursor black,bright-green+F
        set-face buffer PrimaryCursorEol black,bright-yellow
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

hook global ModuleLoaded zellij %{
    define-command -docstring 'vsplit-right (zellij): Open a new vertical split on the right relative to the active pane' vsplit-right -params 0..1 %{
            nop %sh{
                if [ -n "$1" ]
                then
                    zellij action new-pane -c -d right -- $*
                else
                    zellij action new-pane -d right
                fi
            }
    }

    define-command -docstring 'vsplit-left (zellij): Open a new vertical split on the left relative to the active pane' vsplit-left -params 0..1 %{
            nop %sh{
                if [ -n "$1" ]
                then
                    zellij action new-pane -c -d left -- $*
                else
                    zellij action new-pane -d left
                fi
            }
    }

    define-command -docstring 'split-down (zellij): Open a new vertical split on the down relative to the active pane' split-down -params 0..1 %{
            nop %sh{
                if [ -n "$1" ]
                then
                    zellij action new-pane -c -d down -- $*
                else
                    zellij action new-pane -d down
                fi
            }
    }

    define-command -docstring 'split-up (zellij): Open a new vertical split on the up relative to the active pane' split-up -params 0..1 %{
            nop %sh{
                if [ -n "$1" ]
                then
                    zellij-action new-pane -c -d up -- $*
                else
                    zellij action new-pane -d up
                fi
            }
    }

    define-command -docstring 'open-xplr: Open a file manager in a specific direction relative from the active pane' \
    open-xplr -params 0..1 %{
       nop %sh{
           cwd=$(dirname "$kak_buffile" 2>/dev/null)
           if [ -n "$1" ]
           then
                zellij action new-pane -c --floating --cwd $cwd -d $1 -- env KAK_CLIENT=$kak_client KAK_SESSION=$kak_session xplr "$cwd"
           else
                zellij action new-pane -c --floating --cwd $cwd -- env KAK_CLIENT=$kak_client KAK_SESSION=$kak_session xplr "$cwd"
           fi
       }
    }

    define-command -hidden zellij_actionables %{
      prompt actions: -menu -shell-script-candidates 'echo -e "new-pane\nfocus-next-pane\nfocus-previous-pane\nnew-tab"' %{
        nop %sh{
            cwd=$(dirname "$kak_buffile" 2>/dev/null)
            case $kak_text in
                new-pane)
                zellij action "$kak_text" --close-on-exit --cwd "$cwd" -- env KAK_CLIENT=$kak_client KAK_SESSION=$kak_session $SHELL
                ;;
                new-tab)
                zellij action "$kak_text" --cwd "$cwd" -l default
                ;;
                *)
                zellij action "$kak_text"
                ;;
            esac
        }
      }
    }

    define-command -hidden open_file_on_new_pane %{
      prompt file: -menu -shell-script-candidates 'fd --type=file' %{
        nop %sh{
            zellij action new-pane --close-on-exit -- kak -c "$kak_session" "$kak_text"
        }
      }
    }

    define-command -hidden open_buffer_on_new_pane %{
      prompt buffer: -menu -buffer-completion %{
        nop %sh{
            zellij action new-pane --close-on-exit -- kak -c "${kak_session}" -e "buffer ${kak_text}"
        }
      }
    }

    map -docstring "zellij_actionables: action on zellij" global user  <z>   ': zellij_actionables<ret>'
    map -docstring "open_file_on_new_pane" global user <F> ': open_file_on_new_pane<ret>'
    map -docstring "open_buffer_on_new_pane" global user <B> ': open_buffer_on_new_pane<ret>'

}

define-command -hidden open_file_picker %{
  prompt file: -menu -shell-script-candidates 'fd --type=file' %{
    edit -existing %val{text}
  }
}

define-command -hidden open_buffer_picker %{
  prompt buffer: -menu -buffer-completion %{
    buffer %val{text}
  }
}

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
# TODO move mappings somewhere
map global insert <c-[> <esc>
map global normal <c-a> ': inc-dec-modify-numbers + %val{count}<ret>'
map global normal <c-x> ': inc-dec-modify-numbers - %val{count}<ret>'
map -docstring "open_file_picker: opens a file picker using fd" \
    global user   <f>   ': open_file_picker<ret>'
map -docstring "open_buffer_picker: opens a buffer picker using completion" \
    global user   <b>   ': open_buffer_picker<ret>'
map -docstring "open-xplr: open a floating file explorer" \
    global user   <e>   ': open-xplr<ret>'
define-command -docstring "save and quit" x "write-all; quit"

# Status line
set-face global BufferList  "%opt{background},%opt{rosewater}"
set-face global DateTime    "%opt{background},%opt{cyan}"
set-face global StatusLine  "%opt{foreground},%opt{background}"
set-face global GitBranch   "%opt{background},%opt{mauve}"
set-face global GitModified "%opt{background},%opt{teal}"
set-face global BlackOnWhiteBg "%opt{background},%opt{foreground}"

set-option global modelinefmt '%val{bufname} %val{cursor_line}:%val{cursor_char_column} {BlackOnWhiteBg}[%opt{filetype}]{StatusLine} {{context_info}} {{mode_info}} - %val{client}@[%val{session}]%opt{lsp_modeline_message_requests} %opt{lsp_modeline_progress} {BufferList}U+%sh{printf "%04x" "$kak_cursor_char_value"}{StatusLine} {BlackOnWhiteBg}%sh{printf "﬘->%s"  $(printf %s\\n $kak_buflist |wc -w) }{StatusLine} {DateTime}%sh{ date "+%Y-%m-%d %T"}'

