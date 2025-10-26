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

    define-command -docstring 'open-xplr: Open a floating file manager' \
    open-xplr %{
       nop %sh{
           cwd=$(dirname "$kak_buffile" 2>/dev/null)
           tmux popup -d $cwd -E -- env KAK_CLIENT=$kak_client KAK_SESSION=$kak_session xplr "$cwd"
       }
    }
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
        change-directory %sh{
            dirname "$kak_text"
        }
        nop %sh{
            tmux splitw -h -- kak -c "${kak_session}" -e "buffer ${kak_text}"
        }
      }
    }

    map -docstring "open-file-on-new-pane" global user <F> ':open-file-on-new-pane<ret>'
    map -docstring "open-buffer-on-new-pane" global user <B> ':open-buffer-on-new-pane<ret>'
}
