define-command insert-date %{
    execute-keys %sh{
    	local mydate
    	mydate="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf "i%s" "$mydate"
    }
}

map -docstring "insert-date: insert date in UTC and ISO 8601 format" \
    global user <d> ": insert-date<ret>"

define-command -hidden open-file-picker %{
  prompt file: -menu -shell-script-candidates "fd --type=file" %{
    edit -existing %val{text}
  }
}

define-command -hidden open-word-picker %{
  prompt word: -shell-script-candidates "cat /usr/share/dict/* | uniq" %{
    execute-keys %sh{
        printf "i%s" "$kak_text"
    }
  }
}

define-command -hidden -docstring 'makedir: create-new-directory' makedir -params 1 %{
    nop %sh{
        mkdir -p "$PWD/$1"
    }
}

define-command -docstring 'mkdir: passes a directory to makedir so user can modify it for later' mkdir %{
    prompt menu: -shell-script-candidates "fd -t d | sort" %{
        execute-keys %sh{
            printf ":makedir %s" "$kak_text"
        }
    }
}

map -docstring "mkdir: passes a directory to makedir so user can modify it for later" \
    global user <m> ': mkdir<ret>'

map -docstring "open-word-picker: opens dictionary words file" \
    global user   <w>   ': open-word-picker<ret>'

define-command -hidden open-recent-file-picker %{
  prompt menu: -shell-script-candidates "cat $kak_config/recentf" %{
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
        $TERM -e xplr "$PWD" > /dev/null 2>&1 & disown
    }
}

map -docstring "open-xplr-in-new-terminal: opens xplr file explorer" \
    global user   <x>   ': open-xplr-in-new-terminal<ret>'

