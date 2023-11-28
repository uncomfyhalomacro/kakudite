evaluate-commands %sh{
  kak_tree_sitter="$kak_config/kak-tree-sitter"
  [ ! -e "$kak_tree_sitter" ] && \
    git clone -q https://github.com/phaazon/kak-tree-sitter "$kak_tree_sitter" && \
    pushd "$kak_tree_sitter" && cargo build -q --release && popd && \
    cp "$kak_tree_sitter/target/release/ktsctl" "$HOME/.local/bin" && \
    cp "$kak_tree_sitter/target/release/kak-tree-sitter" "$HOME/.local/bin"

  languages=("bash" "julia" "rust" "crystal" "git-commit" "markdown" "toml" "hare" "yaml")

  for language in "${languages[@]}"
  do
    lang_grammar_path="${HOME}/.local/share/kak-tree-sitter/grammars/${language}.so"
    lang_queries_path="${HOME}/.local/share/kak-tree-sitter/queries/${language}"
    [[ ! -e "${lang_grammar_path}" || ! -d "${lang_queries_path}" ]] && \
        ktsctl -fci "${language}" > /dev/null 2>&1
  done

  kak-tree-sitter -dks --session $kak_session
}
