set-option global tabstop		4
set-option global indentwidth	4
# hook global WinSetOption filetype=(?!kak).* %{
#     add-highlighter buffer/ number-lines
#     add-highlighter buffer/  show-matching
#     add-highlighter buffer/  show-whitespaces
# }
evaluate-commands %sh{
    plugins="$kak_config/plugins"
    mkdir -p "$plugins"
    [ ! -e "$plugins/plug.kak" ] && \
        git clone -q https://github.com/andreyorst/plug.kak.git "$plugins/plug.kak"
    printf "%s\n" "source '$plugins/plug.kak/rc/plug.kak'"
}
declare-option -docstring "name of the git branch holding the current buffer" \
    str modeline_git_branch

declare-option -docstring "name of the git status holding the current buffer" \
    str modeline_git_status


hook global WinCreate .* %{
    hook window NormalIdle .* %{ evaluate-commands %sh{
        branch=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -n "${branch}" ]; then
            printf 'set window modeline_git_branch %%{%s}' "${branch}"
        fi
    }
}

}

hook global WinCreate .* %{
    hook window NormalIdle .* %{ evaluate-commands %sh{
        status=$(cd "$(dirname "${kak_buffile}")" && git status --porcelain "${kak_buffile}" | cut -b 1 2>/dev/null)
        if [ -n "${status}" ]; then
            status=$(printf "$status" | sed 's/M/+/g')
            printf 'set window modeline_git_status %%{%s}' "[${status}]"
        else
            status=$(cd "$(dirname "${kak_buffile}")" && git status --porcelain | cut -b 1 2>/dev/null)
            status=$(printf "$status" | sed 's/M/+/g')
            if [ -n "${status}" ]; then
                printf 'set window modeline_git_status %%{%s}' "[${status//$'\n'/ }]"
            fi
        fi
      }
}
}
hook global WinCreate .* %{ evaluate-commands %sh{
        is_work_tree=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --is-inside-work-tree 2>/dev/null)
            if [ "${is_work_tree}" = 'true' ]; then
                printf 'set-option window modelinefmt %%{%s}' " %opt{modeline_git_branch}%opt{modeline_git_status} ${kak_opt_modelinefmt}"
            fi
}}

plug "andreyorst/plug.kak" noload

plug "catppuccin/kakoune" theme config %{
    colorscheme catppuccin
    
}

plug "kak-lsp/kak-lsp" config %{
    set global lsp_cmd "kak-lsp -c %val{config}/kak-lsp.toml -s %val{session} -vvv --log /tmp/kak-lsp.log"
        hook global WinSetOption filetype=(rust|python|haskell|julia|sh|latex) %{
            add-highlighter buffer/	number-lines
            add-highlighter buffer/	show-matching
            add-highlighter buffer/	show-whitespaces
			

            set global lsp_hover_anchor false
            lsp-enable-window
            map global user l %{: enter-user-mode lsp<ret>} -docstring "LSP mode"

            map global goto w '<esc>: lsp-hover-buffer lsp-info-window <ret>' -docstring 'lsp-info-window'

            define-command -docstring 'lsp-logs: shows lsp logs on tmux window' lsp-logs -params 0 %{
                terminal sh -c 'less +F /tmp/kak-lsp.log'
            }

            map global goto L '<esc>: lsp-logs <ret>' -docstring 'show lsp logs on another window'
        }
}

hook global WinSetOption filetype=kak %{
    add-highlighter buffer/	number-lines
    add-highlighter buffer/	show-matching
    add-highlighter buffer/	show-whitespaces
}
		
