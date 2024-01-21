hook global BufOpenFile .* %{
    nop %sh{
        if [[ -f "$kak_buffile" ]];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            cat "$kak_config"/recentf | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi 
    }
}
hook global BufCreate .* %{
    nop %sh{
        if [[ -f "$kak_buffile" ]];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            cat "$kak_config"/recentf | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}

hook global BufNewFile .* %{
    nop %sh{
        if [[ -f "$kak_buffile" ]];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            cat "$kak_config"/recentf | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}

hook global BufWritePost .* %{
    nop %sh{
        if [[ -f "$kak_buffile" ]];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            cat "$kak_config"/recentf | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}
