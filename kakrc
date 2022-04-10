set-option global tabstop		4
set-option global indentwidth	4

evaluate-commands %sh{
    plugins="$kak_config/plugins"
    mkdir -p "$plugins"
    [ ! -e "$plugins/plug.kak" ] && \
        git clone -q https://github.com/andreyorst/plug.kak.git "$plugins/plug.kak"
    printf "%s\n" "source '$plugins/plug.kak/rc/plug.kak'"
}
plug "andreyorst/plug.kak" noload

plug "catppuccin/kakoune" theme config %{
    colorscheme catppuccin
}

plug "kak-lsp/kak-lsp" config %{
    set global lsp_cmd "kak-lsp -c $HOME/.config/kak/kak-lsp.toml -s %val{session} -vvv --log /tmp/kak-lsp.log"
        hook global WinSetOption filetype=(rust|python|haskell|julia|sh|latex) %{
            set global lsp_hover_anchor false
            lsp-enable-window

            map global goto w '<esc>: lsp-hover-buffer lsp-info-window <ret>' -docstring 'lsp-info-window'

            define-command -docstring 'lsp-logs: shows lsp logs on tmux window' lsp-logs -params 0 %{
                terminal 'less +F /tmp/kak-lsp.log'
            }

            map global goto L '<esc>: lsp-logs <ret>' -docstring 'show lsp logs on tmux'
        }
}

plug "andreyorst/kaktree" defer kaktree %{
	set-option global kaktree_dir_icon_close	''
    set-option global kaktree_dir_icon_open		''
    set-option global kaktree_file_icon			'☶'
    set-option global kaktree_keep_focus		true
    set-option global kaktree_size 40
} config %{
    hook global WinSetOption filetype=kaktree %{
        remove-highlighter buffer/numbers-lines
        remove-highlighter buffer/matching
        remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespaces
    }
    kaktree-enable
	map global normal <F8> ':cd %sh{dirname $kak_buffile} <ret> :kaktree-toggle <ret>' -docstring 'open kaktree on current working directory'
}

plug "abuffseagull/kakoune-discord" do %{ cargo install --path . --force } %{
    discord-presence-enable
}

hook global WinSetOption filetype=(julia) %{
    define-command -docstring 'julia-repl: Open Julia REPL at current project or pwd' julia-repl -params 0..1 %{
        evaluate-commands %sh{
            if [ -n "$1" ]
            then
                printf "%s\n" "terminal julia --project=$1"
            else
                project_path="$(julia -q --startup-file=no --history-file=no -e 'println(dirname(Base.current_project(dirname(ENV["kak_buffile"]))))')"                
                printf "%s\n" "terminal julia --project=$project_path"
            fi
        }
    }
    map global normal P -docstring 'julia-repl' ': julia-repl <ret>'
}

hook global ModuleLoaded wayland %{
	set-option global termcmd "foot sh -c"
}

