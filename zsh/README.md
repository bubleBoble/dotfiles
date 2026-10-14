# Zsh

No Oh My Zsh runtime dependency. The [OMZ submodule](<plugins/ohmyzsh/>) is kept only as an upstream reference; updating it does not change shell behavior.

- [zshrc](<zshrc>) installs as `~/.zshrc` and defines Git aliases (`ga`, `gsr`, `gd`, `gco`, `glo`), completion, history, and key bindings.
- [Eastwood](<themes/eastwood.zsh-theme>) is a local copy with only its required Git helpers. Upstream revision is recorded in the file; the [MIT license](<themes/LICENSE.txt>) is retained.
- Autosuggestions and syntax highlighting load directly from their own submodules.

## Setup

From the repository root:

```bash
git submodule update --init --recursive -- zsh/plugins
./install install zsh
```

Open a new terminal after installation.
