hook global BufCreate .*\.(sol) %{
    set-option buffer filetype solidity
}

hook global WinSetOption filetype=solidity %{
    require-module solidity
}

provide-module solidity %{
}
