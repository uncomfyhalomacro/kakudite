hook global BufOpenFile .* %{
    nop %sh{
        if [ -f "$kak_buffile" -a ! -f "$kak_config/recentf" ];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            sort "$kak_config"/recentf | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi 
    }
}
hook global BufCreate .* %{
    nop %sh{
        if [ -f "$kak_buffile" -a ! -f "$kak_config/recentf" ];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            sort "$kak_config"/recentf | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}

hook global BufNewFile .* %{
    nop %sh{
        if [ -f "$kak_buffile" -a ! -f "$kak_config/recentf" ];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            sort "$kak_config"/recentf | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}

hook global BufWritePost .* %{
    nop %sh{
        if [ -f "$kak_buffile" -a ! -f "$kak_config/recentf" ];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            sort "$kak_config"/recentf | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}
