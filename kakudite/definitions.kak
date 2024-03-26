define-command -hidden open_file_picker %{
  prompt file: -menu -shell-script-candidates "fd --type=file" %{
    edit -existing %val{text}
  }
}

define-command -hidden open_recent_file_picker %{
  prompt file: -menu -shell-script-candidates "cat $kak_config/recentf" %{
    change-directory %sh{
        dirname "$kak_text"
    }
    edit -existing %val{text}
  }
}

define-command -hidden open_buffer_picker %{
  prompt buffer: -menu -buffer-completion %{
    buffer %val{text}
  }
}

