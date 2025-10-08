define-command -docstring %{
    clipboard-yank: Yank main selection to system clipboard.

    Uses xclip or xsel if it's on X11. wl-copy for Wayland.
} \
clipboard-yank \
%{
    nop %sh{
        UNAME_OUT="$(uname)"
        if [[ $UNAME_OUT == "Linux" && -n "${WAYLAND_DISPLAY}" ]]
        then
            wl-copy --trim-newline "$kak_selection"
            exit 0
        else
            if [[ -x "$(command -v xsel)" ]]
            then
                printf '%s' "$kak_selection" | xsel -b
                exit 0
            elif [ -x "$(command -v xclip)" ];
            then
                printf '%s' "$kak_selection" | xclip -sel clip
                exit 0
            fi

        fi
        if [[ $UNAME_OUT == "Darwin" ]]
        then
        	printf '%s' "$kak_selection" | pbcopy
        	exit 0
        fi
	exit 1
    }
}
