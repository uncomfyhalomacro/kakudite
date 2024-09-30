define-command -hidden open-file-picker %{
  prompt file: -menu -shell-script-candidates "fd --type=file" %{
    edit -existing %val{text}
  }
}

define-command -hidden open-word-picker %{
  prompt file: -menu -shell-script-candidates "cat /usr/share/dict/* | uniq" %{
    execute-keys %sh{
        printf "i%s" "$kak_text"
    }
  }
}

map -docstring "open-word-picker: opens dictionary words file" \
    global user   <w>   ': open-word-picker<ret>'

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

define-command -hidden -docstring 'open-xplr-in-new-terminal: Open xplr' \
open-xplr-in-new-terminal -params 0..1 %{
    nop %sh{
        cwd=$(dirname "$kak_buffile" 2>/dev/null)
        foot -e xplr --vroot "$cwd" > /dev/null 2>&1 & disown
    }
}

map -docstring "open-xplr-in-new-terminal: opens xplr file explorer" \
    global user   <x>   ': open-xplr-in-new-terminal<ret>'