plug "andreyorst/kaktree" defer kaktree %{
	set-option global kaktree_dir_icon_close	' '
    set-option global kaktree_dir_icon_open		' '
    set-option global kaktree_file_icon			' ☶'
    set-option global kaktree_keep_focus		true
    set-option global kaktree_size				40
    set-option global kaktree_show_hidden		true
} config %{
    hook global WinSetOption filetype=(?!kaktree)(?!sh).* %{
        remove-highlighter buffer/numbers
        remove-highlighter buffer/matching
        remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespace

        # add-highlighter buffer/	number-lines
        # add-highlighter buffer/	show-matching
        # add-highlighter buffer/	show-whitespaces
    }
    kaktree-enable
	map global normal <F8> ':cd %sh{dirname $kak_buffile} <ret> :kaktree-toggle <ret>' -docstring 'open kaktree on current working directory'
}
# evaluate-commands %sh{
#     if [[ "$kak_bufname" == "" ]]
#     then
#     	printf "%s\n" "add-highlighter buffer/ number-lines"
#     	printf "%s\n" "add-highlighter buffer/ show-matching"
#     	printf "%s\n" "add-highlighter buffer/ show-whitespaces"
#     fi
# }
plug "abuffseagull/kakoune-discord" do %{ cargo install --path . --force } %{
    discord-presence-enable
}

plug "andreyorst/fzf.kak"

hook global ModuleLoaded kitty %{
    hook global WinSetOption filetype=(julia) %{
        define-command -docstring 'julia-repl: Open Julia REPL at current project or pwd' julia-repl -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "%s\n" "kitty-repl julia --project=$1"
                else
                    project_path="$(julia -q --startup-file=no --history-file=no -e 'println(dirname(Base.current_project(dirname(ENV["kak_buffile"]))))')"                
                    printf "%s\n" "kitty-repl julia --project=$project_path"
                fi
            }
        }
    }
}
hook global ModuleLoaded tmux %{
    hook global WinSetOption filetype=(julia) %{
        define-command -docstring 'julia-repl: Open Julia REPL at current project or pwd' julia-repl -params 0..1 %{
            evaluate-commands %sh{
                if [ -n "$1" ]
                then
                    printf "%s\n" "tmux-repl-vertical julia --project=$1"
                else
                    project_path="$(julia -q --startup-file=no --history-file=no -e 'println(dirname(Base.current_project(dirname(ENV["kak_buffile"]))))')"                
                    printf "%s\n" "tmux-repl-vertical julia --project=$project_path"
                fi
            }
        }
    }
}

map global normal P -docstring 'julia-repl' ': julia-repl <ret>'

# evaluate-commands %sh{
#     awk '{print "set-option -add window my_custom_completions "$3" "$1}' '$HOME/.config/kak/latex-completion'
#     awk '{print "set-option window my_custom_completions "$3"|"$1"{MenuInfo}"$1"}' '$HOME/.config/kak/latex-completion'
# }

# set-option global my_custom_completions	\
# 	"%val{cursor_line}.%val{cursor_column}@%val{timestamp}"	\
# 	"!||! {MenuInfo}[LaTeX]\\\\exclam = !"	\
# 	"frog||frog {MenuInfo}Fried with garlic"

# declare-option -hidden completions my_custom_completions

# set-option global completers option=my_custom_completions %opt{completers}

# hook global InsertIdle .* %{
# try %{
# # Test whether the previous word is "eat". If it isn't, this
# # command will throw an exception and execution will jump to
# # the "catch" block below.
#     execute-keys -draft 2b s '\A\\\z<ret>'

#     evaluate-commands -draft %{
# # Try to select the entire word before the cursor,
# # putting the cursor at the left-end of the selection.
#     execute-keys h <a-i>w <a-semicolon>

# # The selection's cursor is at the anchor point
# # for completions, and the selection covers
# # the text the completions should replace,
# # exactly the information we need for the header item.
#     set-option window my_custom_completions \
#     	"%val{cursor_line}.%val{cursor_column}+%val{selection_length}@%val{timestamp}"
# }

#     # Now we've built the header item,
#     # we can add the actual completions.
#     set-option -add window my_custom_completions "exclam||! {MenuInfo}[LaTeX] \exclam = !"
#     set-option -add window my_custom_completions "xi||! {MenuInfo}[LaTeX] \exclam = uwu"
#     evaluate-commands -draft %{
#         try %{
# 			execute-keys -draft b 'H<ret>' c '!'
#         	}
#         }
#    	} catch %{
#     # This is not a place to suggest delicious delicacies,
#     # so clear our list of completions.
#     	set-option window my_custom_completions
#     }
# }


# evaluate-commands %sh{
#    	while read -r r; do echo set-option -add window my_custom_completions "$r||$r {MenuInfo}Dictionary"; done <<< "$(cat $kak_config/dictionary/american-english)"
# }

