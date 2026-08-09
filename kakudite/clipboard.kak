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
            nohup wl-copy --trim-newline "$kak_selection" 2>/dev/null &
            exit 0
        else
            if [[ -x "$(command -v xsel)" ]]
            then
                nohup xsel -b <<< "$kak_selection" 2>/dev/null &
                exit 0
            elif [ -x "$(command -v xclip)" ];
            then
                nohup xclip -sel clip <<< "$kak_selection" 2>/dev/null &
                exit 0
            fi

        fi
        if [[ $UNAME_OUT == "Darwin" ]]
        then
        	nohup pbcopy <<< "$kak_selection" 2>/dev/null &
        	exit 0
        fi
	exit 1
    }
}
