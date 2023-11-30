define-command -docstring %{
    clipboard-yank: Yank main selection to system clipboard.

    Uses xclip or xsel if it's on X11. wl-copy for Wayland.
} \
clipboard-yank \
%{
    nop %sh{
        if [ -n "${WAYLAND_DISPLAY}" ];
        then
            wl-copy --trim-newline "$kak_selection"
        else
            if [ -x "$(command -v xsel)" ];
            then
                printf '%s' "$kak_selection" | xsel -b
            elif [ -x "$(command -v xclip)" ];
            then
                printf '%s' "$kak_selection" | xclip -sel clip
            else
                exit 1
            fi

        fi
    }
}
