
hook global ModuleLoaded tmux %{


    hook global WinDisplay .* %{
        nop %sh{
                target="${kak_session}:${kak_bufname}"
                tmux select-pane -T "${target}"
        }
    }

    hook global KakEnd .* %{
        nop %sh{
                win="$(openssl rand -hex 3)"
                tmux select-pane -T "$win"
        }
    }

    hook global WinClose .* %{
        nop %sh{
                win="$(openssl rand -hex 3)"
                tmux select-pane -T "$win"
        }
    }

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

    declare-option str makedirparam
    define-command -override -docstring 'mkdir: passes a directory to makedir so user can modify it for later' mkdir %{
        evaluate-commands %sh{
            selected_dir=$(fd --relative-path -t d | fzf --tmux='center,95%' --preview='if [[ -f "{}" ]]
then
bat -n --color=always {}
else
eza -l --color=always {}
fi')
            printf "set-option buffer makedirparam '%s'" "${selected_dir}\n"
        }

        execute-keys %sh{
            [[ -z "$kak_opt_makedirparam" ]] && exit 0
            printf ":makedir $kak_opt_makedirparam"
        }

        unset-option buffer makedirparam
    }

    map -docstring "mkdir: passes a directory to makedir so user can modify it for later" \
        global user <m> ': mkdir<ret>'


    define-command -override -docstring 'i-edit: interactive find a directory with fzf to run an edit command for later' i-edit %{
        execute-keys %sh{
            selected_dir=$(fd --relative-path -t d | fzf --tmux='center,95%' --preview='if [[ -f "{}" ]]
then
bat -n --color=always {}
else
eza -l --color=always {}
fi')
            printf ":edit %s\n" "${selected_dir}"
        }
    }

    map -docstring "i-edit: interactive find a directory with fzf to run an edit command for later" \
        global user <e> ':i-edit<ret>'

    # Replaces filepicker
    define-command -docstring 'open-fzf-select-file: Open a floating fzf window to select a file'\
    open-fzf-select-file %{
        evaluate-commands %sh{
            selected_file=$(fd --relative-path --no-ignore-vcs -t f | fzf --prompt="select file> " --tmux="center,95%" --preview="bat -n --color=always {}")
            [[ -n $selected_file ]] && printf "edit %s\n" "$selected_file"
        }
    }

    define-command -docstring 'open-fzf-select-buffer: Open a floating fzf window to select a buffer'\
    open-fzf-select-buffer %{
        evaluate-commands %sh{
            selected_buffer=$(echo "$kak_buflist" | tr ' ' '\n' | fzf --prompt="select buffer> " --tmux="center,95%" --preview="[[ -f {} ]] && bat -n --color=always {}")
            [[ -n $selected_buffer ]] && printf "edit %s\n" "$selected_buffer"
        }
    }

    map -docstring "open-file-picker: opens a new file using fd --relative-path and/or fzf" \
        global user <f> ': open-fzf-select-file<ret>'

    map -docstring "open-buffer-picker: opens a new buffer using fd --relative-path and/or fzf" \
        global user <b> ': open-fzf-select-buffer<ret>'

    define-command -hidden open-file-on-new-pane %{
        nop %sh{
            selected_file=$(fd --relative-path --no-ignore-vcs -t f | \
                fzf --prompt="select file> " \
                    --tmux="center,95%" \
                    --preview="bat -n --color=always {}")

            [[ -z "$selected_file" ]] && exit 1

            target="${kak_session}:${selected_file}"

            pane_and_window=$(tmux list-panes -a -F '#{pane_id} #{pane_title} #{window_id}' | \
                   while read -r id title window_id; do
                       [[ "$title" == "$target" ]] && echo "$id $window_id" && break
                   done)

            pane=$(echo $pane_and_window | cut -d' ' -f1)
            win=$(echo $pane_and_window | cut -d' ' -f2)

            if [[ -n "$pane" ]]; then
                win=$(tmux display-message -p -t "$pane" '#{window_id}')
                tmux select-window -t "$win"
                tmux select-pane -t "$pane"
            else
                tmux split-window -h \
                    "tmux select-pane -T \"$target\"; kak -c \"$kak_session\" -e \"edit $selected_file\""
            fi
        }
    }

    define-command -hidden open-buffer-on-new-pane %{
        nop %sh{
            selected_buffer=$(echo "$kak_buflist" | tr ' ' '\n' | fzf --prompt="select buffer> " --tmux="center,95%" --preview="[[ -f {} ]] && bat -n --color=always {}")
            [[ -z "$selected_buffer" ]] && exit 1

            target="${kak_session}:${selected_buffer}"
            pane_and_window=$(tmux list-panes -a -F '#{pane_id} #{pane_title} #{window_id}' | \
                   while read -r id title window_id; do
                       [[ "$title" == "$target" ]] && echo "$id $window_id" && break
                   done)

            pane=$(echo $pane_and_window | cut -d' ' -f1)
            win=$(echo $pane_and_window | cut -d' ' -f2)

            if [[ -n "$pane" ]]; then
                win=$(tmux display-message -p -t "$pane" '#{window_id}')
                tmux select-window -t "$win"
                tmux select-pane -t "$pane"
            else
                tmux split-window -h \
                    "tmux select-pane -T \"$target\"; kak -c \"$kak_session\" -e \"buffer $selected_buffer\""
            fi
        }
    }


    define-command -hidden open-file-on-new-window %{
        nop %sh{
            selected_file=$(fd --relative-path --no-ignore-vcs -t f | \
                fzf --prompt="select file> " \
                    --tmux="center,95%" \
                    --preview="bat -n --color=always {}")

            [[ -z "$selected_file" ]] && exit 1

            target="${kak_session}:${selected_file}"

            pane_and_window=$(tmux list-panes -a -F '#{pane_id} #{pane_title} #{window_id}' | \
                   while read -r id title window_id; do
                       [[ "$title" == "$target" ]] && echo "$id $window_id" && break
                   done)

            pane=$(echo $pane_and_window | cut -d' ' -f1)
            win=$(echo $pane_and_window | cut -d' ' -f2)

            if [[ -n "$pane" ]]; then
                tmux select-window -t "$win"
                tmux select-pane -t "$pane"
                tmux break-pane
            else
                win="kak-$(openssl rand -hex 3)"
                tmux new-window -n "$win" \
                    "tmux select-pane -T \"$target\"; kak -c \"$kak_session\" -e \"edit $selected_file\""
            fi
        }
    }



    define-command -hidden open-buffer-on-new-window  %{
        nop %sh{
            selected_buffer=$(echo "$kak_buflist" | tr ' ' '\n' | fzf --prompt="select buffer> " --tmux="center,95%" --preview="[[ -f {} ]] && bat -n --color=always {}")
            [[ -z "$selected_buffer" ]] && exit 1

            target="${kak_session}:${selected_buffer}"

            pane_and_window=$(tmux list-panes -a -F '#{pane_id} #{pane_title} #{window_id}' | \
                   while read -r id title window_id; do
                       [[ "$title" == "$target" ]] && echo "$id $window_id" && break
                   done)

            pane=$(echo $pane_and_window | cut -d' ' -f1)
            win=$(echo $pane_and_window | cut -d' ' -f2)

            if [[ -n "$pane" ]]; then
                tmux select-window -t "$win"
                tmux select-pane -t "$pane"
                tmux break-pane
            else
                win="kak-$(openssl rand -hex 3)"
                tmux new-window -n "$win" \
                    "tmux select-pane -T \"$target\"; kak -c \"$kak_session\" -e \"buffer $selected_buffer\""
            fi
        }
    }

    map -docstring "open-file-on-new-pane" global user <h> ':open-file-on-new-pane<ret>'
    map -docstring "open-buffer-on-new-pane" global user <H> ':open-buffer-on-new-pane<ret>'
    map -docstring "open-file-on-new-window" global user <n> ':open-file-on-new-window<ret>'
    map -docstring "open-buffer-on-new-window" global user <N> ':open-buffer-on-new-window<ret>'
}
