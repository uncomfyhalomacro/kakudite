hook global ModuleLoaded tmux %{
    define-command -docstring 'vsplit-right (tmux): Open a new vertical split on the right relative to the active pane' vsplit-right -params 0..1 %{
            nop %sh{
                if [ -n "$1" ]
                then
                    tmux splitw -h $*
                else
                    tmux splitw -h
                fi
            }
    }

    define-command -docstring 'vsplit-left (tmux): Open a new vertical split on the left relative to the active pane' vsplit-left -params 0..1 %{
            nop %sh{
                if [ -n "$1" ]
                then
                    tmux splitw -h -b $*
                else
                    tmux splitw -h -b
                fi
            }
    }

    define-command -docstring 'split-down (tmux): Open a new vertical split on the down relative to the active pane' split-down -params 0..1 %{
            nop %sh{
                if [ -n "$1" ]
                then
                    tmux splitw $*
                else
                    tmux splitw
                fi
            }
    }

    define-command -docstring 'split-up (tmux): Open a new vertical split on the up relative to the active pane' split-up -params 0..1 %{
            nop %sh{
                if [ -n "$1" ]
                then
                    tmux splitw -b $*
                else
                    tmux splitw -b
                fi
            }
    }

    # Replaces filepicker
    define-command -docstring 'open-fzf-select-file: Open a floating fzf window to select a file'\
    open-fzf-select-file %{
        evaluate-commands %sh{
            local selected_file
            selected_file=$(fd -t f | fzf --prompt="select file> " --tmux="center,95%" --preview="bat -n --color=always {}")
            [[ -n $selected_file ]] && printf "edit %s\n" "$selected_file"
        }
    }

    define-command -docstring 'open-fzf-select-buffer: Open a floating fzf window to select a buffer'\
    open-fzf-select-buffer %{
        evaluate-commands %sh{
            local selected_buffer
            selected_buffer=$(echo "$kak_buflist" | tr ' ' '\n' | fzf --prompt="select buffer> " --tmux="center,95%" --preview="[[ -f {} ]] && bat -n --color=always {}")
            [[ -n $selected_buffer ]] && printf "edit %s\n" "$selected_buffer"
        }
    }

    define-command -docstring 'open-xplr: Open a floating file manager' \
    open-xplr %{
       nop %sh{
           cwd=$(dirname "$kak_buffile" 2>/dev/null)
           tmux popup -d $PWD -E -- env KAK_CLIENT=$kak_client KAK_SESSION=$kak_session xplr "$PWD"
       }
    }

    map -docstring "open-file-picker: opens a new file using fd and/or fzf" \
        global user <f> ': open-fzf-select-file<ret>'

    map -docstring "open-buffer-picker: opens a new buffer using fd and/or fzf" \
        global user <b> ': open-fzf-select-buffer<ret>'

    map -docstring "open-xplr: opens xplr file explorer" \
        global user   <e>   ': open-xplr<ret>'


    define-command -hidden open-file-on-new-pane %{
      prompt file: -menu -shell-script-candidates "fd --type=file" %{
        nop %sh{
            tmux splitw -h -- kak -c "$kak_session" "$kak_text"
        }
      }
    }

    define-command -hidden open-buffer-on-new-pane %{
      prompt buffer: -menu -buffer-completion %{
        nop %sh{
            tmux splitw -h -- kak -c "${kak_session}" -e "buffer ${kak_text}"
        }
      }
    }

    map -docstring "open-file-on-new-pane" global user <F> ':open-file-on-new-pane<ret>'
    map -docstring "open-buffer-on-new-pane" global user <B> ':open-buffer-on-new-pane<ret>'
}
