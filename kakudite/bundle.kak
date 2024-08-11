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

bundle kakoune-lsp 'git clone --depth 1 -b v17.1.1 https://github.com/kakoune-lsp/kakoune-lsp'  %{
    hook global WinSetOption filetype=(toml|lua|html|css|gleam|solidity|typescript|javascript|rust|crystal|python|haskell|julia|sh|latex|c|cpp) %{
        lsp-enable-window
        set global lsp_hover_anchor true
        set global lsp_auto_show_code_actions true
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

bundle-install-hook kakoune-lsp %{
    cargo install --path . --root "${HOME}/.local"
    julia --project=@kak-lsp "${kak_config}"/scripts/julia-ls-install
    mkdir -p "${HOME}/.config/kak-lsp"
    cp -n "${kak_config}/kak-lsp.toml" "${HOME}/.config/kak-lsp/kak-lsp.toml"
}

bundle-customload kakoune-inc-dec https://gitlab.com/Screwtapello/kakoune-inc-dec %{
    source "%opt{bundle_path}/kakoune-inc-dec/inc-dec.kak"
} %{}


