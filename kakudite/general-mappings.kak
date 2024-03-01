map global insert <c-[> <esc>
map global normal <c-a> ': inc-dec-modify-numbers + %val{count}<ret>'
map global normal <c-x> ': inc-dec-modify-numbers - %val{count}<ret>'

map -docstring "open_file_picker: opens a file picker using fd" \
    global user   <f>   ': open_file_picker<ret>'
map -docstring \
    "open_recentf_picker: opens a recently opened file from a list of recent files" \
    global user   <r>   ': open_recent_file_picker<ret>'
map -docstring "open_buffer_picker: opens a buffer picker using completion" \
    global user   <b>   ': open_buffer_picker<ret>'
map -docstring "open-xplr: open a floating file explorer" \
    global user   <e>   ': open-xplr<ret>'
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

