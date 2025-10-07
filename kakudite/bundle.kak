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

bundle-noload kakoune-themes https://codeberg.org/anhsirk0/kakoune-themes %{
} %{
    mkdir -p ${kak_config}/colors
    ln -sf "${kak_opt_bundle_path}/kakoune-themes" "${kak_config}/colors/"
}

bundle kakoune-lsp 'git clone --depth 1 -b v18.2.0 https://github.com/kakoune-lsp/kakoune-lsp'  %{
    # set global lsp_cmd "kak-lsp -s %val{session} -vvvv --log /tmp/kak-lsp.log"
    # evaluate-commands %sh{kak-lsp}
    remove-hooks global lsp-filetype-.*
    hook -group lsp-filetype-javascript global BufSetOption filetype=(?:javascript|typescript) %{
         set-option buffer lsp_servers %{
            [deno]
            root_globs = ["deno.json"]
            command = "deno"
            args = ["lsp"]
            settings_section = "deno"
            [deno.settings.deno]
            enable = true
            lint = true
            codelens.references = true
            codelens.implementations = true
            codelens.referencesAllFunctions = true
            [biome]
            root_globs = ["biome.json"]
            command = "biome"
            args = ["lsp-proxy"]
         }
    }
    hook -group lsp-filetype-toml global BufSetOption filetype=toml %{
         set-option buffer lsp_servers %{
           [taplo]
           root_globs = [".git", ".hg"]
           args = ["lsp", "stdio"]
         }
    }
    hook -group lsp-filetype-rust global BufSetOption filetype=rust %{
         set-option buffer lsp_servers %{
             [rust-analyzer]
             filetypes = ["rust"]
             root_globs = ["Cargo.toml", "Cargo.lock"]
             command = "rust-analyzer"
             args = []
         }
    }
    hook -group lsp-filetype-python global BufSetOption filetype=python %{
         set-option buffer lsp_servers %{
             [ruff]
             filetypes = ["python"]
             root_globs = ["pyproject.toml", "uv.lock"]
             command = "ruff"
             args = ["server"]

             [ty]
             filetypes = ["python"]
             root_globs = ["pyproject.toml", "uv.lock"]
             command = "uvx"
             args = ["ty", "server"]
         }
    }
    hook -group lsp-filetype-go global BufSetOption filetype=go %{
         set-option buffer lsp_servers %{
             [gopls]
             filetypes = ["go"]
             root_globs = ["go.mod", "go.sum", "go.work", "go.templ"]
             command = "gopls"
         }
    }
    hook global WinSetOption filetype=(go|toml|lua|html|css|gleam|solidity|typescript|javascript|rust|crystal|python|haskell|julia|sh|latex|c|cpp) %{
        lsp-enable-window
        set-option global lsp_hover_anchor true
        set-option global lsp_auto_show_code_actions true
        map global user l %{: enter-user-mode lsp<ret>} -docstring "lsp mode commands"
        map global goto w '<esc>: lsp-hover-buffer lsp-info-window <ret>' -docstring 'lsp-info-window'
        # define-command -docstring 'lsp-logs: shows lsp logs on tmux window' lsp-logs -params 0 %{
            # terminal sh -c 'less +F /tmp/kak-lsp.log'
        # }
        # map global goto L '<esc>: lsp-logs <ret>' -docstring 'show lsp logs on another window'
    }

    hook global KakEnd .* %{
        lsp-exit
        nop %sh{
            rm -v /tmp/kak-lsp.log
        }
    }

} %{}

# bundle-install-hook kakoune-lsp %{
#     # cargo install --path . --root "${HOME}/.local"
#     julia --project=@kak-lsp "${kak_config}"/scripts/julia-ls-install
#     mkdir -p "${HOME}/.config/kak-lsp"
#     cp -n "${kak_config}/kak-lsp.toml" "${HOME}/.config/kak-lsp/kak-lsp.toml"
# }

bundle-customload kakoune-inc-dec https://gitlab.com/Screwtapello/kakoune-inc-dec %{
    source "%opt{bundle_path}/kakoune-inc-dec/inc-dec.kak"
} %{}


