# https://www.reddit.com/r/kakoune/comments/18ewapx/dynamic_fractional_scrolloff/
hook global WinCreate .* %{
  hook -once window WinDisplay .* %{

    hook window WinResize [0-9]*\.[0-9]* %{
      set-option window scrolloff %sh{
        printf '%u,%u' "$(($kak_window_height / 6))" "$(($kak_window_width / 8))"
      }
    }

  }
}
