map global insert <c-[> <esc>
map global normal <c-a> ': inc-dec-modify-numbers + %val{count}<ret>'
map global normal <c-x> ': inc-dec-modify-numbers - %val{count}<ret>'

map -docstring "open_file_picker: opens a file picker using fd" \
    global user   <f>   ': open_file_picker<ret>'
map -docstring "open_buffer_picker: opens a buffer picker using completion" \
    global user   <b>   ': open_buffer_picker<ret>'
map -docstring "open-xplr: open a floating file explorer" \
    global user   <e>   ': open-xplr<ret>'
define-command -docstring "save and quit" x "write-all; quit"

hook global InsertCompletionShow .* %{
	map buffer insert   <tab> <c-n>
	map buffer insert <s-tab> <c-p>
}

hook global InsertCompletionHide .* %{
	unmap buffer insert <tab>
	unmap buffer insert <s-tab>
}

