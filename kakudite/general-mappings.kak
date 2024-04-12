map global insert <c-[> <esc>
map global normal <c-a> ': inc-dec-modify-numbers + %val{count}<ret>'
map global normal <c-x> ': inc-dec-modify-numbers - %val{count}<ret>'

map -docstring "open-file-picker: opens a file picker using fd" \
    global user   <f>   ': open-file-picker<ret>'
map -docstring \
    "open-recentf-picker: opens a recently opened file from a list of recent files" \
    global user   <r>   ': open-recent-file-picker<ret>'
map -docstring "open-buffer-picker: opens a buffer picker using completion" \
    global user   <b>   ': open-buffer-picker<ret>'
define-command -docstring %{
    aliased to `write-all-quit -sync`
} \
x "write-all-quit -sync 0"

map global normal <c-v> ":comment-line<ret>"

hook global InsertCompletionShow .* %{
	map buffer insert   <tab> <c-n>
	map buffer insert <s-tab> <c-p>
}

hook global InsertCompletionHide .* %{
	unmap buffer insert <tab>
	unmap buffer insert <s-tab>
}

