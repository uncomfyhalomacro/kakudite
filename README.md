# Kakudite

A kakoune config for the curious. 

# Installation

To install, run:

```bash
git clone https://git.sr.ht/~uncomfy/kakudite ~/.config/kak
```

Then finally run

```bash
kak -e 'bundle-install'
```

## For Julia users

Run the following 

```bash
julia --project=@kak-lsp scripts/julia-ls-install
```

# Requires

- xplr
- notify-send
- fd
- sk
- rust
- zellij

## Bootstrapped with kak-bundle
- kak-tree-sitter
- kak-lsp
