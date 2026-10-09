Clone with:
```sh
git clone --recurse-submodules -j8 https://github.com/bubleBoble/dotfiles.git
```

Install all configurations with `./install --install`, or select individual tools:

```sh
./install --install nvim
./install --install claude
./install --install codex
./install --install dsh
./install --install vim
./install --install claude codex dsh
```

Shared agent instructions and skills follow the selected destination tool. The same
selection works with `--remove` and `--sync-back`; `agents` selects only `~/.agents`.

Run installer tests with `python3 -B -m unittest discover -s tests -v`.

template:
https://github.com/hendrikmi/dotfiles/tree/main
