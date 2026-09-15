# Git Configuration

Portable git config symlinked to `~/.gitconfig`. Create `~/.gitconfig.local` for machine-local identity:

```ini
[user]
	name = adomrazek
	email = domrazekadam@gmail.com
```

The gitconfig includes this file via `[include] path = ~/.gitconfig.local`.
