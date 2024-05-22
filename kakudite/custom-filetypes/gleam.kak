hook global BufCreate .*\.(gleam) %{
    set-option buffer filetype gleam
}

hook global WinSetOption filetype=gleam %{
    require-module gleam
}

provide-module gleam %{
}
