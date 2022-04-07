colorscheme gruvbox-light


evaluate-commands %sh{
    plugins="$kak_config/plugins"
    mkdir -p "$plugins"
    [ ! -e "$plugins/plug.kak" ] && \
        git clone -q https://github.com/andreyorst/plug.kak.git "$plugins/plug.kak"
    printf "%s\n" "source '$plugins/plug.kak/rc/plug.kak'"
}
plug "andreyorst/plug.kak" noload
plug "kak-lsp/kak-lsp" config %{
  set global lsp_cmd "kak-lsp -s %val{session} -vvv --log /tmp/kak-lsp.log"
  hook global WinSetOption filetype=(rust|python|haskell|julia|sh|latex) %{
      set global lsp_hover_anchor false
      lsp-enable-window
      map global goto w '<esc>: lsp-hover-buffer lsp-info-window <ret>' -docstring 'lsp-info-window' 
  }
}

plug "andreyorst/kaktree" config %{
        hook global WinSetOption filetype=kaktree %{
                    remove-highlighter buffer/numbers
                            remove-highlighter buffer/matching
                                    remove-highlighter buffer/wrap
                                            remove-highlighter buffer/show-whitespaces
        }
        kaktree-enable
}

plug "abuffseagull/kakoune-discord" do %{ cargo install --path . --force } %{
      discord-presence-enable
}

hook global WinSetOption filetype=(julia) %{
    define-command -docstring 'julia-repl: Open Julia REPL at current project or pwd' julia-repl -params 0..1 %{
        evaluate-commands %sh{
                if [ -n "$1" ]
                then
        			echo "tmux-repl-vertical 'julia --project=$1'"
        		else
        			project_path="$(dirname $kak_buffile)"
                 	echo "tmux-repl-vertical 'julia --project=$project_path'"
                fi
        	}
    }
    map global normal P -docstring 'julia-repl' ': julia-repl <ret>'
}
set-option global tabstop     4
set-option global indentwidth 4
