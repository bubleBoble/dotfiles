# Raspberry Pi: VS Code Remote-SSH optimization

Use a lighter Python language server on memory-constrained Raspberry Pi hosts, and remove unused VS Code installations when disk space is low. These are separate changes: reducing disk usage does not reduce language-server RAM usage.

This note records a troubleshooting session on 2026-11-02 with a 4 GiB RAM, ARM64 Raspberry Pi, a 28 GB root filesystem on microSD, and a five-folder VS Code workspace. The retained change was **Jedi instead of Pylance on the remote host**. The workspace folders were kept.

This is a manual, per-host setup. The dotfiles installer does not deploy it. Keep it separate from the desktop defaults described in [VS Code configuration](vscode/README.md).

## Evidence and result

Opening the workspace caused high CPU load and swapping. Pylance started background workers for every root, including notes, firmware, and workspace-settings folders. Retained VS Code logs also showed repeated terminal-host heartbeat timeouts before an earlier disconnect.

| Measurement | Before | After |
|---|---|---|
| Python language-server main-process resident memory | Pylance: about 1,598 MiB, even in light mode | Jedi: about 89 MiB |
| Available RAM with the workspace open | About 734 MiB after the Pylance light-mode reload | About 2.1 GiB with Jedi |
| Root filesystem free space | 1.8 GB | 3.1 GB |
| Root filesystem usage | 94% | 89% |
| `~/.vscode-server` disk usage | 2.6 GB when inspected | 1.4 GB after cleanup |

The initial workspace-opening sample showed CPU idle falling to 3%, swap usage growing from zero to roughly 400 MiB, and I/O wait reaching 22%. The Jedi reload sample showed no new swap-outs. Once settled, CPU was 98–99% idle with no swap traffic or I/O wait. The user confirmed that the editor, Python completion/navigation, and a separate SSH terminal remained usable.

These are observations from this workspace, not performance guarantees. The exact historical SSH failure was not captured live, and long-term stability or larger workspaces were not tested. The kernel journal retained only the current boot, so it could not establish whether the previous session had an out-of-memory kill. The Pi reported `throttled=0x0` during inspection.

## Reproduce on another Pi

### 1. Measure before changing anything

Keep a separate SSH terminal open. Run these commands on the Pi, first with VS Code closed and then while opening the affected workspace:

```sh
free -h
vmstat 1 15
df -h /
du -x -h --max-depth=2 "$HOME/.vscode-server"
ps -u "$USER" -o pid,ppid,comm,%cpu,%mem,rss,stat --sort=-rss
```

In `vmstat`, ignore the first data row when evaluating the sampling interval: it reports averages since boot. Watch `si`/`so` for swap traffic, `wa` for I/O wait, and `id` for CPU idle. Available memory from `free` is more useful than free memory alone. Occupied swap without ongoing swap traffic does not by itself indicate a problem.

Node processes can appear as `MainThread`; the process name alone does not identify the extension. Use VS Code's **Developer: Open Process Explorer** and Python output channels to distinguish language-server load from other extensions. Relevant remote logs are under `~/.vscode-server/data/logs/`.

Do not deliberately overload the Pi until SSH becomes unusable. Start with the existing workspace.

### 2. Select Jedi on the remote host

1. Connect to the Pi with VS Code Remote-SSH.
2. Ensure the Microsoft Python extension (`ms-python.python`) is installed on the remote host. The tested version, `2026.10.0`, bundled a working Jedi language server; no separate package installation was needed.
3. Run **Preferences: Open Remote Settings (JSON)** from the Command Palette.
4. Merge this setting into the existing JSON object; do not replace unrelated settings:

```json
{
    "python.languageServer": "Jedi"
}
```

For the standard stable VS Code server installation, the file is `~/.vscode-server/data/Machine/settings.json`. This applies to this remote machine, not the desktop's local settings. Workspace settings can override it, so check for a conflicting `python.languageServer` value if Pylance still starts.

5. Run **Developer: Reload Window**.
6. Keep the same folders open, open a Python file, and test completion or Go to Definition. Repeat the resource measurements during startup and after it settles. Check the Python output channel for `Starting Jedi language server` and confirm that Pylance is no longer the active backend.

**Tradeoff:** Jedi supplies Python completion and navigation, but not Pylance/Pyright static type checking or Pylance-specific features. Interpreter selection, running Python, and debugging remain separate Python-extension capabilities. Completion quality and supported features differ between backends.

