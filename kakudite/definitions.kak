define-command -hidden open-file-picker %{
  prompt file: -menu -shell-script-candidates "fd --type=file" %{
    edit -existing %val{text}
  }
}

define-command -hidden open-recent-file-picker %{
  prompt file: -menu -shell-script-candidates "cat $kak_config/recentf" %{
    change-directory %sh{
        dirname "$kak_text"
    }
    edit -existing %val{text}
  }
}

define-command -hidden open-buffer-picker %{
  prompt buffer: -menu -buffer-completion %{
    buffer %val{text}
  }
}

