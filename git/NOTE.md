# Git Configuration

Portable git config symlinked to `~/.gitconfig`. Create
`~/.gitconfig.local` for machine-local identity:

```ini
[user]
	name = aabc
	email = abc@abc.com
```

The gitconfig includes this file via `[include] path = ~/.gitconfig.local`.