**Rollback:** remove `python.languageServer` from the remote settings, or set it to `"Default"`, then reload the window. Pylance was left installed on the original Pi. If it is absent on another host, install it before switching back. Removing the override restores the settings inherited from other scopes.

### 3. Do not retain the light-mode experiment

We first tried `python.analysis.languageServerMode: "light"` with Pylance `2026.4.1`. It stopped background source discovery/indexing, but Pylance still created workers for all five roots and used about 1.6 GiB resident memory after reload.

That setting was **removed**, not combined with the final Jedi configuration. There is no light-mode override to undo from this session. It may help other workloads, but it did not provide sufficient memory headroom here.

## Disk cleanup performed

Only obsolete installations and cached downloads were removed, with approval. Settings, current extensions, project files, and workspace state were preserved.

| Removed path, relative to `~/.vscode-server/` | Approximate space reclaimed | Tradeoff and recovery |
|---|---|---|
| `data/CachedExtensionVSIXs` | 345 MB | Cached extension downloads are gone. VS Code downloads packages again when needed. |
| `extensions/ms-vscode.cpptools-1.34.4-linux-arm64` | 302 MB | This version was already marked obsolete. Version `1.35.5` was retained. To roll back the extension, use its gear menu → **Install Another Version…** → `1.34.4`, if available. |
| `cli/servers/Stable-2a59476c9bfcb90b3ddc372c36762471b7dfad1c` and `code-2a59476c9bfcb90b3ddc372c36762471b7dfad1c` | 659 MB combined | The older server and launcher were unused by running processes. An older matching VS Code client normally downloads its required server again on connection. |

The current server/launcher, commit `2c33b50b16c472efe58357d1d2a8a5414bc23fbf`, was retained. Deleted bytes cannot be restored locally; recovery relies on downloading the required versions again.

### Repeat cleanup safely

Do not copy the recorded version identifiers into a cleanup command for another machine. They describe this session, not a general retention rule.

- Measure directory sizes first. A large directory may contain active extensions or server versions needed by another client.
- Close remote VS Code sessions and confirm no remaining process uses an installation before removing it. Keep the independent SSH session open.
- Check `extensions/.obsolete` and the installed extension versions. Do not assume the older-looking directory is unused.
- Remove only explicitly identified cached downloads or unused version directories. Do not delete all of `~/.vscode-server`, `data/User`, or `data/Machine`.
- Expect a download on reconnection if a client needs a removed version. Keep required versions when offline recovery matters.
- Measure `df -h /` and `du -sh "$HOME/.vscode-server"` afterward.

## Ruff is complementary, not a replacement

Ruff handles linting, automatic fixes, import sorting, and formatting. Jedi handles Python completion and navigation. Pylance combines completion/navigation with Pyright-based type analysis and other features.

**Jedi + Ruff** is a reasonable low-resource combination when linting and formatting are also wanted. Ruff alone does not replace Jedi's general completion and navigation. Ruff was not installed, configured, or benchmarked during this optimization, and neither Ruff nor Jedi substitutes for Pylance/Pyright static type checking.

## Changes deliberately not made

- No workspace folders were removed, and no project files were changed.
- Watcher/search exclusions were not changed. The workspace included `.venv` in watching and search, but its contribution to the slowdown was not isolated.
- C/C++ extension settings, kernel watcher limits, swap configuration, SSH configuration, and boot settings were not changed.
- No extra language-server package was installed and no automatic cleanup job was added.

Do not add hard language-server memory limits merely to force a smaller number: an insufficient heap limit can turn pressure into repeated crashes and restarts.

## Planned migration from microSD to USB storage

Moving the OS to the planned approximately 90 GB USB flash drive should relieve the capacity constraint if the root partition is expanded to use the additional space. The migration was not performed during this session.

- Back up important data and keep the original SD card intact until USB boot and the development environment work reliably.
- A larger drive does not increase the Pi's 4 GiB RAM. Re-measure before restoring Pylance or expanding the workload.
- USB flash is not automatically faster than microSD. Small-file/random-I/O performance matters for indexing and swap; the planned drive was not benchmarked.
- A reputable USB 3 SSD is generally preferable for sustained development workloads and random writes when choosing new storage.

Storage capacity and language-server memory pressure are separate constraints. Keep the measured Python-backend improvement even after migration unless a new comparison supports changing it.
