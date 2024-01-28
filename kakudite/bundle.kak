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

bundle-noload catppuccin 'git clone https://github.com/catppuccin/kakoune ./catppuccin.kak' %{
} %{
    mkdir -p ${kak_config}/colors
    ln -sf "${kak_opt_bundle_path}/catppuccin.kak" "${kak_config}/colors/" 
}

bundle-noload kakoune-themes https://codeberg.org/anhsirk0/kakoune-themes %{
} %{
    mkdir -p ${kak_config}/colors
    ln -sf "${kak_opt_bundle_path}/kakoune-themes" "${kak_config}/colors/"
}

bundle kakoune-discord https://github.com/ABuffSeagull/kakoune-discord %{
    discord-presence-enable
    hook global KakEnd .* nop %sh{
        pkill kakoune-discord
        rm -f "${TMPDIR:-/tmp}"/kakoune-discord
    }
}

bundle-install-hook kakoune-discord %{
    cargo install --path . --root "${HOME}/.local"
}

bundle kak-lsp 'git clone -b v15.0.1 https://github.com/kak-lsp/kak-lsp'  %{
    set global lsp_cmd "kak-lsp -c %val{config}/kak-lsp.toml -s %val{session} -vvv --log /tmp/kak-lsp.log"

    hook global WinSetOption filetype=(rust|crystal|python|haskell|julia|sh|latex) %{
        set global lsp_hover_anchor false
        set global lsp_auto_show_code_actions true

        lsp-enable-window
        map global user l %{: enter-user-mode lsp<ret>} -docstring "lsp mode commands"
        map global goto w '<esc>: lsp-hover-buffer lsp-info-window <ret>' -docstring 'lsp-info-window'
        define-command -docstring 'lsp-logs: shows lsp logs on tmux window' lsp-logs -params 0 %{
            terminal sh -c 'less +F /tmp/kak-lsp.log'
        }
        map global goto L '<esc>: lsp-logs <ret>' -docstring 'show lsp logs on another window'
    }

    hook global KakEnd .* lsp-exit

} %{}

bundle-install-hook kak-lsp %{
    cargo install --path . --root "${HOME}/.local"
    julia --project=@kak-lsp "${kak_config}"/scripts/julia-ls-install
}

bundle-customload smarttab https://github.com/andreyorst/smarttab.kak %{
    source "%opt{bundle_path}/smarttab.kak/rc/smarttab.kak"
    hook global ModuleLoaded editorconfig %{
        hook global BufCreate .*  %{
            autoconfigtab
        }
    }
    # you can configure text that is being used to represent curent active mode
    hook global WinSetOption filetype=.* %{
        expandtab # must be before softtabstop
        set-option buffer indentwidth 4
        set-option global softtabstop 4 # number of spaces to delete on backspace
    }
    set-option global smarttab_expandtab_mode_name 'exp'
    set-option global smarttab_noexpandtab_mode_name 'noexp'
    set-option global smarttab_smarttab_mode_name 'smart'
} %{}

bundle-customload kakoune-inc-dec https://gitlab.com/Screwtapello/kakoune-inc-dec %{
    source "%opt{bundle_path}/kakoune-inc-dec/inc-dec.kak"
} %{}

bundle-customload kak-tree-sitter https://github.com/phaazon/kak-tree-sitter %{
    # evaluate-commands %sh{
    #     kak-tree-sitter -dks --session $kak_session
    # }
} %{}

bundle-install-hook kak-tree-sitter %{
    cargo install --path ktsctl --root "$HOME/.local"
    cargo install --path kak-tree-sitter --root "$HOME/.local"
    languages=( "bash" "julia" "rust" "crystal" "git-commit" "markdown" "toml" "hare" "yaml" )

    for language in "${languages[@]}"
    do
      lang_grammar_path="${HOME}/.local/share/kak-tree-sitter/grammars/${language}.so"
      lang_queries_path="${HOME}/.local/share/kak-tree-sitter/queries/${language}"
      [[ ! -e "${lang_grammar_path}" || ! -d "${lang_queries_path}" ]] && \
          ktsctl -fci "${language}" > /dev/null 2>&1
    done
}
