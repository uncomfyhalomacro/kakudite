hook global BufOpenFile .* %{
    nop %sh{
        if [ -f "$kak_buffile" ] && [ "$kak_buffile" != "$kak_config/recentf" ] && [ "$kak_buffile" != "$kak_config/recentf.tmp" ];
        then
            echo "$kak_buffile" >> "$kak_config"/recentf
            for file in $(cat "$kak_config"/recentf | tr '\n' ' ')
            do
            if [ -f "$file" ]
            then
                echo $file >> "$kak_config"/.recentf-exist
            fi
            done
            sort "$kak_config"/.recentf-exist | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi 
    }
}
hook global BufCreate .* %{
    nop %sh{
        if [ -f "$kak_buffile" ] && [ "$kak_buffile" != "$kak_config/recentf" ] && [ "$kak_buffile" != "$kak_config/recentf.tmp" ];
        then
            for file in $(cat "$kak_config"/recentf | tr '\n' ' ')
            do
            if [ -f "$file" ]
            then
                echo $file >> "$kak_config"/.recentf-exist
            fi
            done
            sort "$kak_config"/.recentf-exist | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}

hook global BufNewFile .* %{
    nop %sh{
        if [ -f "$kak_buffile" ] && [ "$kak_buffile" != "$kak_config/recentf" ] && [ "$kak_buffile" != "$kak_config/recentf.tmp" ];
        then
            for file in $(cat "$kak_config"/recentf | tr '\n' ' ')
            do
            if [ -f "$file" ]
            then
                echo $file >> "$kak_config"/.recentf-exist
            fi
            done
            sort "$kak_config"/.recentf-exist | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}

hook global BufWritePre .* %{
    nop %sh{
        if [ -f "$kak_buffile" ] && [ "$kak_buffile" != "$kak_config/recentf" ] && [ "$kak_buffile" != "$kak_config/recentf.tmp" ];
        then
            for file in $(cat "$kak_config"/recentf | tr '\n' ' ')
            do
            if [ -f "$file" ]
            then
                echo $file >> "$kak_config"/.recentf-exist
            fi
            done
            sort "$kak_config"/.recentf-exist | uniq > "$kak_config"/recentf.tmp
            mv "$kak_config"/recentf.tmp "$kak_config"/recentf
        fi
    }
}
