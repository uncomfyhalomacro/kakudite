hook global ModuleLoaded zellij %{
    define-command -docstring 'vsplit-right (zellij): Open a new vertical split on the right relative to the active pane' vsplit-right -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "zellij- action new-pane -c -d right -- $*"
                else
                    printf "zellij- action new-pane -d right"
                fi
            }
    }

    define-command -docstring 'vsplit-left (zellij): Open a new vertical split on the left relative to the active pane' vsplit-left -params 0..1 %{

            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "zellij- action new-pane -c -d left -- $*"
                else
                    printf "zellij- action new-pane -d left"
                fi
            }
    }

    define-command -docstring 'split-down (zellij): Open a new vertical split on the down relative to the active pane' split-down -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "zellij-action new-pane -c -d down -- $*"
                else
                    printf "zellij-action new-pane -d down"
                fi
            }
    }

    define-command -docstring 'split-up (zellij): Open a new vertical split on the up relative to the active pane' split-up -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "zellij-action new-pane -c -d up -- $*"
                else
                    printf "zellij-action new-pane -d up"
                fi
            }
    }

    define-command -docstring 'open-xplr: Open a floating file manager' \
    open-xplr -params 0..1 %{
       evaluate-commands %sh{
           cwd=$(dirname "$kak_buffile" 2>/dev/null)
           if [ -n "$1" ]
           then
             printf "zellij-action new-pane -c --floating --cwd $cwd -d $1 -- env KAK_CLIENT=$kak_client KAK_SESSION=$kak_session xplr "$cwd""
           else
             printf "zellij-action new-pane -c --floating --cwd $cwd -- env KAK_CLIENT=$kak_client KAK_SESSION=$kak_session xplr "$cwd""
           fi
       }
    }

    define-command -params 0..1 \
        -docstring %{
        zellij-send-text [text]: Send text to another pane or tab relative to focused pane or tab.

        If there is no text, the main selection is used.
    } \
    zellij-send-text %{
        nop %sh{
            zellij action focus-next-pane
            if [ $# -eq 0 ]; then
                text="$kak_selection"
            else
                text="$1"
            fi
            zellij action write-chars "${text}"
            zellij action focus-previous-pane
        }
    }

    define-command -params 0..1 \
        -docstring %{
            zellij-send-text-with-eof [text]: Like zellij-send-text but also write EOF after the last character.

            Good for aliasing on REPL interactions.

            If there is no text, the main selection is used.
    } \
    zellij-send-text-with-eof %{
        nop %sh{
            zellij action focus-next-pane
            if [ $# -eq 0 ]; then
                text="$kak_selection"
            else
                text="$1"
            fi
            zellij action write-chars "${text}"
            zellij action write 10
            zellij action focus-previous-pane
        }
    }

    define-command -hidden zellij_actionables %{
      prompt actions: -menu -shell-script-candidates 'echo -e "new-pane\nfocus-next-pane\nfocus-previous-pane\nnew-tab\nfocus-client\nsend-text\nsend-text-with-eof\n"' %{
        evaluate-commands %sh{
            cwd=$(dirname "$kak_buffile" 2>/dev/null)
            case $kak_text in
                new-pane)
                printf "zellij-action "$kak_text" --close-on-exit --cwd "$cwd" -- env KAK_CLIENT=$kak_client KAK_SESSION=$kak_session $SHELL"
                ;;
                new-tab)
                printf "zellij-action "$kak_text" --cwd "$cwd" -l default"
                ;;
                focus-client)
                printf '%s%b' "execute-keys :zellij-focus" " "
                ;;
                send-text)
                printf "evaluate-commands -client ${kak_client} zellij-send-text"
                ;;
                send-text-with-eof)
                printf "evaluate-commands -client ${kak_client} zellij-send-text-with-eof"
                ;;
                *)
                printf "zellij-action %s" "$kak_text"
                ;;
            esac
        }
      }
    }

    define-command -hidden open_file_on_new_pane %{
      prompt file: -menu -shell-script-candidates "fd --type=file" %{
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
  prompt file: -menu -shell-script-candidates "fd --type=file" %{
    edit -existing %val{text}
  }
}

define-command -hidden open_buffer_picker %{
  prompt buffer: -menu -buffer-completion %{
    buffer %val{text}
  }
}

