define-command -docstring %{
	get-emojis: Download emojis from <https://unicode.org/Public/emoji/latest/emoji-test.txt>

	Uses curl under the hood to download them and sed to filter text.
} \
get-emojis \
%{
	nop %sh{
		local emojis
		local emojis_location
		emojis_location="$kak_config"/unicode

		if [[ ! -f "$emojis_location/emojis.txt" ]];
		then
			emojis=$(curl -sSL https://unicode.org/Public/emoji/latest/emoji-test.txt)
			mkdir -p $emojis_location
			printf "%s" "$emojis" | sed -E -ne 's/^.*; fully-qualified.*# ([^[:space:]]*) [^[:space:]]* (.*$)/\1 \2/gp' >"$emojis_location/emojis.txt"
		fi
	}
}

define-command -docstring %{
	get-math-symbols: Download math symbols from <https://unicode.org/Public/math/latest/MathClassEx-15.txt>

} \
get-math-symbols \
%{
	nop %sh{
		local math_symbols
		local math_symbols_location

		math_symbols_location="$kak_config"/unicode
		if [[ ! -f "$math_symbols_location"/math.txt ]];
		then
			math_symbols=$(curl -sSL "https://unicode.org/Public/math/latest/MathClassEx-15.txt")
			mkdir -p $math_symbols_location
			printf "%s" "$math_symbols" | grep -ve '^#' | cut -d';' -f3,7 | sed -e 's/;/ /' >"$math_symbols_location/math.txt"
		fi
	}
}

define-command -hidden open-unicode-picker %{
  evaluate-commands get-emojis
  evaluate-commands get-math-symbols
  prompt file: -menu -shell-script-candidates "cat $kak_config/unicode/*.txt" %{
    execute-keys %sh{
        local char
        char=$(printf "%s" "$kak_text" | cut -d' ' -f1)
        printf "i%s" "$char"
    }
  }
}

map -docstring "open-unicode-picker: opens a list of unicode symbols" \
    global user   <E>   ': open-unicode-picker<ret>'
